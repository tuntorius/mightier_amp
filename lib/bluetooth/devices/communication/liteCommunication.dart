import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';

import '../NuxConstants.dart';
import 'communication.dart';

class LiteCommunication extends DeviceCommunication {
  LiteCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  @override
  int get connectionSteps => 1;

  int _readyPresetsCount = 0;

  @override
  void performNextConnectionStep() {
    switch (currentConnectionStep) {
      case 0:
        _readyPresetsCount = 0;
        //device.deviceControl.sendBLEData(requestPresetByIndex(0));
        requestAllPresets();
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
  void saveCurrentPreset(int index) {}

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

  @override
  void fillTestData() {
    //Data for Mighty 20/40 BT
    _handlePresetDataPiece(
        [240, 7, 0, 48, 0, 0, 0, 50, 0, 20, 41, 40, 30, 55, 0, 2, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 0, 49, 52, 24, 100, 0, 0, 50, 34, 14, 1, 0, 30, 50, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 0, 50, 20, 1, 3, 116, 0, 0, 0, 0, 0, 0, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 1, 48, 0, 0, 0, 50, 1, 70, 23, 30, 30, 20, 0, 1, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 1, 49, 78, 41, 100, 0, 0, 50, 39, 19, 1, 0, 28, 50, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 1, 50, 35, 1, 3, 116, 0, 0, 0, 0, 0, 0, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 2, 48, 1, 70, 0, 50, 2, 80, 20, 50, 50, 50, 0, 2, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 2, 49, 55, 39, 100, 0, 0, 50, 52, 19, 1, 0, 20, 50, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 2, 50, 35, 1, 3, 116, 0, 0, 0, 0, 0, 0, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 3, 48, 0, 45, 0, 50, 3, 100, 21, 50, 50, 35, 0, 1, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 3, 49, 50, 50, 100, 0, 2, 50, 50, 40, 1, 0, 40, 50, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 3, 50, 25, 1, 5, 71, 0, 0, 0, 0, 0, 0, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 4, 48, 0, 0, 0, 50, 4, 50, 50, 40, 90, 0, 1, 1, 128, 247]);
    _handlePresetDataPiece([
      240,
      7,
      4,
      49,
      50,
      100,
      100,
      1,
      1,
      50,
      30,
      20,
      0,
      0,
      11,
      50,
      128,
      247
    ]);
    _handlePresetDataPiece(
        [240, 7, 4, 50, 26, 1, 3, 119, 0, 0, 0, 0, 0, 0, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 5, 48, 0, 0, 0, 50, 5, 80, 12, 30, 100, 15, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 5, 49, 27, 50, 100, 0, 1, 50, 35, 20, 1, 0, 15, 50, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 5, 50, 25, 1, 3, 119, 0, 0, 0, 0, 0, 0, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 6, 48, 1, 70, 0, 50, 6, 80, 25, 40, 50, 50, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 6, 49, 2, 27, 100, 0, 0, 50, 50, 24, 0, 0, 11, 50, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 6, 50, 70, 1, 3, 116, 0, 0, 0, 0, 0, 0, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 7, 48, 0, 49, 0, 50, 7, 100, 17, 50, 50, 50, 0, 0, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 7, 49, 2, 49, 100, 1, 0, 50, 60, 34, 1, 0, 60, 50, 128, 247]);
    _handlePresetDataPiece(
        [240, 7, 7, 50, 20, 1, 3, 119, 0, 0, 0, 0, 0, 0, 0, 0, 128, 247]);
  }
}
