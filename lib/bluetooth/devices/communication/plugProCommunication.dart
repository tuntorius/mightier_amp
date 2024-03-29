import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../NuxDevice.dart';
import '../NuxFXID.dart';
import '../NuxMightySpace.dart';
import '../effects/plug_pro/Cabinet.dart';
import '../features/drumsTone.dart';
import '../features/tuner.dart';
import '../presets/PlugProPreset.dart';

import '../../../platform/simpleSharedPrefs.dart';
import '../NuxConstants.dart';
import '../NuxMightyPlugPro.dart';
import 'communication.dart';

class PlugProCommunication extends DeviceCommunication {
  PlugProCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  StreamController<List<int>>? _bluetoothEQReceived;
  Stream<List<int>>? get bluetoothEQStream => _bluetoothEQReceived?.stream;

  StreamController<List<int>>? _speakerEQReceived;
  Stream<List<int>>? get speakerEQStream => _speakerEQReceived?.stream;

  @override
  get connectionSteps => 6;

  @protected
  int readyPresetsCount = 0;
  @protected
  int readyIRsCount = 0;

  //use this, because when the app sends the order, the amp answers sends it back,
  //however, it must be ignored in this case, but not in other cases.
  //This DateTime is used for that
  DateTime _lastEffectReorder = DateTime.now();

  @override
  NuxPlugProConfiguration get config => super.config as NuxPlugProConfiguration;

  static const int customIRStart = 34;
  static const int customIRsCount = 20;
  static const int irLength = customIRStart + customIRsCount;

  @override
  List<int> createFirmwareMessage() {
    List<int> msg = [];

    //create header
    msg.addAll([
      0x80,
      0x80,
      MidiMessageValues.sysExStart,
      0x43,
      0x58,
      SysexPrivacy.kSYSEX_PUBLIC.toInt(),
      0x80,
      MidiMessageValues.sysExEnd
    ]);

    return msg;
  }

  @override
  void performNextConnectionStep() {
    switch (currentConnectionStep) {
      case 0: //presets
        readyPresetsCount = 0;
        readyIRsCount = 0;
        device.deviceControl.sendBLEData(requestPresetByIndex(0));
        break;
      case 1:
        device.deviceControl.sendBLEData(requestCurrentChannel());
        break;
      case 2:
        device.deviceControl.sendBLEData(requestIRName(customIRStart));
        break;
      case 3:
        device.deviceControl.sendBLEData(_requestSystemSettings());
        break;
      case 4:
        device.deviceControl.sendBLEData(_requestDrumData());
        break;
      case 5:
        device.deviceControl.sendBLEData(_requestMicSettings());
        break;
    }
  }

  @override
  void saveCurrentPreset(int index) {
    var data = createSysExMessagePro(
        SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_SPEC_CMD,
        SyxDir.kSYXDIR_SET,
        [SysCtrlState.syscmd_save, index]);

    device.deviceControl.sendBLEData(data);
  }

  @override
  List<int> requestPresetByIndex(int index) {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_PRESET, SyxDir.kSYXDIR_REQ, [index]);
  }

  @protected
  List<int> requestCurrentChannel() {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_CURPRESET, SyxDir.kSYXDIR_REQ, []);
  }

  List<int> _requestSystemSettings() {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_SYSTEMSET, SyxDir.kSYXDIR_REQ, []);
  }

  @protected
  List<int> requestIRName(int index) {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_CRCNAME, SyxDir.kSYXDIR_REQ, [index]);
  }

  List<int> _requestEffectsOrder() {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_MODULELINK, SyxDir.kSYXDIR_REQ, []);
  }

  List<int> _requestDrumData() {
    return createSysExMessagePro(
        SysexPrivacy.kSYSEX_PRIVATE, SyxMsg.kSYX_DRUM, SyxDir.kSYXDIR_REQ, []);
  }

  List<int> _requestMicSettings() {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_CURSTATE, SyxDir.kSYXDIR_REQ, []);
  }

  void requestBTEQData(int index) {
    if (!device.deviceControl.isConnected) return;
    var data = createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_BTSET, SyxDir.kSYXDIR_REQ, [index]);
    device.deviceControl.sendBLEData(data);
    _bluetoothEQReceived = StreamController<List<int>>();
  }

  void requestSpeakerEQData(int index) {
    if (!device.deviceControl.isConnected) return;
    var data = createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_SPKSET, SyxDir.kSYXDIR_GET, [index]);
    device.deviceControl.sendBLEData(data);
    _speakerEQReceived = StreamController<List<int>>();
  }

  @override
  void requestBatteryStatus() {
    if (!device.batterySupport) return;
    //TODO: Wrong!!!

    // var data = createSysExMessagePro(
    //     SysexPrivacy.kSYSEX_PRIVATE,
    //     SyxMsg.kSYX_SPEC_CMD,
    //     SyxDir.kSYXDIR_REQ,
    //     [SysCtrlState.syscmd_dsprun_battery]);

    var data = createSysExMessage(DeviceMessageID.devSysCtrlMsgID,
        [SysCtrlState.syscmd_dsprun_battery, 0, 0, 0, 0]);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendReset() {
    var data = createSysExMessagePro(
        SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_SPEC_CMD,
        SyxDir.kSYXDIR_SET,
        [SysCtrlState.syscmd_resetall]);

    readyPresetsCount = 0;
    readyIRsCount = 0;
    device.deviceControl.sendBLEData(data);
  }

  void _sendSlotData(int slot, bool enabled, int effectIndex) {
    var preset = device.getPreset(device.selectedChannel);
    var swIndex = preset
        .getEffectsForSlot(slot)[preset.getSelectedEffectForSlot(slot)]
        .midiCCEnableValue;
    preset.getSelectedEffectForSlot(slot);

    int midiVal = effectIndex | (enabled ? 0x00 : 0x40);

    var data = createCCMessage(swIndex, midiVal);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendSlotEnabledState(int slot) {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);

    var effect =
        preset.getEffectsForSlot(slot)[preset.getSelectedEffectForSlot(slot)];
    var index = effect.nuxIndex;

    _sendSlotData(slot, preset.slotEnabled(slot), index);
  }

  void setSlotEffect(int slot, int index) {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    _sendSlotData(slot, preset.slotEnabled(slot), index);
  }

  @override
  void sendActiveChannels(List<bool> channels) {
    if (!device.deviceControl.isConnected) return;
    int channelsBitfield = 0;
    for (int i = 0; i < channels.length; i++) {
      channelsBitfield |= (channels[i] ? 1 : 0) << i;
    }

    var data = createCCMessage(MidiCCValuesPro.PRESETRANGE, channelsBitfield);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendSlotOrder() {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    List<NuxFXID> order = (preset as PlugProPreset).processorAtSlot;

    var nuxOrder = [order.length];
    for (var i = 0; i < order.length; i++) {
      var p = device.getProcessorInfoByFXID(order[i]);
      if (p != null) nuxOrder.add(p.nuxFXID.toInt());
    }
    var data = createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_MODULELINK, SyxDir.kSYXDIR_SET, nuxOrder);
    device.deviceControl.sendBLEData(data);
    _lastEffectReorder = DateTime.now();
  }

  void sendChannelVolume(int value) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.MASTER, value);
    device.deviceControl.sendBLEData(data);
  }

  @override
  List<int> setChannel(int channel) {
    return createPCMessage(channel);
  }

  @override
  void sendDrumsEnabled(bool enabled) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.DRUMENABLE, enabled ? 1 : 0);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendDrumsStyle(int style) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.DRUMTYPE, style);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendDrumsLevel(double volume) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.DRUMLEVEL, volume.round());
    device.deviceControl.sendBLEData(data);
  }

  setDrumsTone(double value, DrumsToneControl control) {
    if (!device.deviceControl.isConnected) return;
    int cc = 0;
    switch (control) {
      case DrumsToneControl.bass:
        cc = MidiCCValuesPro.DRUM_BASS;
        break;
      case DrumsToneControl.middle:
        cc = MidiCCValuesPro.DRUM_MIDDLE;
        break;
      case DrumsToneControl.treble:
        cc = MidiCCValuesPro.DRUM_TREBLE;
        break;
    }
    var data = createCCMessage(cc, value.round());
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendDrumsTempo(double tempo) {
    if (!device.deviceControl.isConnected) return;

    //int tempoNux = (((tempo - 40) / 200) * 16384).floor();
    //these must be sent as 2 7bit values
    int tempoL = tempo.round() & 0x7f;
    int tempoH = (tempo.round() >> 7);

    var data = createSysExMessagePro(
        SysexPrivacy.kSYSEX_PRIVATE, SyxMsg.kSYX_DRUM, SyxDir.kSYXDIR_SET, [
      config.drumsEnabled ? 1 : 0,
      config.selectedDrumStyle,
      config.drumsVolume.round(),
      config.drumsBass.round(),
      config.drumsMiddle.round(),
      config.drumsTreble.round(),
      tempoH,
      tempoL
    ]);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void setEcoMode(bool enable) {}

  //sets eq group
  @override
  void setBTEq(int eq) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.AUXEQENABLE, eq);
    device.deviceControl.sendBLEData(data);
  }

  void saveBTEQGroup(int group) {
    if (!device.deviceControl.isConnected) return;
    var data = createSysExMessagePro(
        SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_SPEC_CMD,
        SyxDir.kSYXDIR_SET,
        [SysCtrlState.speccmd_auxeqsave, group]);

    device.deviceControl.sendBLEData(data);
  }

  void setSpeakerEq(int eq) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.SPK_EQ_GROUP, eq);
    device.deviceControl.sendBLEData(data);
  }

  void saveSpeakerEQGroup(int group) {
    if (!device.deviceControl.isConnected) return;
    var data = createSysExMessagePro(
        SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_SPEC_CMD,
        SyxDir.kSYXDIR_SET,
        [SysCtrlState.speccmd_speakereqsave, group]);

    device.deviceControl.sendBLEData(data);
  }

  void setBTInvert(bool invert) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.AUX_PHASE, invert ? 1 : 0);
    device.deviceControl.sendBLEData(data);
  }

  void setBTMute(bool mute) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.AUX_MUTE, mute ? 1 : 0);
    device.deviceControl.sendBLEData(data);
  }

  void setMicMute(bool mute) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.MICMUTE, mute ? 1 : 0);
    device.deviceControl.sendBLEData(data);
  }

  void setMicLevel(int level) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.MICVOLUME, level);
    device.deviceControl.sendBLEData(data);
  }

  void setMicNoiseGate(bool enable) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.NR_ENABLE, enable ? 1 : 0);
    device.deviceControl.sendBLEData(data);
  }

  void setMicNoiseGateSens(int level) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.NR_SENS, level);
    device.deviceControl.sendBLEData(data);
  }

  void setMicNoiseGateDecay(int level) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.NR_DECAY, level);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void setUsbAudioMode(int mode) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.USBROUNT_3, mode);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void setUsbInputVolume(int vol) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.USBROUNT_1, vol);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void setUsbOutputVolume(int vol) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.USBROUNT_2, vol);
    device.deviceControl.sendBLEData(data);
  }

  void setUsbDryWet(int vol) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.USBROUNT_4, vol);
    device.deviceControl.sendBLEData(data);
  }

  void enableTuner(bool enable) {
    tunerSetSettings(tunerOn: enable);
  }

  void tunerSetSettings({bool tunerOn = true}) {
    if (!device.deviceControl.isConnected) return;
    var data = createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_TUNER_SETTINGS, SyxDir.kSYXDIR_SET, [
      tunerOn ? 1 : 0,
      config.tunerData.mode.mode,
      config.tunerData.referencePitch,
      config.tunerData.muted ? 1 : 0,
      0,
      0,
      0
    ]);

    device.deviceControl.sendBLEData(data);
  }

  void requestTunerSettings() {
    if (!device.deviceControl.isConnected) return;
    var data = createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_TUNER_SETTINGS, SyxDir.kSYXDIR_GET, [0, 0, 0, 0, 0, 0, 0]);

    device.deviceControl.sendBLEData(data);
  }

  void looperRecord() {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.LOOPSTATE, 1);
    device.deviceControl.sendBLEData(data);
  }

  void looperStop() {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.LOOPSTATE, 2);
    device.deviceControl.sendBLEData(data);
  }

  void looperClear() {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.LOOPSTATE, 4);
    device.deviceControl.sendBLEData(data);
  }

  void looperUndoRedo() {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.LOOPSTATE, 8);
    device.deviceControl.sendBLEData(data);
  }

  void looperVolume(int volume) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.LOOPLEVEL, volume);
    device.deviceControl.sendBLEData(data);
  }

  void looperNrAr(bool auto) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValuesPro.LOOP_ARNR, auto ? 1 : 0);
    device.deviceControl.sendBLEData(data);
  }

  void requestLooperSettings() {
    if (!device.deviceControl.isConnected) return;
    var data = createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_LOOP, SyxDir.kSYXDIR_GET, [0, 0, 0, 0, 0, 0, 0, 0]);

    device.deviceControl.sendBLEData(data);
  }

  List<List<int>> _splitPresetData(List<int> data) {
    List<List<int>> presetData = [];
    int pos = 0;

    //sometimes MPPro sends several data pieces in one payload.
    //Let's split it here
    do {
      pos = data.indexOf(SysexPrivacy.kSYSEX_PRIVATE);

      if (pos > 0) {
        var sublist = data.sublist(0, pos - 1);
        presetData.add(sublist);
        if (data.length >= pos + 1) data = data.sublist(pos + 1);
      } else {
        if (data.length > 2) presetData.add(data);
      }
    } while (pos > 0);

    return presetData;
  }

  void _handlePresetDataPiece(List<int> data) {
    List<List<int>> presetData = _splitPresetData(data);

    for (List<int> data in presetData) {
      //remove last 2 bytes if needed
      if (data[data.length - 1] == MidiMessageValues.sysExEnd) {
        data = data.sublist(0, data.length - 2);
      }

      var total = (data[3] & 0xf0) >> 4;
      var current = data[3] & 0x0f;

      debugPrint('preset ${data[2] + 1}, piece ${current + 1} of $total');

      var preset = device.getPreset(data[2]);
      if (current == 0) preset.resetNuxData();

      preset.addNuxPayloadPiece(data.sublist(4), current, total);

      if (preset.payloadPiecesReady()) {
        preset.setupPresetFromNuxData();
        if (!device.nuxPresetsReceived) {
          readyPresetsCount++;

          if (readyPresetsCount == device.channelsCount) {
            device.onPresetsReady();
            debugPrint("Presets connection step ready");
            connectionStepReady();
          } else {
            device.deviceControl.sendBLEData(requestPresetByIndex(data[2] + 1));
          }
        }
      }
    }
  }

  void _handleIRName(List<int> data) {
    if (data.length > 8) {
      int index = data[1];
      bool hasIR = data[data.length - 3] != 0;
      int stringEnd = 0;

      //find name length
      for (int i = 8; i < data.length - 1; i++) {
        if (data[i] == 0 && data[i + 1] == 0) {
          stringEnd = i;
          break;
        }
      }
      if (stringEnd < 8) stringEnd = data.length - 3;

      if (hasIR) {
        List<int> encodedName = data.sublist(8, stringEnd);
        List<int> decodedName = [];
        for (int i = 0; i < encodedName.length; i++) {
          if (i % 3 == 0) {
            decodedName.add((encodedName[i] & 0x01) << 6);
          } else if (i % 3 == 1) {
            decodedName.last |= encodedName[i] >> 1;
          } else if (i % 3 == 2) {
            decodedName.add(encodedName[i]);
          }
        }
        var decoder = const AsciiDecoder();
        String name = decoder.convert(decodedName);
        debugPrint("IR $index, active: $hasIR, name: $name");

        for (var preset in device.presets) {
          if (preset.cabinetList == null) continue;
          if (index >= preset.cabinetList!.length) break;
          var cab = preset.cabinetList![index];
          if (cab is UserCab) {
            cab.setName(name);
          }
        }
      } else {
        debugPrint("IR $index, active: $hasIR}");
      }
    }
    readyIRsCount++;

    if (readyIRsCount == customIRsCount) {
      debugPrint("IR names connection step ready");
      connectionStepReady();
    } else {
      device.deviceControl
          .sendBLEData(requestIRName(customIRStart + readyIRsCount));
    }
  }

  bool _handleEffectsOrderData(List<int> data) {
    var dt = DateTime.now();
    if (dt.difference(_lastEffectReorder).inMilliseconds < 3000) {
      return true;
    }

    if (data[0] == SyxDir.kSYXDIR_REQ) {
      var len = data[1];
      var preset = device.getPreset(device.selectedChannel);

      List<NuxFXID> order = (preset as PlugProPreset).processorAtSlot;
      order.clear();
      data.sublist(2, 2 + len).forEach((element) {
        order.add(NuxFXID.fromInt(element));
      });
      device.deviceControl.forceNotifyListeners();
      return true;
    }
    return false;
  }

  bool _handleFirmwareData(List<int> data) {
    //check for firmware message
    if (data[2] == MidiMessageValues.sysExStart &&
        data[3] == 67 &&
        data[5] == SysexPrivacy.kSYSEX_PUBLICREPLY.toInt()) {
      //the actual version starts at byte 9 and is 8 byte string
      //containing the date of the build
      //for now it's not needed
      device.setFirmwareVersion(0);

      //get FW version date of MPPro
      var versionArray = data.sublist(6, 14);
      String asciiString = String.fromCharCodes(versionArray);
      (device as NuxMightyPlugPro).setVersionDate(asciiString);

      //save device version since we know it already
      SharedPrefs().setValue(SettingsKeys.deviceVersion, device.productVersion);

      device.deviceControl.onFirmwareVersionReady();
      return true;
    }
    return false;
  }

  bool _handleDrumCCData(int control, int value) {
    bool consumed = false;
    switch (control) {
      case MidiCCValuesPro.DRUMENABLE:
        config.drumsEnabled = value != 0;
        consumed = true;
        break;
      case MidiCCValuesPro.DRUMLEVEL:
        config.drumsVolume = value.toDouble();
        consumed = true;
        break;
      case MidiCCValuesPro.DRUMTYPE:
        config.selectedDrumStyle = value;
        consumed = true;
        break;
      case MidiCCValuesPro.DRUM_BASS:
        config.drumsBass = value.toDouble();
        consumed = true;
        break;
      case MidiCCValuesPro.DRUM_MIDDLE:
        config.drumsMiddle = value.toDouble();
        consumed = true;
        break;
      case MidiCCValuesPro.DRUM_TREBLE:
        config.drumsTreble = value.toDouble();
        consumed = true;
        break;
    }
    if (consumed) {
      device.deviceControl.forceNotifyListeners();
      return true;
    }
    return false;
  }

  void _handleActiveChannelsData(int bitfield) {
    for (int i = 0; i < config.activeChannels.length; i++) {
      config.activeChannels[i] = ((bitfield >> i) & 1) != 0;
    }
    device.deviceControl.forceNotifyListeners();
  }

  void _handleVolumeData(int vol) {
    (device.presets[device.selectedChannel] as PlugProPreset).setVolumeRaw(vol);
    device.deviceControl.forceNotifyListeners();
  }

  void _handleLooperState(int state) {
    config.looperData.loopState = state & 0x0f;
    config.looperData.loopUndoState = (state >> 4) & 0x03;
    config.looperData.loopHasAudio = (state >> 6) & 0x01 != 0;
  }

  void _handleLooperCC(int ccNumber, int value) {
    switch (ccNumber) {
      case MidiCCValuesPro.LOOPLEVEL:
        config.looperData.loopLevel = value.toDouble();
        break;
      case MidiCCValuesPro.LOOPSTATE:
        _handleLooperState(value);
        break;
      case MidiCCValuesPro.LOOP_ARNR:
        config.looperData.loopRecordMode = value;
        break;
    }
    (device as NuxMightySpace).notifyLooperListeners();
  }

  void _handleLooperSysEx(List<int> data) {
    if (data[0] != 2) return;
    config.looperData.loopLevel = data[1].toDouble();
    _handleLooperState(data[2]);
    config.looperData.loopRecordMode = data[3];
    (device as NuxMightySpace).notifyLooperListeners();
  }

  void _handleTuner(int ccNumber, int value) {
    var tuner = device as Tuner;

    if (ccNumber == tuner.tunerStateCC) {
      config.tunerData.enabled = value == 1;
    } else if (ccNumber == tuner.tunerNoteCC) {
      config.tunerData.note = value;
    } else if (ccNumber == tuner.tunerPitchCC) {
      config.tunerData.cents = value;
    } else if (ccNumber == tuner.tunerStringCC) {
      config.tunerData.stringNumber = value;
    }
    tuner.notifyTunerListeners();
  }

  void _handleTunerSysEx(List<int> data) {
    if (data[0] != 2) return;
    config.tunerData.mode = TunerMode.getByMode(data[2]) ?? TunerMode.chromatic;
    config.tunerData.referencePitch = data[3];
    config.tunerData.muted = data[4] == 1;
    (device as Tuner).notifyTunerListeners();
  }

  //Info: in plugProDataObject.js in the beginning there are few const enums
  // O, G, z, etc... they are the indexes of some SysEx data
  //just reduce with 1
  /*
  const G = {
  micmute: 0,
  outmodeeq1: 1,
  outmodeeq2: 2,
  outmodeeq3: 3,
  display1: 4,
  display2: 5,
  display3: 6,
  expset1: 7,
  expset2: 8,
  expset3: 9,
  expset4: 10,
  preeq1: 11,
  preeq2: 12,
  preeq3: 13,
  preeq4: 14,
  usbrount1: 15,
  usbrount2: 16,
  usbrount3: 17,
  usbrount4: 18,
  presetrange: 19,
  micvolume: 20,
  midi_chan: 21,
  length: 22,
};
*/
  void _handleSystemSettings(List<int> data) {
    config.micMute = data[1] > 0;
    config.routingMode = data[18];
    config.recLevel = data[16];
    config.playbackLevel = data[17];
    config.usbDryWet = data[19];
    config.micVolume = data[21];
    for (int i = 0; i < config.activeChannels.length; i++) {
      config.activeChannels[i] = ((data[20] >> i) & 1) != 0;
    }
  }

/*
const z = {
  drum_command: 0,
  drumtype: 1,
  drum_vol: 2,
  drumeqL: 3,
  drumeqM: 4,
  drumeqH: 5,
  tmpoH: 6,
  tmpoL: 7,
  length: 8,
};
*/
  void _handleDrumData(List<int> data) {
    if (data[0] == SyxDir.kSYXDIR_REQ && data.length >= 8) {
      config.drumsEnabled = data[1] != 0;
      config.selectedDrumStyle = data[2];
      config.drumsVolume = data[3].toDouble();
      config.drumsBass = data[4].toDouble();
      config.drumsMiddle = data[5].toDouble();
      config.drumsTreble = data[6].toDouble();

      config.drumsTempo = (data[8] + (data[7] << 7)).toDouble();
      if (!isConnectionReady()) {
        debugPrint("Drums connection step ready");
        connectionStepReady();
      } else {
        device.deviceControl.forceNotifyListeners();
      }
    }
  }

  void _handleMicSettings(List<int> data) {
    if (data[0] == SyxDir.kSYXDIR_REQ) {
      config.bluetoothGroup = data[2];
      config.micNoiseGate = data[3] > 0;
      config.micNGSensitivity = data[4];
      config.micNGDecay = data[5];

      if (config is NuxMightySpaceConfiguration) {
        (config as NuxMightySpaceConfiguration).speakerEQGroup = data[6];
      }

      debugPrint("Mic step ready");
      connectionStepReady();
    }
  }

  void _handleBTEqData(List<int> data) {
    if (data[0] == SyxDir.kSYXDIR_REQ) {
      _bluetoothEQReceived?.add(data.sublist(2));
      _bluetoothEQReceived?.close();
    }
  }

  void _handleSpeakerEqData(List<int> data) {
    if (data[0] == SyxDir.kSYXDIR_REQ) {
      _speakerEQReceived?.add(data.sublist(2));
      _speakerEQReceived?.close();
      _speakerEQReceived = null;
    }
  }

//Some discovered stuff
//kSYX_SYSTEMSET - for ACTIVE channels, mic stuff and USB stuff

  @override
  void onDataReceive(List<int> data) {
    if (data.length > 2) {
      switch (data[2]) {
        case MidiMessageValues.controlChange:
          switch (data[3]) {
            case MidiCCValuesPro.PRESETRANGE:
              _handleActiveChannelsData(data[4]);
              return;
            case MidiCCValuesPro.MASTER:
              _handleVolumeData(data[4]);
              break;
            case MidiCCValuesPro.TUNER_State:
            case MidiCCValuesPro.TUNER_Note:
            case MidiCCValuesPro.TUNER_Number:
            case MidiCCValuesPro.TUNER_Cent:
            case MidiCCValuesPro.TunerLiteMK2_Cent:
            case MidiCCValuesPro.TunerLiteMK2_Note:
            case MidiCCValuesPro.TunerLiteMK2_Number:
            case MidiCCValuesPro.TunerLiteMK2_State:
              _handleTuner(data[3], data[4]);
              break;
            case MidiCCValuesPro.LOOPLEVEL:
            case MidiCCValuesPro.LOOPSTATE:
            case MidiCCValuesPro.LOOP_ARNR:
              _handleLooperCC(data[3], data[4]);
          }
          bool consumed = false;
          consumed = _handleDrumCCData(data[3], data[4]);
          if (consumed) return;
          break;
        case MidiMessageValues.sysExStart:
          switch (data[5]) {
            case SysexPrivacy.kSYSEX_PUBLICREPLY:
              if (_handleFirmwareData(data)) return;
              break;
            case SysexPrivacy.kSYSEX_PRIVATE:
              switch (data[6]) {
                case SyxMsg.kSYX_PRESET:
                  _handlePresetDataPiece(data.sublist(6));
                  return;
                case SyxMsg.kSYX_CRCNAME:
                  _handleIRName(data.sublist(7));
                  return;
                case SyxMsg.kSYX_SYSTEMSET:
                  _handleSystemSettings(data.sublist(7));
                  connectionStepReady();
                  return;
                case SyxMsg.kSYX_CURPRESET:

                  //current preset is sent 3 times, check it's the 3rd time
                  //to proceed with connection
                  if (data[9] == 0x32) {
                    device.setSelectedChannel(data[8],
                        notifyBT: false, notifyUI: true, sendFullPreset: false);
                    debugPrint("Current preset connection step ready");
                    connectionStepReady();
                  }
                  return;
                case SyxMsg.kSYX_MODULELINK:
                  if (_handleEffectsOrderData(data.sublist(7))) return;
                  break;
                case SyxMsg.kSYX_DRUM:
                  _handleDrumData(data.sublist(7));
                  return;
                case SyxMsg.kSYX_CURSTATE:
                  _handleMicSettings(data.sublist(7));
                  return;
                case SyxMsg.kSYX_BTSET:
                  _handleBTEqData(data.sublist(7));
                  return;
                case SyxMsg.kSYX_SPKSET:
                  _handleSpeakerEqData(data.sublist(7));
                  return;
                case SyxMsg.kSYX_TUNER_SETTINGS:
                  _handleTunerSysEx(data.sublist(7));
                  return;
                case SyxMsg.kSYX_LOOP:
                  _handleLooperSysEx(data.sublist(7));
                  return;
                case SyxMsg.kSYX_SENDCMD:
                  if (data[7] == SyxDir.kSYXDIR_REQ) {
                    switch (data[8]) {
                      case SyxMsg.kSYX_MODULELINK:
                        device.deviceControl
                            .sendBLEData(_requestEffectsOrder());
                        break;
                      case SyxMsg.kSYX_DRUM:
                        //request drums data
                        device.deviceControl.sendBLEData(_requestDrumData());
                        break;
                    }
                  }
                  return;
              }
              break;
          }
          break;
      }
      device.onDataReceived(data.sublist(2));
    }
  }

  @override
  void onDisconnect() {
    super.onDisconnect();
    readyPresetsCount = 0;
    readyIRsCount = 0;
  }
}
