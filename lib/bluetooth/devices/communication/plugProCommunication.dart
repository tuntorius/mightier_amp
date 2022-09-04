import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/PlugProPreset.dart';

import '../../../platform/simpleSharedPrefs.dart';
import '../NuxConstants.dart';
import 'communication.dart';

class PlugProCommunication extends DeviceCommunication {
  PlugProCommunication(NuxDevice device) : super(device);

  @override
  int get productVID => 48;

  int _readyPresetsCount = 0;

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

  void requestPrimaryData() {
    print("Requesting primary data");
    //for (int i = 0; i < device.channelsCount; i++)
    //  device.deviceControl.sendBLEData(requestPresetByIndex(i));

    device.deviceControl.sendBLEData(requestPresetByIndex(0));
  }

  void requestSecondaryData() {
    print("Requesting secondary data");
    device.deviceControl.deviceConnectionReady();
  }

  List<int> requestPresetByIndex(int index) {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_PRESET, SyxDir.kSYXDIR_REQ, [index]);
  }

  List<int> requestIRName(int index) {
    return createSysExMessagePro(SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_CABNAME, SyxDir.kSYXDIR_REQ, [index]);
  }

  void requestBatteryStatus() {
    if (!device.batterySupport) return;
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
            device.deviceControl.onPrimaryDataReady();
          } else {
            device.deviceControl
                .sendBLEData(requestPresetByIndex(_data[2] + 1));
          }
        }
      }
    }
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
              }
              break;
          }
          break;
      }
      device.onDataReceived(data.sublist(2));
    }
  }

  void onDisconnect() {
    _readyPresetsCount = 0;
  }
}
