import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';

import '../NuxConstants.dart';
import 'communication.dart';

class LiteCommunication extends DeviceCommunication {
  LiteCommunication(NuxDevice _device, NuxDeviceConfiguration _config)
      : super(_device, _config);

  @override
  int get productVID => 48;

  @override
  int get connectionSteps => 1;

  @override
  List<int> createFirmwareMessage() {
    return [];
  }

  List<int> requestPresetByIndex(int index) {
    return [];
  }

  List<int> requestIRName(int index) {
    return [];
  }

  List<int> setChannel(int channel) {
    return createCCMessage(device.channelChangeCC, channel);
  }

  void requestBatteryStatus() {
    if (!device.batterySupport) return;
    var data = createSysExMessage(DeviceMessageID.devSysCtrlMsgID,
        [SysCtrlState.syscmd_dsprun_battery, 0, 0, 0, 0]);
    device.deviceControl.sendBLEData(data);
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
    device.onDataReceived(data.sublist(2));
  }

  void onDisconnect() {
    super.onDisconnect();
  }

  void performNextConnectionStep() {
    connectionStepReady();
    device.selectedChannelNormalized = 0;
    device.deviceControl.changeDevicePreset(0);
    device.deviceControl.sendFullPresetSettings();
  }

  // void requestPrimaryData() {
  //   device.deviceControl.onPrimaryDataReady();
  // }

  // requestSecondaryData() {
  //   device.deviceControl.deviceConnectionReady();

  //   device.selectedChannelNormalized = 0;
  //   device.deviceControl.changeDevicePreset(0);
  //   device.deviceControl.sendFullPresetSettings();
  //   device.deviceControl.deviceConnectionReady();
  // }
}
