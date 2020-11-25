// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PresetsStorage {
  static final PresetsStorage _storage = PresetsStorage._();
  static const presetsFile = "presets.json";
  factory PresetsStorage() {
    return _storage;
  }

  String presetsPath;
  Directory storageDirectory;
  File _presetsFile;

  List<dynamic> presetsData;
  List<String> categoriesCache;

  PresetsStorage._() {
    presetsData = List<Map<String, dynamic>>();
    _init();
  }

  _init() async {
    categoriesCache = List<String>();
    await _getDirectory();
    await _loadPresets();
  }

  _getDirectory() async {
    if (Platform.isAndroid) {
      storageDirectory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      storageDirectory = await getApplicationDocumentsDirectory();
    }
    presetsPath = path.join(storageDirectory.path, presetsFile);
    _presetsFile = File(presetsPath);
  }

  _loadPresets() async {
    try {
      var _presetJson = await _presetsFile.readAsString();
      presetsData = json.decode(_presetJson);
      _buildCategoryCache();
    } catch (e) {
      //   //no file
      //   print("Presets file not available");
    }
  }

  _savePresets() async {
    _buildCategoryCache();
    String _json = json.encode(presetsData);
    await _presetsFile.writeAsString(_json);
  }

  List<String> getCategories() {
    return categoriesCache;
  }

  _buildCategoryCache() {
    categoriesCache.clear();
    presetsData.forEach((element) {
      if (!categoriesCache.contains(element["category"]))
        categoriesCache.add(element["category"]);
    });
  }

  int findPreset(String name, String category) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["name"] == name &&
          presetsData[i]["category"] == category) return i;
    }
    return null;
  }

  savePreset(Map<String, dynamic> preset, String name, String category) {
    preset["name"] = name;
    preset["category"] = category;

    var index = findPreset(name, category);
    if (index != null) {
      //overwrite preset
      presetsData[index] = preset;
    } else {
      presetsData.add(preset);
    }

    _savePresets();
  }

  Future deletePreset(String category, String name) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        presetsData.removeAt(i);
        return _savePresets();
      }
    }
    return null;
  }

  Future renamePreset(String category, String name, String newName) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        presetsData[i]["name"] = newName;
        return _savePresets();
      }
    }
    return null;
  }
}
