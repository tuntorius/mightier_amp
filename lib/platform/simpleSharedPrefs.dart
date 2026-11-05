// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'platformUtils.dart';

class SettingsKeys {
  static const String latency = "audioLatency";
  static const String screenAlwaysOn = "screenAlwaysOn";
  static const String darkMode = "darkMode";
  static const String timeUnit = "timeUnit";
  static const String changeCabs = "changeCabs";
  static const String device = "device";
  static const String deviceVersion = "deviceVersion";
  static const String masterVolume = "volume";
  static const String customCabinets = "customCabinets";
  static const String legacyDecoder = "legacyDecoder";
  static const String hiddenSources = "hiddenSources";
  static const String hideNotApplicablePresets = "hideNotApplicablePresets";
  static const String tempoTrainerTempoMin = "trainerTempoMin";
  static const String tempoTrainerTempoMax = "trainerTempoMax";
  static const String tempoTrainerStep = "trainerStep";
  static const String tempoTrainerChangeMode = "trainerChangeMode";
  static const String tempoTrainerChangeUnits = "trainerChangeUnits";
  static const String trackGain = "jamTracksGain";
  static const String midiHotkeys = "midiHotkeysData";
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
    WakelockPlus.toggle(enable: value);
  }

  _getDirectory() async {
    storageDirectory = await PlatformUtils.getAppDataDirectory();

    if (storageDirectory != null) {
      prefsPath = path.join(storageDirectory!.path, prefsFile);
      _prefsFile = File(prefsPath);
    }
  }

  _loadPrefs() async {
    try {
      if (_prefsFile != null) {
        var presetJson = await _prefsFile!.readAsString();
        _prefsData = json.decode(presetJson);
        _prefsReady = true;
      }
    } catch (e) {
      _prefsReady = true;
    }
  }

  Future waitLoading() async {
    for (int i = 0; i < 20; i++) {
      if (_prefsReady) break;
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  _savePrefs() async {
    if (_prefsFile != null) {
      String jsonString = json.encode(_prefsData);
      await _prefsFile?.writeAsString(jsonString);
    }
  }

  void setInt(String key, int value) {
    _prefsData[key] = value;
    _savePrefs();
  }

  int getInt(String key, int defaultValue) {
    if (_prefsData.containsKey(key)) return _prefsData[key];
    return defaultValue;
  }

  void setValue(String key, dynamic value) {
    _prefsData[key] = value;
    _savePrefs();
  }

  void remove(String key) {
    _prefsData.remove(key);
    _savePrefs();
  }

  dynamic getValue(String key, dynamic defaultValue) {
    if (_prefsData.containsKey(key)) return _prefsData[key];
    return defaultValue;
  }

  String? getCustomCabinetName(String productId, int cabIndex) {
    return _prefsData[SettingsKeys.customCabinets]?[productId]
        ?[cabIndex.toString()];
  }

  setCustomCabinetName(String productId, int cabIndex, String name) {
    if (!_prefsData.containsKey(SettingsKeys.customCabinets)) {
      _prefsData[SettingsKeys.customCabinets] = <String, Map<String, String>>{};
    }
    if (!_prefsData[SettingsKeys.customCabinets].containsKey(productId)) {
      _prefsData[SettingsKeys.customCabinets][productId] = <String, String>{};
    }

    _prefsData[SettingsKeys.customCabinets][productId][cabIndex.toString()] =
        name;
    _savePrefs();
  }
}