// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:convert';
import 'dart:io';
import 'package:mighty_plug_manager/bluetooth/devices/effects/plug_air/Cabinet.dart';
import 'package:wakelock/wakelock.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SettingsKeys {
  static const String latency = "audioLatency";
  static const String screenAlwaysOn = "screenAlwaysOn";
  static const String timeUnit = "timeUnit";
  static const String changeCabs = "changeCabs";
  static const String device = "device";
  static const String deviceVersion = "deviceVersion";
  static const String masterVolume = "volume";
  static const String customCabinets = "customCabinets";
}

class SharedPrefs {
  static final SharedPrefs _storage = SharedPrefs._();
  static const prefsFile = "prefs.json";

  factory SharedPrefs() {
    return _storage;
  }

  String prefsPath = "";
  Directory? storageDirectory;
  File? _prefsFile;
  bool _prefsReady = false;

  Map<String, dynamic> _prefsData = {};

  SharedPrefs._() {
    _init();
  }

  _init() async {
    await _getDirectory();
    await _loadPrefs();

    bool value = getValue(SettingsKeys.screenAlwaysOn, false);
    Wakelock.toggle(enable: value);
  }

  _getDirectory() async {
    if (Platform.isAndroid) {
      storageDirectory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      storageDirectory = await getApplicationDocumentsDirectory();
    }
    if (storageDirectory != null) {
      prefsPath = path.join(storageDirectory!.path, prefsFile);
      _prefsFile = File(prefsPath);
    }
  }

  _loadPrefs() async {
    try {
      if (_prefsFile != null) {
        var _presetJson = await _prefsFile!.readAsString();
        _prefsData = json.decode(_presetJson);
        _prefsReady = true;
      }
    } catch (e) {
      _prefsReady = true;
      //   //no file
      //   print("Presets file not available");
    }
  }

  Future waitLoading() async {
    for (int i = 0; i < 20; i++) {
      if (_prefsReady) break;
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  _savePrefs() async {
    if (_prefsFile != null) {
      String _json = json.encode(_prefsData);
      await _prefsFile?.writeAsString(_json);
    }
  }

  setInt(String key, int value) {
    _prefsData[key] = value;
    _savePrefs();
  }

  int getInt(String key, int _default) {
    if (_prefsData.containsKey(key)) return _prefsData[key];
    return _default;
  }

  void setValue(String key, dynamic value) {
    _prefsData[key] = value;
    _savePrefs();
  }

  dynamic getValue(String key, dynamic _default) {
    if (_prefsData.containsKey(key)) return _prefsData[key];
    return _default;
  }

  String? getCustomCabinetName(String productId, int cabIndex) {
    return _prefsData[SettingsKeys.customCabinets]?[productId]
            ?[cabIndex.toString()] ??
        null;
  }

  setCustomCabinetName(String productId, int cabIndex, String name) {
    if (!_prefsData.containsKey(SettingsKeys.customCabinets))
      _prefsData[SettingsKeys.customCabinets] = <String, Map<String, String>>{};
    if (!_prefsData[SettingsKeys.customCabinets].containsKey(productId))
      _prefsData[SettingsKeys.customCabinets][productId] = <String, String>{};

    _prefsData[SettingsKeys.customCabinets][productId][cabIndex.toString()] =
        name;
    _savePrefs();
  }
}
