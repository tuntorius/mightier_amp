import 'package:mighty_plug_manager/bluetooth/devices/communication/plugProCommunication.dart';
import '../NuxDevice.dart';

class LiteMk2Communication extends PlugProCommunication {
  LiteMk2Communication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  @override
  get connectionSteps => 3;

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
        device.deviceControl
            .sendBLEData(requestIRName(PlugProCommunication.customIRStart));
        break;
      /*case 3:
        device.deviceControl.sendBLEData(_requestSystemSettings());
        break;
      case 4:
        device.deviceControl.sendBLEData(_requestDrumData());
        break;
      case 5:
        device.deviceControl.sendBLEData(_requestMicSettings());
        break;*/
    }
  }

  @override
  List<int> createFirmwareMessage() {
    return [];
  }
}
