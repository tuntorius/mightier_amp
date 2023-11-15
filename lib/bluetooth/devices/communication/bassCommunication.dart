import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';

import '../NuxConstants.dart';
import 'communication.dart';

class BassCommunication extends DeviceCommunication {
  BassCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  @override
  int get connectionSteps => 1;

  int _readyPresetsCount = 0;

  static const int customIRStart = 8;
  static const int customIRsCount = 8;
  static const int irLength = customIRStart + customIRsCount;

  @override
  void performNextConnectionStep() {
    switch (currentConnectionStep) {
      case 0:
        _readyPresetsCount = 0;

        //requestAllPresets();
        break;
    }
    connectionStepReady();
  }

  void requestAllPresets() async {
    for (int i = 0; i < device.channelsCount; i++) {
      device.deviceControl.sendBLEData(requestPresetByIndex(i));
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  List<int> createFirmwareMessage() {
    return [];
  }

  @override
  List<int> requestPresetByIndex(int index) {
    return createSysExMessage(DeviceMessageID.devReqPresetMsgID, index);
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

    _readyPresetsCount = 0;
  }

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
  void saveCurrentPreset(int index) {
    var data = createCCMessage(MidiCCValues.bCC_CtrlCmd, 0x7e);
    device.deviceControl.sendBLEData(data);
  }

  void _handlePresetDataPiece(List<int> data) {
    var total = (data[3] & 0xf0) >> 4;
    var current = data[3] & 0x0f;

    print('preset ${data[2] + 1}, piece ${current + 1} of $total');
    print(data);

    var preset = device.getPreset(data[2]);
    if (current == 0) preset.resetNuxData();

    preset.addNuxPayloadPiece(data.sublist(4, data.length - 2), current, total);

    if (preset.payloadPiecesReady()) {
      preset.setupPresetFromNuxData();
      if (!device.nuxPresetsReceived) {
        _readyPresetsCount++;

        if (_readyPresetsCount == device.channelsCount) {
          device.onPresetsReady();
          device.deviceControl.forceNotifyListeners();
          //connectionStepReady();
        } else {
          //device.deviceControl.sendBLEData(requestPresetByIndex(data[2] + 1));
        }
      } else {
        device.deviceControl.forceNotifyListeners();
      }
    }
  }

  @override
  void onDataReceive(List<int> data) {
    if (data.length < 3) return;

    switch (data[2] & 0xf0) {
      case MidiMessageValues.sysExStart:
        switch (data[3]) {
          case DeviceMessageID.devGetPresetMsgID:
            _handlePresetDataPiece(data.sublist(2));
            return;
        }
        break;
    }

    device.onDataReceived(data.sublist(2));
  }

  @override
  void onDisconnect() {
    super.onDisconnect();
    _readyPresetsCount = 0;
  }
}
