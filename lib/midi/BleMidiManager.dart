import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';

import 'MidiControllerManager.dart';
import 'controllers/BleMidiController.dart';

class BleMidiManager extends ChangeNotifier {
  static final BleMidiManager _controller = BleMidiManager._();
  //List<MidiDevice> _devices = [];

  bool get isScanning => BLEMidiHandler().isScanning;
  bool _firstTimeScanned = false;

  List<BleMidiController> get controllers => _controllers;
  List<BleMidiController> _controllers = [];

  bool usbMidiSupported = false;

  StreamSubscription<midiSetupStatus>? _bleStatusSub;
  StreamSubscription<bool>? _bleScanSub;

  factory BleMidiManager() {
    return _controller;
  }

  BleMidiManager._() {
    _bleStatusSub = BLEMidiHandler().status.listen(_bleStatusListener);
  }

  startScan() {
    if (BLEMidiHandler().isScanning) return;

    for (int i = controllers.length - 1; i >= 0; i--)
      if (!controllers[i].connected) controllers.removeAt(i);

    _bleScanSub = BLEMidiHandler().scanStatus.listen(_scanStatusListener);
    BLEMidiHandler().startScanning(true);
  }

  stopScan() {
    BLEMidiHandler().stopScanning();
    _unsubscribeScanListener();
  }

  createControllers() {
    var ctrls = BLEMidiHandler().controllerDevices;
    for (var ctl in ctrls) {
      var blectl = BleMidiController(ctl);
      if (!_controllers.contains(blectl))
        _controllers.add(BleMidiController(ctl));
    }
  }

  _unsubscribeScanListener() {
    _bleScanSub?.cancel();
  }

  _scanStatusListener(bool scanning) {
    if (scanning == false) _unsubscribeScanListener();
    notifyListeners();
  }

  _bleStatusListener(midiSetupStatus status) {
    switch (status) {
      case midiSetupStatus.bluetoothOff:
        // TODO: Handle this case.
        break;
      case midiSetupStatus.deviceIdle:
        if (!_firstTimeScanned) {
          _firstTimeScanned = true;
          MidiControllerManager().connectAvailableBLEDevices();
        }
        break;
      case midiSetupStatus.deviceSearching:
        // TODO: Handle this case.
        break;
      case midiSetupStatus.deviceFound:
        createControllers();
        break;
      case midiSetupStatus.deviceConnecting:
        // TODO: Handle this case.
        break;
      case midiSetupStatus.deviceConnected:
        // TODO: Handle this case.
        break;
      case midiSetupStatus.deviceDisconnected:
        print("Dev just disconnected!");
        // TODO: Handle this case.
        break;
      case midiSetupStatus.unknown:
        // TODO: Handle this case.
        break;
    }

    notifyListeners();
  }
}
