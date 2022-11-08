import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';

import '../NuxConstants.dart';
import 'communication.dart';

class LiteCommunication extends DeviceCommunication {
  LiteCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  @override
  int get productVID => 48;

  @override
  int get connectionSteps => 1;

  @override
  List<int> createFirmwareMessage() {
    return [];
  }

  @override
  List<int> requestPresetByIndex(int index) {
    return [];
  }

  @override
  List<int> setChannel(int channel) {
    return createCCMessage(device.channelChangeCC, channel);
  }

  @override
  void requestBatteryStatus() {
    if (!device.batterySupport) return;
    var data = createSysExMessage(DeviceMessageID.devSysCtrlMsgID,
        [SysCtrlState.syscmd_dsprun_battery, 0, 0, 0, 0]);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendReset() {
    var data = createCCMessage(MidiCCValues.bCC_CtrlCmd, 0x7f);
    device.deviceControl.sendBLEData(data);
  }

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
  void saveCurrentPreset() {}

  @override
  void onDataReceive(List<int> data) {
    device.onDataReceived(data.sublist(2));
  }

  @override
  void performNextConnectionStep() {
    connectionStepReady();
    device.selectedChannelNormalized = 0;
    device.deviceControl.changeDevicePreset(0);
    device.deviceControl.sendFullPresetSettings();
  }
}
