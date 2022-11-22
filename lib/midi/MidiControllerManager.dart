import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'package:mighty_plug_manager/midi/UsbMidiManager.dart';
import 'package:mighty_plug_manager/midi/controllers/BleMidiController.dart';
import 'package:mighty_plug_manager/midi/controllers/HidController.dart';
import 'package:path/path.dart' as path;

import '../bluetooth/ble_controllers/BLEController.dart';
import '../platform/platformUtils.dart';
import 'BleMidiManager.dart';
import 'ControllerConstants.dart';
import 'controllers/MidiController.dart';

typedef MidiDataOverride = void Function(int code, int? sliderValue, String name);

class MidiControllerManager extends ChangeNotifier {
  static final MidiControllerManager _controller = MidiControllerManager._();

  bool get isScanning => BleMidiManager().isScanning;
  List<MidiController> get controllers => _controllers;
  final List<MidiController> _controllers = [];

  final MidiController _hidController = HidController();

  MidiDataOverride? dataOverride;

  //file stuff for saving controller assignments
  static const controllersFile = "midicontrollers.json";

  String filePath = "";
  late Directory? storageDirectory;
  late File _controllersFile;
  List<dynamic> _controllersData = [];

  factory MidiControllerManager() {
    return _controller;
  }

  MidiControllerManager._() {
    _controllers.add(_hidController);
    BleMidiManager().addListener(_onBleMidiManagerChanged);
    loadConfig();

    BLEMidiHandler.instance().status.listen(_statusListener);
  }

  void _statusListener(statusValue) {
    switch (statusValue) {
      case MidiSetupStatus.deviceFound:
        // check if this is valid nux device
        for (var dev in BLEMidiHandler.instance().controllerDevices) {
          //don't autoconnect on manual scan
          if (!BLEMidiHandler.instance().manualScan) {
            //_midiHandler.connectToDevice(dev.device);
          }
        }
        break;
    }
  }

  startScan() {
    notifyListeners();
    _controllers.clear();

    //add the hid controller by default
    _controllers.add(_hidController);
    _loadControllerHotkeys(_hidController);
    //scan for usb midi devices
    UsbMidiManager().getDevices().then((value) {
      _controllers.addAll(value);
      for (var dev in value) {
        dev.setOnStatus(onControllerStatus);
        dev.setOnDataReceived(onControllerData);
        _loadControllerHotkeys(dev);
      }
      notifyListeners();
    });

    BleMidiManager().startScan();
  }

  stopScan() {
    BleMidiManager().stopScan();
    notifyListeners();
  }

  connectAvailableBLEDevices() {
    for (var c in _controllers) {
      if (c is BleMidiController) {
        if (!c.connected) c.connect();
      }
    }
  }

  _onBleMidiManagerChanged() {
    //check for new device
    for (var dev in BleMidiManager().controllers) {
      if (!_controllers.contains(dev)) {
        _controllers.add(dev);
        dev.setOnStatus(onControllerStatus);
        dev.setOnDataReceived(onControllerData);
        _loadControllerHotkeys(dev);
      }
    }
    notifyListeners();
  }

  onControllerStatus(MidiController ctrl, ControllerStatus status) {
    if (status == ControllerStatus.Disconnected) notifyListeners();
  }

  onControllerData(MidiController ctrl, List<int> data) {
    bool consumed = false;
    int code = 0;
    int? value = 0;
    String name = "";
    for (int i = 0; i < data.length - 1; i++) {
      //check midi message start
      if (data[i] >= 0x80 && data[i + 1] < 0x80) {
        int status = data[i] & 0xf0;
        switch (status) {
          case MidiConstants.NoteOn:
            if (data.length - i < 3) break;
            code = data[i] << 16 | data[i + 1] << 8;
            value = data[i + 2];
            if (value == 0) return;
            name = "NO ${data[i + 1].toRadixString(16)}";
            consumed = true;
            break;
          case MidiConstants.PolyAfterTouch:
            if (data.length - i < 3) break;
            code = data[i] << 8 | data[i + 1] << 8;
            value = data[i + 2];
            name = "PKP ${data[i + 1].toRadixString(16)}";
            consumed = true;
            break;
          case MidiConstants.ControlChange:
            if (data.length - i < 3) break;
            code = data[i] << 16 | data[i + 1] << 8 | data[i + 2];
            value = data[i + 2];
            name = "CC ${data[i + 1].toRadixString(16)} ${data[i + 2].toRadixString(16)}";
            consumed = true;
            break;
          case MidiConstants.ProgramChange:
            if (data.length - i < 2) break;
            code = data[i] << 16 | data[i + 1] << 8;
            value = null;
            name = "PC ${data[i + 1].toRadixString(16)}";
            consumed = true;
            break;
          case MidiConstants.ChannelPressure:
            if (data.length - i < 2) break;
            code = data[i] << 8;
            value = data[i + 1];
            name = "CP";
            consumed = true;
            break;
          case MidiConstants.PitchBend:
            if (data.length - i < 3) break;
            code = data[i] << 8;
            value = data[i + 1] | data[i + 2] << 7;
            name = "PB";
            consumed = true;
            break;
        }
      }
      if (consumed) break;
    }

    //decode message
    _onControlMessage(ctrl, code, value, name);
  }

  onHIDData(RawKeyEvent event) {
    _onControlMessage(_hidController, event.physicalKey.usbHidUsage, null, event.logicalKey.keyLabel);
  }

  _onControlMessage(MidiController ctrl, int code, int? sliderValue, String name) {
    //do whatever you do
    if (dataOverride != null) {
      dataOverride!.call(code, sliderValue, name);
    } else {
      //execute function
      var hk = ctrl.getHotkeyByCode(code, false);
      hk?.execute(sliderValue);
    }
  }

  overrideOnData(MidiDataOverride override) {
    dataOverride = override;
  }

  cancelOnDataOverride() {
    dataOverride = null;
  }

  loadConfig() async {
    await _getDirectory();

    try {
      var exists = await _controllersFile.exists();
      if (exists) {
        var ctrlJson = await _controllersFile.readAsString();
        _controllersData = json.decode(ctrlJson);
        _loadControllerHotkeys(_hidController);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  saveConfig() async {
    //generate controllers data
    _controllersData.clear();

    //while json encode does this, it's needed here as well
    //so prepare it manually
    for (var c in _controllers) {
      _controllersData.add(c.toJson());
    }

    String jsonData = json.encode(_controllersData);
    await _controllersFile.writeAsString(jsonData);
  }

  _getDirectory() async {
    storageDirectory = await PlatformUtils.getAppDataDirectory();
    filePath = path.join(storageDirectory?.path ?? "", controllersFile);
    _controllersFile = File(filePath);
  }

  _loadControllerHotkeys(MidiController ctrl) {
    for (var config in _controllersData) {
      if (config is Map<String, dynamic>) {
        if (config["name"] == ctrl.name) ctrl.fromJson(config);
      }
    }
  }
}
