import 'dart:async';
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
import '../platform/simpleSharedPrefs.dart';
import 'BleMidiManager.dart';
import 'ControllerConstants.dart';
import 'controllers/MidiController.dart';

typedef MidiDataOverride = void Function(
    MidiController ctrl, int code, int? sliderValue, String name);

class MidiControllerManager extends ChangeNotifier {
  static final MidiControllerManager _controller = MidiControllerManager._();

  late BleMidiManager _bleMidiManager;
  late UsbMidiManager _usbMidiManager;

  bool get isScanning => _bleMidiManager.isScanning;
  List<MidiController> get controllers => _controllers;
  final List<MidiController> _controllers = [];

  late MidiController _hidController;

  MidiDataOverride? dataOverride;

  final StreamController<HotkeyControl> _midiCommandController =
      StreamController<HotkeyControl>.broadcast();

  Stream<HotkeyControl> get controllerStream => _midiCommandController.stream;

  // File stuff for saving controller assignments
  static const controllersFile = "midicontrollers.json";

  String filePath = "";
  late Directory? storageDirectory;
  late File _controllersFile;

  // Persistent memory of saved configs keyed by controller identifier/name
  final Map<String, Map<String, dynamic>> _savedControllersData = {};

  factory MidiControllerManager() {
    return _controller;
  }

  MidiControllerManager._() {
    _bleMidiManager = BleMidiManager(_onHotkeyReceived);
    _usbMidiManager = UsbMidiManager(_onHotkeyReceived, scanUsb);
    _hidController = HidController(_onHotkeyReceived);
    _controllers.add(_hidController);
    _bleMidiManager.addListener(_onBleMidiManagerChanged);
    loadConfig().then(
      (_) async {
        await Future.delayed(const Duration(seconds: 1));
        scanUsb();
      },
    );

    BLEMidiHandler.instance().status.listen(_statusListener);
  }

  void _statusListener(statusValue) {
    switch (statusValue) {
      case MidiSetupStatus.deviceFound:
        for (var dev in BLEMidiHandler.instance().controllerDevices) {
          if (!BLEMidiHandler.instance().manualScan) {
            // connection handled by scanner
          }
        }
        break;
    }
  }

  startScan() {
    notifyListeners();
    // Do not wipe _controllers to prevent losing native references!
    _loadControllerHotkeys(_hidController);
    scanUsb();
    _bleMidiManager.startScan();
  }

  scanUsb() {
    _usbMidiManager.getDevices().then(_connectAvailableUsbDevices);
  }

  stopScan() {
    _bleMidiManager.stopScan();
    notifyListeners();
  }

  Future<void> disconnectAllControllers() async {
    for (var ctrl in _controllers) {
      if (ctrl is BleMidiController && ctrl.connected) {
        ctrl.disconnect();
      }
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  _connectAvailableUsbDevices(List<MidiController> devices) {
    for (var dev in devices) {
      MidiController activeCtrl = _findOrRegisterController(dev);
      activeCtrl.setOnStatus(onControllerStatus);
      activeCtrl.setOnDataReceived(onControllerData);
      _loadControllerHotkeys(activeCtrl);
      if (!activeCtrl.connected) {
        activeCtrl.connect();
      }
    }
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
    for (var dev in _bleMidiManager.controllers) {
      MidiController activeCtrl = _findOrRegisterController(dev);
      activeCtrl.setOnStatus(onControllerStatus);
      activeCtrl.setOnDataReceived(onControllerData);
      _loadControllerHotkeys(activeCtrl);
    }
    notifyListeners();
  }

  MidiController _findOrRegisterController(MidiController dev) {
    int existingIndex = _controllers.indexWhere((c) =>
        (c.id.isNotEmpty && c.id == dev.id) ||
        _sanitizeName(c.name) == _sanitizeName(dev.name));

    if (existingIndex != -1) {
      return _controllers[existingIndex];
    } else {
      _controllers.add(dev);
      return dev;
    }
  }

  onControllerStatus(MidiController ctrl, ControllerStatus status) {
    notifyListeners();
  }

  onControllerData(MidiController ctrl, List<int> data) {
    bool consumed = false;
    int code = 0;
    int? value = 0;
    String name = "";
    for (int i = 0; i < data.length - 1; i++) {
      if (data[i] >= 0x80 && data[i + 1] < 0x80) {
        int status = data[i] & 0xf0;
        switch (status) {
          case MidiConstants.NoteOn:
            if (data.length - i < 3) break;
            code = data[i] << 16 | data[i + 1] << 8;
            value = data[i + 2];
            if (value == 0) return;
            if (dataOverride != null) {
              name = "NO ${data[i + 1].toRadixString(16)}";
            }
            consumed = true;
            break;
          case MidiConstants.PolyAfterTouch:
            if (data.length - i < 3) break;
            code = data[i] << 8 | data[i + 1] << 8;
            value = data[i + 2];
            if (dataOverride != null) {
              name = "PKP ${data[i + 1].toRadixString(16).padLeft(2, '0')}";
            }
            consumed = true;
            break;
          case MidiConstants.ControlChange:
            if (data.length - i < 3) break;
            code = data[i] << 16 | data[i + 1] << 8 | data[i + 2];
            value = data[i + 2];
            if (dataOverride != null) {
              name =
                  "CC ${data[i + 1].toRadixString(16).padLeft(2, '0')} ${data[i + 2].toRadixString(16).padLeft(2, '0')}";
            }
            consumed = true;
            break;
          case MidiConstants.ProgramChange:
            if (data.length - i < 2) break;
            code = data[i] << 16 | data[i + 1] << 8;
            value = null;

            if (dataOverride != null) {
              name = "PC ${data[i + 1].toRadixString(16).padLeft(2, '0')}";
            }
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

    _onControlMessage(ctrl, code, value, name);
  }

  onHIDData(RawKeyEvent event) {
    _onControlMessage(_hidController, event.physicalKey.usbHidUsage, null,
        event.logicalKey.keyLabel);
  }

  _onControlMessage(
      MidiController ctrl, int code, int? sliderValue, String name) {
    if (dataOverride != null) {
      dataOverride!.call(ctrl, code, sliderValue, name);
    } else {
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

  Future<void> loadConfig() async {
    await SharedPrefs().waitLoading();
    await _getDirectory();

    var savedString = SharedPrefs().getValue(SettingsKeys.midiHotkeys, null);
    if (savedString != null) {
      try {
        List<dynamic> list = json.decode(savedString);
        _parseConfigList(list);
        _loadControllerHotkeys(_hidController);
        return;
      } catch (e) {
        debugPrint("Error parsing SharedPrefs MIDI config: $e");
      }
    }

    // Fallback to reading file
    try {
      var exists = await _controllersFile.exists();
      if (exists) {
        var ctrlJson = await _controllersFile.readAsString();
        List<dynamic> list = json.decode(ctrlJson);
        _parseConfigList(list);
        _loadControllerHotkeys(_hidController);
      }
    } catch (e) {
      debugPrint("Error reading controllers file: $e");
    }
  }

  void _parseConfigList(List<dynamic> list) {
    for (var config in list) {
      if (config is Map<String, dynamic>) {
        var name = config["name"] as String?;
        var id = config["id"] as String?;
        if (name != null) _savedControllersData[name] = config;
        if (id != null && id.isNotEmpty) _savedControllersData[id] = config;
      }
    }
  }

  saveConfig() async {
    for (var c in _controllers) {
      _savedControllersData[c.name] = c.toJson();
      if (c.id.isNotEmpty) {
        _savedControllersData[c.id] = c.toJson();
      }
    }

    Set<String> processedNames = {};
    List<dynamic> exportList = [];

    for (var entry in _savedControllersData.entries) {
      var name = entry.value["name"] ?? entry.key;
      if (!processedNames.contains(name)) {
        exportList.add(entry.value);
        processedNames.add(name);
      }
    }

    String jsonData = json.encode(exportList);
    SharedPrefs().setValue(SettingsKeys.midiHotkeys, jsonData);

    try {
      if (_controllersFile != null) {
        await _controllersFile.writeAsString(jsonData);
      }
    } catch (e) {
      debugPrint("Error saving midicontrollers.json: $e");
    }
  }

  _getDirectory() async {
    storageDirectory = await PlatformUtils.getAppDataDirectory();
    filePath = path.join(storageDirectory?.path ?? "", controllersFile);
    _controllersFile = File(filePath);
  }

  bool _loadControllerHotkeys(MidiController ctrl) {
    Map<String, dynamic>? config =
        _savedControllersData[ctrl.name] ?? _savedControllersData[ctrl.id];

    if (config == null) {
      String sanitizedCtrlName = _sanitizeName(ctrl.name);
      for (var entry in _savedControllersData.entries) {
        if (_sanitizeName(entry.key) == sanitizedCtrlName) {
          config = entry.value;
          break;
        }
      }
    }

    if (config != null) {
      ctrl.fromJson(config, _onHotkeyReceived);
      return true;
    }
    return false;
  }

  String _sanitizeName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  void _onHotkeyReceived(HotkeyControl hotkey) {
    _midiCommandController.add(hotkey);
  }
}