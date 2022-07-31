import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';

import '../../../platform/simpleSharedPrefs.dart';
import '../NuxConstants.dart';
import 'communication.dart';

class PlugProCommunication extends DeviceCommunication {
  PlugProCommunication(NuxDevice device) : super(device);

  @override
  int get productVID => 48;

  List<int> createFirmwareMessage() {
    List<int> msg = [];

    //create header
    msg.addAll([
      0x80,
      0x80,
      MidiMessageValues.sysExStart,
      0x43,
      0x58,
      SysexPrivacy.kSYSEX_PUBLIC.toInt()
    ]);

    //add termination symbol
    msg.add(0x80);
    msg.add(MidiMessageValues.sysExEnd);

    //TODO:
    return [];
    //msg;
  }

  void requestPrimaryData() {
    for (int i = 0; i < device.channelsCount; i++)
      device.deviceControl.sendBLEData(requestPresetByIndex(i));

    device.deviceControl.onPrimaryDataReady();
  }

  void requestSecondaryData() {
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

  void onDataReceive(List<int> data) {
    if (data.length > 2) {
      //check for firmware message
      if (data[2] == MidiMessageValues.sysExStart &&
          data[3] == 0 &&
          data[8] == 16 &&
          data.length == 12) {
        //firmware version is in the 9th bit
        device.setFirmwareVersion(data[9]);
        //save device version since we know it already
        SharedPrefs()
            .setValue(SettingsKeys.deviceVersion, device.productVersion);

        device.deviceControl.onFirmwareVersionReady();
      } else
        device.onDataReceived(data.sublist(2));
    }
  }

  void onDisconnect() {}
}
