import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

import '../../bluetooth/ble_controllers/BLEController.dart';

class BleMidiController extends MidiController {
  final BLEScanResult _scanResult;
  BLEConnection? _bleConnection;
  StreamSubscription? _characteristicSubscription;
  StreamSubscription? _deviceStatusSubscription;

  @override
  ControllerType get type => ControllerType.MidiBle;

  BleMidiController(this._scanResult);

  @override
  String get id => _scanResult.id;

  @override
  String get name => _scanResult.name;

  @override
  bool get connected => _connected;
  bool _connected = false;

  @override
  Future<bool> connect() async {
    _bleConnection = await BLEMidiHandler.instance().connectToDevice(_scanResult.device);

    if (_bleConnection != null) {
      _onConnected();
    }
    return _bleConnection != null;
  }

  _onConnected() {
    _deviceStatusSubscription = _scanResult.device.state.listen(_deviceStateListener);
    _connected = true;

    _characteristicSubscription = _bleConnection!.data.listen(_onDataReceivedEvent);
  }

  _onDataReceivedEvent(List<int> data) {
    onDataReceived?.call(this, data);
  }

  _deviceStateListener(BleDeviceState event) {
    if (event == BleDeviceState.disconnected) {
      //remove device from the list
      debugPrint("Midi controller disconnected");
      _connected = false;
      onStatus?.call(this, ControllerStatus.Disconnected);
      _characteristicSubscription?.cancel();
      _deviceStatusSubscription?.cancel();
    }
  }
}
