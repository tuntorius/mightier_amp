import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';

import '../bluetooth/ble_controllers/BLEController.dart';
import 'ControllerConstants.dart';
import 'MidiControllerManager.dart';
import 'controllers/BleMidiController.dart';

class BleMidiManager extends ChangeNotifier {
  //List<MidiDevice> _devices = [];

  bool get isScanning => BLEMidiHandler.instance().isScanning;
  bool _firstTimeScanned = false;
  final Function(HotkeyControl) onHotkeyReceived;

  List<BleMidiController> get controllers => _controllers;
  final List<BleMidiController> _controllers = [];

  bool usbMidiSupported = false;

  StreamSubscription<MidiSetupStatus>? _bleStatusSub;
  StreamSubscription<bool>? _bleScanSub;

  BleMidiManager(this.onHotkeyReceived) {
    _bleStatusSub = BLEMidiHandler.instance().status.listen(_bleStatusListener);
  }

  startScan() {
    if (BLEMidiHandler.instance().isScanning) return;

    for (int i = controllers.length - 1; i >= 0; i--) {
      if (!controllers[i].connected) controllers.removeAt(i);
    }

    _bleScanSub =
        BLEMidiHandler.instance().isScanningStream.listen(_scanStatusListener);
    BLEMidiHandler.instance().startScanning(true);
  }

  stopScan() {
    BLEMidiHandler.instance().stopScanning();
    _unsubscribeScanListener();
  }

  createControllers() {
    var ctrls = BLEMidiHandler.instance().controllerDevices;
    for (var ctl in ctrls) {
      var blectl = BleMidiController(ctl, onHotkeyReceived);
      if (!_controllers.contains(blectl)) {
        _controllers.add(BleMidiController(ctl, onHotkeyReceived));
      }
    }
  }

  _unsubscribeScanListener() {
    _bleScanSub?.cancel();
  }

  _scanStatusListener(bool scanning) {
    if (scanning == false) _unsubscribeScanListener();
    notifyListeners();
  }

  _bleStatusListener(MidiSetupStatus status) {
    switch (status) {
      case MidiSetupStatus.bluetoothOff:
        // TODO: Handle this case.
        break;
      case MidiSetupStatus.deviceIdle:
        if (!_firstTimeScanned) {
          _firstTimeScanned = true;
          MidiControllerManager().connectAvailableBLEDevices();
        }
        break;
      case MidiSetupStatus.deviceSearching:
        // TODO: Handle this case.
        break;
      case MidiSetupStatus.deviceFound:
        createControllers();
        break;
      case MidiSetupStatus.deviceConnecting:
        // TODO: Handle this case.
        break;
      case MidiSetupStatus.deviceConnected:
        // TODO: Handle this case.
        break;
      case MidiSetupStatus.deviceDisconnected:
        debugPrint("Dev just disconnected!");
        // TODO: Handle this case.
        break;
      case MidiSetupStatus.unknown:
        // TODO: Handle this case.
        break;
    }

    notifyListeners();
  }
}
