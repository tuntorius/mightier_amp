import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

class BleMidiController extends MidiController {
  ScanResult scanResult;
  BluetoothCharacteristic? _characteristic;

  ControllerType get type => ControllerType.MidiBle;

  BleMidiController(this.scanResult);

  @override
  String get id => scanResult.device.id.id;

  @override
  String get name => scanResult.device.name;

  @override
  bool get connected => _connected;
  bool _connected = false;

  Future<bool> connect() async {
    _characteristic =
        await BLEMidiHandler.instance().connectToController(scanResult.device);

    if (_characteristic != null) {
      _onConnected();
    }
    return _characteristic != null;
  }

  _onConnected() {
    scanResult.device.state.listen(_deviceStateListener);
    _connected = true;

    _characteristic!.value.listen(_onDataReceivedEvent);
  }

  _onDataReceivedEvent(List<int> data) {
    onDataReceived?.call(this, data);
  }

  _deviceStateListener(event) {
    if (event == BluetoothDeviceState.disconnected) {
      //remove device from the list
      print("Midi controller disconnected");
      _connected = false;
      onStatus?.call(this, ControllerStatus.Disconnected);
    }
  }
}
