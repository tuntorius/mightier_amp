// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../NuxDevice.dart';
import '../NuxFXID.dart';
import '../effects/Processor.dart';
import '../effects/gp5/GP5Effects.dart';
import '../effects/gp5/GP5Processor.dart';
import '../presets/Gp5Preset.dart';
import '../value_formatters/SwitchFormatters.dart';
import '../../../utilities/MathEx.dart';
import 'communication.dart';
import '../value_formatters/GP5Formatters.dart';
import 'gp5ParamCell.dart';

/// Communication layer for the Valeton GP5.
///
/// The GP5 uses a custom BLE SysEx protocol. Every command is a frame:
/// `80 80 F0` + addzero(crcHex + commandHex) + `F7` where commandHex is the
/// raw binary command expressed as hex digits. On the wire every actual byte
/// is transmitted as its two hex digits as byte values, so the incoming
/// notifications use the same "nibble split" encoding.
class Gp5Communication extends DeviceCommunication {
  Gp5Communication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  @override
  int get connectionSteps => 1;

  bool _presetsReadyNotified = false;
  final Set<String> _reportedUnmappedCells = <String>{};
  Timer? _currentPatchTimer;
  Timer? _patchDataEndTimer;
  bool _tailRequested = false;
  Timer? _stageAdvanceTimer;
  int _currentPatch = -1;
  bool _uuidUnlocked = false;
  // Track last local parameter writes to avoid readback overwriting
  // values during fast slider drags (readback is needed after context changes
  // like effect/preset switches, not for optimistic local writes)
  final Map<String, int> _lastLocalParamWriteMs = <String, int>{};
  static const int _localWriteSuppressMs = 1500;

  /// arms a single timer that advances the sync chain when the current stage
  /// stream goes idle (the pedal's stage-end control frames are frequently
  /// dropped by the BLE stack, so a quiet stage is treated like its end).
  void _armStageAdvance(Duration wait, void Function() advance) {
    _stageAdvanceTimer?.cancel();
    _stageAdvanceTimer = Timer(wait, () {
      _stageAdvanceTimer = null;
      advance();
    });
  }

  // ==================== commands ====================

  static String _addzero(String s) {
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write('0${s[i]}');
    }
    return buf.toString();
  }

  static List<int> _hexStringToBytes(String hexString) {
    hexString = hexString.replaceAll(RegExp(r'\s+'), '');
    final bytes = <int>[];
    for (int i = 0; i < hexString.length; i += 2) {
      final end = i + 2 <= hexString.length ? i + 2 : i + 1;
      bytes.add(int.parse(hexString.substring(i, end), radix: 16));
    }
    return bytes;
  }

  static int _crc8(List<int> bytes) {
    int crc = 0x00;
    for (int i = 0; i < bytes.length; i++) {
      int cur = bytes[i] & 0xff;
      crc ^= cur;
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x80) != 0) {
          crc = ((crc << 1) ^ 0x07) & 0xff;
        } else {
          crc = (crc << 1) & 0xff;
        }
      }
    }
    return crc & 0xff;
  }

  /// builds a full BLE frame for the given command expressed as hex digits
  static List<int> _frame(String commandHex) {
    final commandBytes = _hexStringToBytes(commandHex);
    final crc = _crc8(commandBytes);
    final crcHex = crc.toRadixString(16).padLeft(2, '0').toUpperCase();
    return _hexStringToBytes('8080F0${_addzero(crcHex + commandHex)}F7');
  }

  //fixed (already addzero'd) sysex frames used by the device sync handshake
  //requestDeviceUUID(0x32): the device answers this read with the RID body -
  //80 80 F0 05 07 00 01 00 00 00 02 01 02 03 02 F7 (crc 0x57), gets a verbatim
  //echo, then after start_sync(0x40) the pedal PUSHES the whole patch list +
  //snaptones + IRs + current patch + patch data without further requests.
  static final List<int> _requestDeviceUuid = _hexStringToBytes(
      '8080F0050700010000000201020302F7');
  static final List<int> _startSyncFrame = _hexStringToBytes(
      '8080F0000E00010000000201020400F7');
  static final List<int> _requestPatchList = _hexStringToBytes(
      '8080f0030500010000000201020204f7');
  static final List<int> _requestSnaptonesFrame = _hexStringToBytes(
      '8080f0030500010000000201020204f7');
  static final List<int> _requestIrListFrame = _hexStringToBytes(
      '8080F0020900010000000201020200F7');
  static final List<int> _requestCurrentPatchNumberFrame = _hexStringToBytes(
      '8080F0000700010000000201020403F7');
  static final List<int> _requestPatchData = _hexStringToBytes(
      '8080f0000900010000000201020401f7');

  @override
  List<int> createFirmwareMessage() {
    return [];
  }

  @override
  void performNextConnectionStep() {
    switch (currentConnectionStep) {
      case 0:
        _startSync();
        break;
    }
  }

  @override
  void syncOnConnect() {
    _startSync();
  }

  bool _syncInProgress = false;

  void _startSync() async {
    if (_syncInProgress) {
      //defend against double-trigger: connect hits this via syncOnConnect
      //(deviceConnected) AND via performNextConnectionStep (firmware ready)
      if (kDebugMode)
        debugPrint('[GP5] sync already in progress, skipping re-entry');
        return;
    }
    _syncInProgress = true;
    if (kDebugMode)
      debugPrint('[GP5] gate startSync-detected@connect');
      _presetsReadyNotified = false;

    //UNLOCK: the connect flow first sends requestDeviceUUID (msg address
    //0x32, flag=response) and only proceeds to the sync chain once the pedal
    //answers (reply msg address 0x64, mapped to
    //PresetModel.updateDeviceUUId/isDeviceId). Without this handshake every
    //read is answered by a bare echo.
    _uuidUnlocked = false;
    if (kDebugMode)
      debugPrint('[GP5] SEND requestDeviceUUID(0x32) '
          't=${DateTime.now().millisecondsSinceEpoch % 1000000}');
    device.deviceControl.sendBLEData(_requestDeviceUuid);
    final stopwatch = Stopwatch()..start();
    while (!_uuidUnlocked && stopwatch.elapsedMilliseconds < 5000) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!device.deviceControl.isConnected) {
        _syncInProgress = false;
        return;
      }
    }
    if (kDebugMode)
      debugPrint('[GP5] UUID handshake ${_uuidUnlocked ? "OK" : "TIMEOUT"} '
          'after ${stopwatch.elapsedMilliseconds}ms');

    await Future.delayed(const Duration(milliseconds: 800));
    if (!device.deviceControl.isConnected) {
      _syncInProgress = false;
      return;
    }
    //device sync chain: start_sync first, declare the connection complete
    //right away (beats the app's 10s connection timer), then request the patch
    //list. Everything after that is notification-driven:
    //   patch_list(212B) -> end(16B) -> request_snaptones
    //   -> snaptones end(136B) -> request_ir_list
    //   -> IRs end(96B) -> request_current_patch_number
    //   -> current patch(20B) -> request_patch_data(0x41)
    //   -> patch data parts -> final -> _onPatchDataComplete
    if (kDebugMode)
      debugPrint('[GP5] SEND start_sync(0x40 names) '
          't=${DateTime.now().millisecondsSinceEpoch % 1000000}');
    device.deviceControl.sendBLEData(_startSyncFrame);
    //declare the device ready right away so the UI handshake is unaffected
    connectionStepReady();
    if (kDebugMode)
      debugPrint('[GP5] sync handshake complete, starting patch-list chain');
      //the pedal PUSHES the whole patch list / snaptones / IRs / current patch
      //on its own after start_sync; no further reads are needed from our side.
      await Future.delayed(const Duration(milliseconds: 800));
    _syncInProgress = false;
  }

  @override
  List<int> setChannel(int channel) {
    //the patch data replied by the device belongs to this channel
    _currentPatch = channel;
    // context change - allow readback to apply
    _lastLocalParamWriteMs.clear();
    //return the frame, the caller sends it (only once), then refresh the data
    _schedulePatchDataRefresh();
    return _changePatch(channel);
  }

  List<int> _changePatch(int channel) {
    final patch = channel.toRadixString(16).padLeft(2, '0');
    return _frame('0100061143${patch}000000');
  }

  @override
  List<int> requestPresetByIndex(int index) {
    _currentPatch = index;
    _lastLocalParamWriteMs.clear();
    _schedulePatchDataRefresh();
    return _changePatch(index);
  }

  void _schedulePatchDataRefresh() {
    Future.delayed(const Duration(milliseconds: 250), () {
      _requestPatchDataWithTail();
    });
  }

  /// The pedal answers a request with patch-data parts 0-3 and only emits the
  /// 148-byte "end of patch data" frame once the request is repeated, so the
  /// repeat is triggered when part 3 arrives (see [_requestPatchDataTail]).
  void _requestPatchDataWithTail() {
    if (!device.deviceControl.isConnected) return;
    _tailRequested = false;
    device.deviceControl.sendBLEData(_requestPatchData);
  }

  /// Asks for the patch once more now that parts 0-3 have been received; that
  /// second request is what makes the pedal send the 148-byte final frame
  /// carrying the block 8 overflow and all of block 9.
  void _requestPatchDataTail() {
    if (_tailRequested || !device.deviceControl.isConnected) return;
    _tailRequested = true;
    // the pedal only emits the final frame in answer to a repeated request,
    // and it takes a couple of tries, so keep asking briefly
    for (int attempt = 1; attempt <= 3; attempt++) {
      Timer(Duration(milliseconds: attempt * 300), () {
        if (device.deviceControl.isConnected) {
          device.deviceControl.sendBLEData(_requestPatchData);
        }
      });
    }
  }

  void _cancelCurrentPatchTimer() {
    _currentPatchTimer?.cancel();
    _currentPatchTimer = null;
  }

  /// current patch number reply (and patch_changed notification) handling
  void _handlePatchNumber(int patch) {
    _cancelCurrentPatchTimer();
    _currentPatch = patch;

    if (device.selectedChannel != patch) {
      device.setSelectedChannel(patch,
          notifyBT: false, sendFullPreset: false, notifyUI: true);
    } else {
      device.deviceControl.forceNotifyListeners();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      _requestPatchDataWithTail();
    });
  }

  @override
  void sendSlotEnabledState(int slot) {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    int status = preset.slotEnabled(slot) ? 1 : 0;
    int block = preset.getFXIDFromSlot(slot).toInt();
    var command = '01000a11490${block}0000000${status}000000';
    device.deviceControl.sendBLEData(_frame(command));
  }

  @override
  void sendSlotEffect(int slot, int index) {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    var effects = preset.getEffectsForSlot(slot);
    if (index < 0 || index >= effects.length) return;
    var fx = effects[index] as Gp5Processor;
    var block = preset.getFXIDFromSlot(slot).toInt();
    var command =
        '01000e11470${block}0000000${block}000000${fx.effectIdHex}';
    if (kDebugMode) {
      debugPrint('[GP5] SEND change-fx slot=$slot index=$index block=$block'
          ' fx=${fx.name} id=${fx.effectIdHex} cmd=$command');
    }
    //A freshly changed algorithm drops parameter writes until the pedal has
    //loaded its values from patch storage: on the pedal, Arena's Decay was dead
    //until the patch was read back after the change-fx. Measured on device.
    // Context change - clear local write suppressions so readback applies
    _lastLocalParamWriteMs.clear();
    _schedulePatchDataRefresh();
    device.deviceControl.sendBLEData(_frame(command));
  }

  @override
  bool get customParameterSending => true;

  @override
  List<int> sendParameter(Parameter param) {
    if (!device.deviceControl.isConnected) return [];
    var block = (param.midiCC - MidiCCValuesGP5.none) ~/ 8;
    if (block < 0 || block > 9) return [];

    var preset = device.getPreset(device.selectedChannel);
    var slot = preset.getSlotFromFXID(NuxFXID.fromInt(block))!;
    var effect = preset
        .getEffectsForSlot(slot)[preset.getSelectedEffectForSlot(slot)];
    var paramIndex = effect.parameters.indexOf(param);
    if (paramIndex < 0) return [];

    //The reverb and delay blocks address their parameters by declared wire bytes
    //instead of by their slot in the app's list (see GP5Effects.rvbEffects /
    //dlyEffects): the pedal numbers them with the "algId" from the official
    //metadata, which is sparse. Everywhere else the slot order is the address.
    //resolveWireParam() owns that decision, including which parameters of a
    //sparse block are not writable at all.
    final wireParam =
        GP5Effects.resolveWireParam(block, paramIndex, param.wireAddress);
    if (wireParam == null) return [];

    double value = param.value;
    //master volume is scaled by the app master volume setting
    if (param.masterVolume) {
      value = value * (device.deviceControl.masterVolume * 0.01);
    }

    //the GP5 stores every parameter (switches included) on the same 0-100
    //percent grid, so an On switch is written as 100, not 1 (the model domain
    //for switches is 0/1).
    if (param.formatter is SwitchFormatter) {
      value = (value * 100).clamp(0, 100);
    }

    var blockHex = block.toRadixString(16).padLeft(2, '0');
    var paramHex = wireParam.toRadixString(16).padLeft(2, '0');

    final bd = ByteData(4)..setFloat32(0, value, Endian.little);
    final valueHex = StringBuffer();
    for (int i = 0; i < 4; i++) {
      valueHex
          .write(bd.getUint8(i).toRadixString(16).padLeft(2, '0'));
    }

    if (kDebugMode) {
      debugPrint('[GP5] SEND change-param block=$block index=$paramIndex'
          ' wireParam=$wireParam value=$value '
          'cmd=01000e1148$blockHex' '000000$paramHex' '000000$valueHex');
    }

    final frame =
        _frame('01000e1148$blockHex' '000000$paramHex' '000000$valueHex');
    //The pedal does not push a patch update of its own after a parameter
    //write, but we do not want readback to overwrite optimistic values during
    //fast drags - refresh is only needed to confirm writes after a short delay,
    //and we suppress applying readback for recently written params. Measured
    //on device: a full MHigh sweep produced change-param frames and no patch
    //data at all.
    _recordLocalParamWrite(block, wireParam);
    _schedulePatchDataRefresh();
    return frame;
  }

  @override
  void requestBatteryStatus() {
    //no battery support on the GP5
  }

  @override
  void saveCurrentPreset(int index) {
    //the GP5 keeps live edits in RAM; persist them to the target slot with a
    //10-char name via the 0x11 0x4A store command
    final patch = index.toRadixString(16).padLeft(2, '0').toUpperCase();
    final name = _sanitizeStoreName(
        index >= 0 && index < device.channelNames.length
            ? device.channelNames[index]
            : '');
    final nameHex = name.codeUnits
        .map((c) => c.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();
    final command = '010010114a$patch' '000000$nameHex';
    device.deviceControl.sendBLEData(_frame(command));
  }

  /// GP-5 store command name field: ASCII [A-Za-z0-9 -], max 10 chars, padded
  static String _sanitizeStoreName(String input) {
    final clean = input.replaceAll(RegExp(r'[^A-Za-z0-9 \-]'), '');
    return clean.length > 10
        ? clean.substring(0, 10)
        : clean.padRight(10, ' ');
  }

  @override
  void sendReset() {}

  @override
  void sendDrumsEnabled(bool enabled) {}
  @override
  void sendDrumsStyle(int style) {}
  @override
  void sendDrumsLevel(double volume) {}
  @override
  void sendDrumsTempo(double tempo) {}
  @override
  void setEcoMode(bool enable) {}
  @override
  void setBTEq(int eq) {}
  @override
  void setUsbAudioMode(int mode) {}
  @override
  void setUsbInputVolume(int vol) {}
  @override
  void setUsbOutputVolume(int vol) {}

  @override
  void onDisconnect() {
    super.onDisconnect();
    _syncInProgress = false;
    _stageAdvanceTimer?.cancel();
    _stageAdvanceTimer = null;
    _patchDataEndTimer?.cancel();
    _patchDataEndTimer = null;
    _cancelCurrentPatchTimer();
  }

  // ==================== notifications ====================

  @override
  void onDataReceive(List<int> data) {
    if (data.length < 9) {
      if (kDebugMode)
        debugPrint('[GP5] in DROPPED len=${data.length} bytes='
            '${data.map((e) => e.toRadixString(16).padLeft(2, "0")).join(" ")}');
      return;
    }
    if (data.length >= 80) {
      if (kDebugMode)
        debugPrint('[GP5] in len=${data.length} '
            '${data.map((e) => e.toRadixString(16).padLeft(2, "0")).join(" ")} '
            't=${DateTime.now().millisecondsSinceEpoch % 1000000}');
    } else {
      if (kDebugMode)
        debugPrint('[GP5] in len=${data.length} '
            '${data.map((e) => e.toRadixString(16).padLeft(2, "0")).join(" ")} '
            't=${DateTime.now().millisecondsSinceEpoch % 1000000}');
    }

    // UUID handshake reply: the pedal echoes the RID body verbatim
    // [0x57, 0x01, 0x00, 0x02, 0x12, 0x32]. Accept addr 0x32 or the
    // 0x64 form.
    if (!_uuidUnlocked && data[data.length - 1] == 0xf7) {
      final wireLen = (data.length - 6) ~/ 2;
      if (wireLen >= 6) {
        final buf = List<int>.generate(
            wireLen, (i) => data[5 + i * 2] * 16 + data[5 + i * 2 + 1]);
        if (buf[1] == 0x01 && buf[2] == 0x00 &&
            (buf[5] == 0x32 || buf[5] == 0x64)) {
          _uuidUnlocked = true;
          if (kDebugMode)
            debugPrint('[GP5] UUID handshake reply received '
                'BUF=${buf.map((e) => e.toRadixString(16).padLeft(2, "0")).join(" ")}');
          return;
        }
      }
    }

    // change-parameter notification (device pushes active-patch param values).
    // wire: 80 80 80 80 f0 + addzero(real BUF) + 0f, real BUF is 18 bytes:
    // [crc, 0x01, 0x00, 0x0e, 0x11, 0x48, block, 0x00,0x00,0x00, param,
    //  0x00,0x00,0x00, value(4, float32 LE)]
    if (data.length >= 42 && data[5] <= 0x0f && data[data.length - 1] == 0x0f) {
      final wireLen = (data.length - 6) ~/ 2;
      final buf = List<int>.generate(wireLen, (i) => data[5 + i * 2] * 16 + data[5 + i * 2 + 1]);
      if (buf.length >= 18 && buf[1] == 0x01 && buf[2] == 0x00 && buf[3] == 0x0e && buf[4] == 0x11 && buf[5] == 0x48) {
        final block = buf[6];
        final param = buf[10];
        final value = _readFloat(buf, 14);
        if (kDebugMode)
          debugPrint('[GP5] change-param block=$block param=$param value=$value '
              'BUF=${buf.map((e) => e.toRadixString(16).padLeft(2, "0")).join(" ")}');
        _applyChangeParameter(block, param, value);
        return;
      }
    }

    // patch list (5 names per notification)
    if (data.length == 212 && data[5] == 1 && data[6] == 5) {
      _parsePatchList(data);
      _armStageAdvance(const Duration(milliseconds: 1200),
          () => device.deviceControl.sendBLEData(_requestSnaptonesFrame));
      return;
    }

    // snaptones content frames (pushed 212B) - end frame handled below
    if (data.length == 212 && data[5] == 0 && data[6] == 0x0e) {
      _armStageAdvance(const Duration(milliseconds: 1200),
          () => device.deviceControl.sendBLEData(_requestIrListFrame));
      return;
    }

    // IRs content frames (pushed 212B) - end frame handled below
    if (data.length == 212 && data[5] == 0 && data[6] == 0x04) {
      _armStageAdvance(const Duration(milliseconds: 1200),
          () => device.deviceControl.sendBLEData(_requestCurrentPatchNumberFrame));
      return;
    }

    // end of patch list -> next phase: snaptones
    if (data.length == 16 &&
        data[5] == 1 &&
        data[6] == 5 &&
        data[7] == 1 &&
        data[8] == 4) {
      _stageAdvanceTimer?.cancel();
      _stageAdvanceTimer = null;
      device.deviceControl.forceNotifyListeners();
      if (kDebugMode)
        debugPrint('[GP5] patch-list end -> request_snaptones');
        device.deviceControl.sendBLEData(_requestSnaptonesFrame);
      return;
    }

    // end of snaptones list -> next phase: IR list
    if (data.length == 136 && data[5] == 0 && data[6] == 14) {
      _stageAdvanceTimer?.cancel();
      _stageAdvanceTimer = null;
      if (kDebugMode)
        debugPrint('[GP5] snaptones end -> request_ir_list');
        device.deviceControl.sendBLEData(_requestIrListFrame);
      return;
    }

    // end of IR list -> next phase: current patch number
    if (data.length == 96 && data[5] == 0 && data[6] == 4) {
      _stageAdvanceTimer?.cancel();
      _stageAdvanceTimer = null;
      if (kDebugMode)
        debugPrint('[GP5] IRs end -> request_current_patch_number');
        device.deviceControl.sendBLEData(_requestCurrentPatchNumberFrame);
      return;
    }

    // current patch number
    if (data.length == 20 &&
        data[5] == 0 &&
        data[6] == 1 &&
        data[10] == 4 &&
        data[11] == 1 &&
        data[12] == 2) {
      var patch = data[15] * 16 + data[16];
      _handlePatchNumber(patch);
      return;
    }

    // patch changed on the device
    if (data.length == 24 &&
        data[5] == 0 &&
        data[6] == 1 &&
        data[12] == 2 &&
        data[13] == 4 &&
        data[14] == 3) {
      var patch = data[15] * 16 + data[16];
      _handlePatchNumber(patch);
      return;
    }

    // patch data
    if (data.length == 212 && data[5] == 0 && data[6] == 5) {
      if (data[7] != 0) return;
      if (_currentPatch < 0 || _currentPatch >= device.channelsCount) return;
      switch (data[8]) {
        case 0:
          _parsePatchData1(data);
          break;
        case 1:
          _parsePatchData2(data);
          _parseParamCells(data, 1);
          break;
        case 2:
          _parseParamCells(data, 2);
          break;
        case 3:
          _parseParamCells(data, 3);
          // parts 0-3 are in; ask again to get the 148-byte final frame
          Timer(const Duration(milliseconds: 400), _requestPatchDataTail);
          break;
      }
      //the pedal pushes the parts one-by-one and only sends the 148B final
      //frame in answer to the repeated request above; fall back to a timeout
      //so the sync still completes when that frame does not arrive.
      _patchDataEndTimer ??= Timer(const Duration(milliseconds: 2500), () {
        _patchDataEndTimer = null;
        _onPatchDataComplete();
      });
      return;
    }

    // end of patch data
    if (data.length == 148 &&
        data[5] == 0 &&
        data[6] == 5 &&
        data[7] == 0 &&
        data[8] == 4) {
      // carries the block 8 overflow and all of block 9
      _parseParamCells(data, 4);
      _patchDataEndTimer?.cancel();
      _patchDataEndTimer = null;
      _onPatchDataComplete();
    }
  }

  /// reads a 4 byte value encoded as 8 nibble bytes starting at [start]
  String _readEffectId(List<int> b, int start) {
    if (b.length < start + 8) return "";
    final buf = StringBuffer();
    for (int i = 0; i < 4; i++) {
      int v = b[start + i * 2] * 16 + b[start + i * 2 + 1];
      buf.write(v.toRadixString(16).padLeft(2, '0'));
    }
    return buf.toString();
  }

  /// reads a float32 as 4 packed bytes starting at [start] (little endian)
  double _readFloat(List<int> b, int start) {
    if (b.length < start + 4) return 0;
    final bd = ByteData(4);
    for (int i = 0; i < 4; i++) {
      bd.setUint8(i, b[start + i]);
    }
    return bd.getFloat32(0, Endian.little);
  }

  String _paramKey(int block, int paramIndex) => '$block:$paramIndex';

  void _recordLocalParamWrite(int block, int wireParam) {
    _lastLocalParamWriteMs[_paramKey(block, wireParam)] =
        DateTime.now().millisecondsSinceEpoch;
  }

  bool _shouldSuppressReadback(int block, int wireParam) {
    final key = _paramKey(block, wireParam);
    final last = _lastLocalParamWriteMs[key];
    if (last == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - last > _localWriteSuppressMs) {
      _lastLocalParamWriteMs.remove(key);
      return false;
    }
    return true;
  }

  /// applies a device push of the parameter at [block]/[paramIndex] to the
  /// selected effect of the given block on the current preset. [block] is a
  /// data block id / FXID (3 = amp, 9 = ns/NAM). [paramIndex] is the "algId" of
  /// the parameter, the same number [sendParameter] writes, so it is resolved
  /// back through [GP5Effects.resolveWireParam] rather than used as a list
  /// position: on a sparse algorithm the two differ.
  void _applyChangeParameter(int block, int paramIndex, double value) {
    if (block < 0 || block > 9 || paramIndex < 0) return;
    var patch = _currentPatch >= 0 && _currentPatch < device.channelsCount
        ? _currentPatch
        : device.selectedChannel;
    if (patch < 0 || patch >= device.channelsCount) return;
    var preset = device.getPreset(patch);
    var slot = preset.getSlotFromFXID(NuxFXID.fromInt(block))!;
    var effects = preset.getEffectsForSlot(slot);
    if (effects.isEmpty) return;
    var index = preset.getSelectedEffectForSlot(slot);
    if (index < 0 || index >= effects.length) return;
    var effect = effects[index];
    //the pushed index is the wire byte, so find the parameter that is written
    //to it instead of assuming list order
    int? target;
    for (int i = 0; i < effect.parameters.length; i++) {
      if (GP5Effects.resolveWireParam(
              block, i, effect.parameters[i].wireAddress) ==
          paramIndex) {
        target = i;
        break;
      }
    }
    if (target == null) return;
    var param = effect.parameters[target];
    // Device-pushed notifications reflect actual device state (e.g. after
    // external changes); don't suppress them
    if (kDebugMode)
      debugPrint('[GP5] apply change-param block=$block'
          ' effect=${effect.name} param=${param.name} value=$value');
    //The device reports a switch as the cell for percent 1 when it is On
    //(0x0f030008), not as the top of the percent grid. Measured on Bright and
    //on both Trail switches, so anything at or above 1 means On.
    if (param.formatter is SwitchFormatter) {
      value = value >= 1 ? 1.0 : 0.0;
    }
    preset.setParameterValue(param, value, notify: false);
    device.deviceControl.forceNotifyListeners();
  }

  void _parsePatchList(List<int> b) {
    var index = (b[7] * 16 + b[8]) * 5;
    var names = <String>[];
    for (int k = 0; k < 5; k++) {
      var start = 23 + k * 40;
      if (index + k >= device.channelNames.length) continue;
      var nameBuf = StringBuffer();
      for (int i = 0; i < 20; i += 2) {
        if (start + i + 1 >= b.length) break;
        int code = b[start + i] * 16 + b[start + i + 1];
        if (code != 0) nameBuf.writeCharCode(code);
      }
      var name = nameBuf.toString().trim();
      names.add(name);
      //update the device channel name for the UI
      if (name.isNotEmpty) device.channelNames[index + k] = name;
    }
    if (kDebugMode)
      debugPrint('[GP5] patch-list frag idx=${b[7] * 16 + b[8]} base=$index '
          'names=${names.map((e) => "«$e»").join(',')}');
  }

  /// Applies every parameter cell carried by patch-data part [part] to the
  /// effects currently selected on [preset]. The device reports each parameter
  /// as a normalised position, so it is mapped back onto the parameter's own
  /// range; on/off switches only ever report 0 or 100.
  void _parseParamCells(List<int> b, int part) {
    if (_currentPatch < 0 || _currentPatch >= device.channelsCount) return;
    final preset = device.getPreset(_currentPatch) as Gp5Preset;

    for (final block in gp5ParamCellBase.keys) {
      final slot = preset.getSlotFromFXID(NuxFXID.fromInt(block));
      if (slot == null) continue;
      final effects = preset.getEffectsForSlot(slot);
      if (effects.isEmpty) continue;
      final selected = preset.getSelectedEffectForSlot(slot);
      if (selected < 0 || selected >= effects.length) continue;
      final effect = effects[selected];
      for (int i = 0; i < effect.parameters.length; i++) {
        final param = effect.parameters[i];
        // the patch stores a parameter's cell at its wire address (`algId`),
        // not at its list position: sparse effects leave holes between cells
        // (Bias Trem Bias=4, RVB Trail=3/6, EV 51 PRES=6). Using the list index
        // here read the hole and snapped sparse parameters back to default.
        final wire =
            GP5Effects.resolveWireParam(block, i, param.wireAddress) ?? i;
        // the cell is at the wire address in every block, including block 8,
        // whose cells simply continue into the final frame (see
        // gp5ParamCellIndex)
        final cellIndex = gp5ParamCellIndex(block, i, wire);
        // a cell can live in a later part than the block's own part, e.g.
        // block 8 continues in the 148-byte final frame
        final pos = gp5ParamCellPosition(block, cellIndex);
        if (pos == null || pos[0] != part) continue;
        if (_shouldSuppressReadback(block, wire)) {
          // Don't overwrite values we just wrote locally during fast drags;
          // readback is still useful for context changes (effect/preset switch)
          // because those don't set local write timestamps in the same way
          continue;
        }
        final cell = gp5CellAt(b, pos[1]);
        final formatter = param.formatter;
        final family = formatter is GP5FloatFormatter
            ? gp5CellFamily(formatter.minVal, formatter.maxVal)
            : Gp5CellFamily.percent;
        final value = cell == null ? null : gp5DecodeCell(family, cell);
        if (value == null) {
          // A cell the device has not been seen to produce for this parameter.
          // Leave the parameter at its default rather than guess a value.
          _reportUnmappedCell(block, effect, i, b, pos[1]);
          continue;
        }
        if (formatter is SwitchFormatter) {
          // The device reports On as the cell for percent 1 (0x0f030008) rather
          // than the top of the grid, so the threshold is 1 and not 50.
          param.value = value >= 1 ? 1.0 : 0.0;
        } else if (family == Gp5CellFamily.percent) {
          // a percentage is a position on a 0-100 scale, not the value itself,
          // so it is mapped back onto the range the parameter declares
          param.value = MathEx.map(value, 0, 100, formatter.min.toDouble(),
              formatter.max.toDouble());
        } else {
          // the other families' cells already carry the value in its own unit:
          // rateHz, delayTimeMs, bipolar and rawCount all decode to the value
          // itself, so nothing is rescaled onto the declared range
          param.value = value;
        }
      }
    }
  }

  /// Reports a parameter cell that is not one of the mapped states, once per
  /// distinct cell, so unmapped parameter kinds can be identified and added.
  void _reportUnmappedCell(
      int block, Processor effect, int paramIndex, List<int> b, int offset) {
    if (!kDebugMode) return;
    if (offset + 4 > b.length) return;
    final cell = b
        .sublist(offset, offset + 4)
        .map((e) => e.toRadixString(16).padLeft(2, "0"))
        .join();
    if (_reportedUnmappedCells.add(cell)) {
      debugPrint('[GP5] unmapped cell $cell at block $block '
          '"${effect.name}" parameter $paramIndex');
    }
  }


  void _parsePatchData1(List<int> b) {
    Gp5Preset preset = device.getPreset(_currentPatch) as Gp5Preset;

    //block enable statuses from bits
    final statuses = <bool>[
      (b[152] & (1 << 0)) != 0,
      (b[152] & (1 << 1)) != 0,
      (b[152] & (1 << 2)) != 0,
      (b[152] & (1 << 3)) != 0,
      (b[151] & (1 << 0)) != 0,
      (b[151] & (1 << 1)) != 0,
      (b[151] & (1 << 2)) != 0,
      (b[151] & (1 << 3)) != 0,
      (b[154] & (1 << 0)) != 0,
      (b[154] & (1 << 1)) != 0,
    ];
    for (int i = 0; i < statuses.length; i++) {
      preset.setSlotEnabled(
          preset.getSlotFromFXID(NuxFXID.fromInt(i))!, statuses[i], false);
    }

    //pre effect id
    var preId = _readEffectId(b, 203);
    var idx = preset.findEffectIndexByHexId(1, preId);
    if (idx >= 0) {
      preset.setSelectedEffectForSlot(
          preset.getSlotFromFXID(NuxFXID.fromInt(1))!, idx, false);
    }
  }

  void _parsePatchData2(List<int> b) {
    Gp5Preset preset = device.getPreset(_currentPatch) as Gp5Preset;

    const offsets = {2: 11, 9: 67, 3: 19, 4: 27, 5: 35, 6: 43, 7: 51, 8: 59};
    offsets.forEach((block, start) {
      var id = _readEffectId(b, start);
      var idx = preset.findEffectIndexByHexId(block, id);
      if (idx >= 0) {
        preset.setSelectedEffectForSlot(
            preset.getSlotFromFXID(NuxFXID.fromInt(block))!, idx, false);
      }
    });
  }

  void _onPatchDataComplete() {
    if (device.selectedChannel != _currentPatch) {
      device.setSelectedChannel(_currentPatch,
          notifyBT: false, sendFullPreset: false, notifyUI: true);
    } else {
      device.deviceControl.forceNotifyListeners();
    }

    if (!_presetsReadyNotified) {
      _presetsReadyNotified = true;
      device.onPresetsReady();
    }

    device.deviceControl.forceNotifyListeners();
    connectionStepReady();
  }
}
