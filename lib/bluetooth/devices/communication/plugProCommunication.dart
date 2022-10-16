import 'dart:convert';

import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/plug_pro/Cabinet.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/PlugProPreset.dart';

import '../../../platform/simpleSharedPrefs.dart';
import '../NuxConstants.dart';
import 'communication.dart';

class PlugProCommunication extends DeviceCommunication {
  PlugProCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  @override
  int get productVID => 48;

  @override
  get connectionSteps => 3;

  int _readyPresetsCount = 0;
  int _readyIRsCount = 0;

  static const int CustomIRStart = 34;
  static const int CustomIRsCount = 20;
  static const int IRLength = CustomIRStart + CustomIRsCount;

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

  void performNextConnectionStep() {
    switch (currentConnectionStep) {
      case 0: //presets
        device.deviceControl.sendBLEData(requestPresetByIndex(0));
        break;
      case 1: //IR names
        device.deviceControl.sendBLEData(requestIRName(CustomIRStart));
        break;
      case 2:
        device.deviceControl.sendBLEData(requestCurrentChannel());
        break;
    }
  }

  void saveCurrentPreset() {
    var data = createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_SPEC_CMD, SyxDir.kSYXDIR_SET, [SysCtrlState.syscmd_save]);

    device.deviceControl.sendBLEData(data);
  }

  List<int> requestPresetByIndex(int index) {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_PRESET, SyxDir.kSYXDIR_REQ, [index]);
  }

  List<int> requestIRName(int index) {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_CABNAME, SyxDir.kSYXDIR_REQ, [index]);
  }

  List<int> requestCurrentChannel() {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_CURPRESET, SyxDir.kSYXDIR_REQ, []);
  }

  void requestBatteryStatus() {
    if (!device.batterySupport) return;
    //TODO: Wrong!!!
    var data = createSysExMessage(DeviceMessageID.devSysCtrlMsgID,
        [SysCtrlState.syscmd_dsprun_battery, 0, 0, 0, 0]);
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

  void sendSlotEnabledState(int slot) {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    _sendSlotData(
        slot, preset.slotEnabled(slot), preset.getSelectedEffectForSlot(slot));
  }

  void setSlotEffect(int slot, int index) {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    _sendSlotData(slot, preset.slotEnabled(slot), index);
  }

  void sendSlotOrder() {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    var order = (preset as PlugProPreset).processorAtSlot;

    var nuxOrder = [order.length];
    for (var i = 0; i < order.length; i++)
      nuxOrder.add(device.processorList[order[i]].nuxOrderIndex);

    var data = createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_MODULELINK, SyxDir.kSYXDIR_SET, nuxOrder);
    device.deviceControl.sendBLEData(data);
  }

  List<int> setChannel(int channel) {
    return createPCMessage(channel);
  }

  void sendDrumsEnabled(bool enabled) {}
  void sendDrumsStyle(int style) {}
  void sendDrumsLevel(double volume) {}
  void sendDrumsTempo(double tempo) {}
  void setEcoMode(bool enable) {}
  void setBTEq(int eq) {}
  void setUsbAudioMode(int mode) {}
  void setUsbInputVolume(int vol) {}
  void setUsbOutputVolume(int vol) {}

  List<List<int>> _splitPresetData(List<int> data) {
    List<List<int>> presetData = [];
    int pos = 0;

    //sometimes MPPro sends several data pieces in one payload.
    //Let's split it here
    do {
      pos = data.firstWhere((element) => element == SysexPrivacy.kSYSEX_PRIVATE,
          orElse: () => -1);

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

    for (List<int> _data in presetData) {
      //remove last 2 bytes if needed
      if (_data[_data.length - 1] == MidiMessageValues.sysExEnd) {
        _data = _data.sublist(0, _data.length - 2);
      }

      var total = (_data[3] & 0xf0) >> 4;
      var current = _data[3] & 0x0f;

      print('preset ${_data[2] + 1}, piece ${current + 1} of $total');

      var preset = device.getPreset(_data[2]);
      if (current == 0) preset.resetNuxData();

      preset.addNuxPayloadPiece(_data.sublist(4), current, total);

      if (preset.payloadPiecesReady()) {
        preset.setupPresetFromNuxData();
        if (!device.nuxPresetsReceived) {
          _readyPresetsCount++;

          if (_readyPresetsCount == device.channelsCount) {
            device.onPresetsReady();
            connectionStepReady();
          } else {
            device.deviceControl
                .sendBLEData(requestPresetByIndex(_data[2] + 1));
          }
        }
      }
    }
  }

  void _handleIRName(List<int> data) {
    int index = data[1];
    bool hasIR = data[2] != 0;
    var decoder = AsciiDecoder();
    String name = decoder.convert(data.sublist(6, 17));
    print("IR $index, active: $hasIR, name: $name");

    for (var preset in device.presets) {
      PlugProPreset proPreset = preset as PlugProPreset;
      var cab = proPreset.cabinetList[index];
      if (cab is UserCab) {
        cab.setName(name);
        cab.setActive(hasIR);
      }
    }
    _readyIRsCount++;

    if (_readyIRsCount == CustomIRsCount)
      connectionStepReady();
    else
      device.deviceControl
          .sendBLEData(requestIRName(CustomIRStart + _readyIRsCount));
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
      //save device version since we know it already
      SharedPrefs().setValue(SettingsKeys.deviceVersion, device.productVersion);

      device.deviceControl.onFirmwareVersionReady();
      return true;
    }
    return false;
  }

//Some discovered stuff
//kSYX_SYSTEMSET - for ACTIVE channels, mic stuff and USB stuff

  void onDataReceive(List<int> data) {
    if (data.length > 2) {
      switch (data[2]) {
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
                case SyxMsg.kSYX_CABNAME:
                  _handleIRName(data.sublist(7));
                  return;
                case SyxMsg.kSYX_CURPRESET:
                  device.setSelectedChannelNuxIndex(data[8], false);
                  connectionStepReady();
                  return;
              }
              break;
          }
          break;
      }
      device.onDataReceived(data.sublist(2));
    }
  }

  void onDisconnect() {
    super.onDisconnect();
    _readyPresetsCount = 0;
    _readyIRsCount = 0;
  }
}
