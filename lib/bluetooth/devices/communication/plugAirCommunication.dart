import '../NuxMightyPlugAir.dart';
import '../../../platform/simpleSharedPrefs.dart';
import '../NuxDevice.dart';
import '../NuxConstants.dart';
import 'communication.dart';

class PlugAirCommunication extends DeviceCommunication {
  PlugAirCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  @override
  int get productVID => 48;

  @override
  int get connectionSteps => 3;

  int _readyPresetsCount = 0;

  @override
  NuxMightyPlugConfiguration get config =>
      super.config as NuxMightyPlugConfiguration;

  @override
  List<int> createFirmwareMessage() {
    List<int> msg = [];

    //create header
    msg.addAll([
      0x80,
      0x80,
      MidiMessageValues.sysExStart,
      0,
      vendorID & 255,
      vendorID >> 8 & 255,
      productVID & 255,
      productVID >> 8 & 255,
      0
    ]);

    //add termination symbol
    msg.add(0x80);
    msg.add(MidiMessageValues.sysExEnd);

    return msg;
  }

  @override
  void performNextConnectionStep() {
    switch (currentConnectionStep) {
      case 0:
        _readyPresetsCount = 0;
        device.deviceControl.sendBLEData(requestPresetByIndex(0));
        break;
      case 1: //eco mode and other
        var message = createSysExMessage(DeviceMessageID.devReqManuMsgID, [0]);
        device.deviceControl.sendBLEData(message);
        break;
      case 2: //usb settings
        var message = createSysExMessage(DeviceMessageID.devSysCtrlMsgID,
            [SysCtrlState.syscmd_usbaudio, 0, 0, 0, 0]);
        device.deviceControl.sendBLEData(message);
        break;
    }
  }

  @override
  void saveCurrentPreset(int index) {
    var data = createCCMessage(MidiCCValues.bCC_CtrlCmd, 0x7e);
    device.deviceControl.sendBLEData(data);
  }

  @override
  List<int> requestPresetByIndex(int index) {
    return createSysExMessage(DeviceMessageID.devReqPresetMsgID, index);
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

    _readyPresetsCount = 0;
  }

  @override
  List<int> setChannel(int channel) {
    return createCCMessage(device.channelChangeCC, channel);
  }

  //*************/
  //Drums section
  //*************/
  @override
  void sendDrumsEnabled(bool enabled) {
    if (!device.deviceControl.isConnected) return;
    var data =
        createCCMessage(MidiCCValues.bCC_drumOnOff_No, enabled ? 0x7f : 0);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendDrumsStyle(int style) {
    if (!device.deviceControl.isConnected) return;
    var data = createCCMessage(MidiCCValues.bCC_drumType_No, style);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendDrumsLevel(double volume) {
    if (!device.deviceControl.isConnected) return;
    int val = percentageTo7Bit(volume);
    var data = createCCMessage(MidiCCValues.bCC_drumLevel_No, val);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void sendDrumsTempo(double tempo) {
    if (!device.deviceControl.isConnected) return;

    int tempoNux = (((tempo - 40) / 200) * 16384).floor();
    //these must be sent as 2 7bit values
    int tempoL = tempoNux & 0x7f;
    int tempoH = (tempoNux >> 7);

    //no idea what the first 2 messages are for
    var data = createCCMessage(MidiCCValues.bCC_drumTempo1, 0x06);
    device.deviceControl.sendBLEData(data);
    data = createCCMessage(MidiCCValues.bCC_drumTempo2, 0x26);
    device.deviceControl.sendBLEData(data);
    data = createCCMessage(MidiCCValues.bCC_drumTempoH, tempoH);
    device.deviceControl.sendBLEData(data);
    data = createCCMessage(MidiCCValues.bCC_drumTempoL, tempoL);
    device.deviceControl.sendBLEData(data);
  }

  //***************/
  //Settings section
  //***************/
  @override
  void setEcoMode(bool enable) {
    var data = createSysExMessage(DeviceMessageID.devSysCtrlMsgID,
        [SysCtrlState.syscmd_eco_pro, enable ? 1 : 0, 0, 0, 0]);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void setBTEq(int eq) {
    var data = createSysExMessage(
        DeviceMessageID.devSysCtrlMsgID, [SysCtrlState.syscmd_bt, 1, eq, 0, 0]);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void setUsbAudioMode(int mode) {
    var data = createCCMessage(MidiCCValues.bCC_VolumePedalMin, mode);
    device.deviceControl.sendBLEData(data);
  }

  @override
  void setUsbInputVolume(int vol) {
    var data = createCCMessage(
        MidiCCValues.bCC_VolumePedal, percentageTo7Bit(vol.toDouble()));
    device.deviceControl.sendBLEData(data);
  }

  @override
  void setUsbOutputVolume(int vol) {
    var data = createCCMessage(
        MidiCCValues.bCC_VolumePrePost, percentageTo7Bit(vol.toDouble()));
    device.deviceControl.sendBLEData(data);
  }

  void _handlePresetDataPiece(List<int> data) {
    var total = (data[3] & 0xf0) >> 4;
    var current = data[3] & 0x0f;

    var preset = device.getPreset(data[2]);
    if (current == 0) preset.resetNuxData();

    preset.addNuxPayloadPiece(data.sublist(4, 16), current, total);

    if (preset.payloadPiecesReady()) {
      preset.setupPresetFromNuxData();
      if (!device.nuxPresetsReceived) {
        _readyPresetsCount++;

        if (_readyPresetsCount == device.channelsCount) {
          device.onPresetsReady();
          connectionStepReady();
        } else {
          device.deviceControl.sendBLEData(requestPresetByIndex(data[2] + 1));
        }
      }
    }
  }

  bool _handleFirmwareData(List<int> data) {
    if (data[8] == 16 && data.length == 12) {
      //firmware version is in the 9th bit
      device.setFirmwareVersion(data[9]);
      //save device version since we know it already
      SharedPrefs().setValue(SettingsKeys.deviceVersion, device.productVersion);

      device.deviceControl.onFirmwareVersionReady();
      return true;
    }
    return false;
  }

  void _handleBTEcoMode(List<int> data) {
    //this has lots of unknown values - maybe bpm settings
    //eco mode is 12
    if (data[data.length - 1] == MidiMessageValues.sysExEnd) {
      //current preset is located here
      device.setSelectedChannel(data[4],
          notifyBT: false, notifyUI: false, sendFullPreset: false);
      config.btEq = data[10];
      config.ecoMode = data[12] != 0;
      connectionStepReady();
    }
  }

  void _handleUSBConfig(List<int> data) {
    config.usbMode = data[9];
    config.inputVol = data[10];
    config.outputVol = data[11];
    connectionStepReady();
  }

  @override
  void onDataReceive(List<int> data) {
    if (data.length > 3) {
      switch (data[2] & 0xf0) {
        case MidiMessageValues.sysExStart:
          switch (data[3]) {
            case DeviceMessageID.devReqFwID:
              if (data[9] == DeviceMessageID.devSysCtrlMsgID &&
                  data[10] == SysCtrlState.syscmd_usbaudio) {
                _handleUSBConfig(data.sublist(2));
              } else if (_handleFirmwareData(data)) {
                return;
              }
              break;
            case DeviceMessageID.devGetManuMsgID:
              _handleBTEcoMode(data.sublist(2));
              break;
            case DeviceMessageID.devGetPresetMsgID:
              _handlePresetDataPiece(data.sublist(2));
              return;
          }
          break;
      }
      device.onDataReceived(data.sublist(2));
    }
  }

  @override
  void onDisconnect() {
    super.onDisconnect();
    _readyPresetsCount = 0;
  }
}
