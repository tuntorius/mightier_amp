// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:convert';
import 'dart:io';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugAir.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PresetsStorage {
  static final PresetsStorage _storage = PresetsStorage._();
  static const presetsFile = "presets.json";

  static const presetsSingle = "preset-single";
  static const presetsMultiple = "preset-multiple";

  factory PresetsStorage() {
    return _storage;
  }

  String presetsPath;
  Directory storageDirectory;
  File _presetsFile;

  List<dynamic> presetsData;
  List<String> categoriesCache;

  PresetsStorage._() {
    presetsData = <Map<String, dynamic>>[];
    _init();
  }

  _init() async {
    categoriesCache = <String>[];
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

      //fix any old compatibility issues
      for (int i = 0; i < presetsData.length; i++)
        presetsData[i] = fixPresetCompatibility(presetsData[i]);

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

  savePreset(Map<String, dynamic> preset, String name, String category) async {
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

  Future duplicatePreset(String category, String name) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        var clone = json.decode(json.encode(presetsData[i]));

        name = _findFreeName(name, category);
        clone["name"] = name;
        presetsData.insert(i + 1, clone);
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

  Future changeChannel(String category, String name, int channel) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        presetsData[i]["channel"] = channel;
        return _savePresets();
      }
    }
    return null;
  }

  Future deleteCategory(String category) {
    bool modified = false;
    for (int i = presetsData.length - 1; i >= 0; i--) {
      if (presetsData[i]["category"] == category) {
        presetsData.removeAt(i);
        modified = true;
      }
    }
    if (modified) return _savePresets();
    return null;
  }

  Future renameCategory(String category, String newName) {
    bool modified = false;
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category) {
        presetsData[i]["category"] = newName;
        modified = true;
      }
    }
    if (modified) return _savePresets();
    return null;
  }

  String presetToJson(String category, String name) {
    var finalData = Map<String, dynamic>();
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        //add some info
        finalData["type"] = presetsSingle;
        finalData["data"] = presetsData[i];
        return json.encode(finalData);
      }
    }
    return null;
  }

  //converts a category to json
  //if parameter left empty, then the full preset list is converted
  String presetsToJson([String category]) {
    var presets = <dynamic>[];
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category ||
          category == null ||
          category == "") {
        presets.add(presetsData[i]);
      }
    }
    if (presets.length > 0) {
      var finalData = Map<String, dynamic>();
      finalData["type"] = presetsMultiple;
      finalData["data"] = presets;
      return json.encode(finalData);
    }
    return null;
  }

  presetsFromJson(String jsonData) async {
    Map<String, dynamic> data = json.decode(jsonData);

    if (!data.containsKey("type")) return Future.error("Wrong File");
    if (data["type"] == presetsSingle) {
      //single preset
      Map<String, dynamic> pr = data["data"];
      _presetFromJson(pr["category"], pr["name"], pr);
    } else if (data["type"] == presetsMultiple) {
      //this is array of presets

      List<dynamic> pr = data["data"];
      for (Map<String, dynamic> item in pr) {
        _presetFromJson(item["category"], item["name"], item);
      }
    }
  }

  _presetFromJson(
      String category, String name, Map<String, dynamic> presetData) async {
    int p = findPreset(name, category);

    presetData = fixPresetCompatibility(presetData);

    //check if exists
    if (p != null) {
      Map<String, dynamic> _p = presetsData[p];

      if (_presetsEquality(presetData, _p)) return;

      //difference - find free name and save as that
      name = _findFreeName(name, category);
    }

    //save preset
    savePreset(presetData, name, category);
  }

  String _findFreeName(String name, String category) {
    for (int i = 1; i < 1000; i++) {
      String _name = "$name ($i)";
      if (findPreset(category, _name) == null) return _name;
    }

    return null;
  }

  bool _presetsEquality(Map<String, dynamic> p1, Map<String, dynamic> p2) {
    for (String k in p1.keys) {
      if (!p2.containsKey(k)) return false;

      //check sub-maps
      if (p1[k] is Map && p2[k] is Map) {
        bool equal = _presetsEquality(p1[k], p2[k]);
        if (equal == false) return false;
        continue;
      }

      if (p1[k] != p2[k]) return false;
    }
    return true;
  }

  Map<String, dynamic> fixPresetCompatibility(Map<String, dynamic> presetData) {
    //old style preset didn't contain mighty plug
    if (!presetData.containsKey("product_id"))
      presetData["product_id"] = NuxMightyPlug.defaultNuxId;

    return presetData;
  }
}
