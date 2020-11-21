import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SettingsKeys {
  static const String latency = "audioLatency";
}

class SharedPrefs {
  static final SharedPrefs _storage = SharedPrefs._();
  static const prefsFile = "prefs.json";
  factory SharedPrefs() {
    return _storage;
  }

  String prefsPath;
  Directory storageDirectory;
  File _prefsFile;

  Map<String, dynamic> _prefsData;

  SharedPrefs._() {
    _init();
  }

  _init() async {
    _prefsData = Map<String, dynamic>();
    await _getDirectory();
    await _loadPrefs();
  }

  _getDirectory() async {
    if (Platform.isAndroid) {
      storageDirectory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      storageDirectory = await getApplicationDocumentsDirectory();
    }
    prefsPath = path.join(storageDirectory.path, prefsFile);
    _prefsFile = File(prefsPath);
  }

  _loadPrefs() async {
    try {
      var _presetJson = await _prefsFile.readAsString();
      _prefsData = json.decode(_presetJson);
    } catch (e) {
      //   //no file
      //   print("Presets file not available");
    }
  }

  _savePrefs() async {
    String _json = json.encode(_prefsData);
    await _prefsFile.writeAsString(_json);
  }

  setInt(String key, int value) {
    _prefsData[key] = value;
    _savePrefs();
  }

  getInt(String key, int _default) {
    if (_prefsData.containsKey(key)) return _prefsData[key];
    return _default;
  }
}
