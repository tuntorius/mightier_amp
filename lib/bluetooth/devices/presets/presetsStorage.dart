// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugAir.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class PresetsStorage extends ChangeNotifier {
  static final PresetsStorage _storage = PresetsStorage._();
  static const presetsFile = "presets.json";

  static const presetsSingle = "preset-single";
  static const presetsMultiple = "preset-multiple";

  final Uuid uuid = Uuid();

  factory PresetsStorage() {
    return _storage;
  }

  String presetsPath = "";
  Directory? storageDirectory;
  File? _presetsFile;
  bool _presetsReady = false;

  List<dynamic> presetsData = <dynamic>[];
  List<String> categoriesCache = <String>[];

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

    if (storageDirectory != null) {
      presetsPath = path.join(storageDirectory!.path, presetsFile);
      _presetsFile = File(presetsPath);
    }
  }

  _loadPresets() async {
    try {
      if (_presetsFile != null) {
        var _presetJson = await _presetsFile!.readAsString();
        presetsData = json.decode(_presetJson);

        //fix any old compatibility issues
        for (int i = 0; i < presetsData.length; i++)
          presetsData[i] = fixPresetCompatibility(presetsData[i]);

        _buildCategoryCache();
        _presetsReady = true;
      }
    } catch (e) {
      _presetsReady = true;
      //   //no file
      //   print("Presets file not available");
    }
  }

  _savePresets() async {
    _buildCategoryCache();
    String _json = json.encode(presetsData);
    await _presetsFile!.writeAsString(_json);
    notifyListeners();
  }

  Future waitLoading() async {
    for (int i = 0; i < 20; i++) {
      if (_presetsReady) break;
      await Future.delayed(Duration(milliseconds: 200));
    }
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
    categoriesCache.sort();
  }

  int? findPreset(String name, String category) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["name"] == name &&
          presetsData[i]["category"] == category) return i;
    }
    return null;
  }

  dynamic findPresetByUuid(String uuid) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["uuid"] == uuid) return presetsData[i];
    }
    return null;
  }

  savePreset(Map<String, dynamic> preset, String name, String category) async {
    preset["name"] = name;
    preset["category"] = category;

    _addUuid(preset);

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
    return Future.error("Preset not found");
  }

  Future duplicatePreset(String category, String name) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        var clone = json.decode(json.encode(presetsData[i]));

        String? _name = _findFreeName(name, category);
        if (_name != null) {
          clone["name"] = _name;
          presetsData.insert(i + 1, clone);
          return _savePresets();
        }
      }
    }
    return Future.error("Can't clone preset");
  }

  Future renamePreset(String category, String name, String newName) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        presetsData[i]["name"] = newName;
        return _savePresets();
      }
    }
    return Future.error("Preset not found");
  }

  clearNewFlag(String category, String name) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        if (presetsData[i].containsKey("new")) {
          presetsData[i].remove("new");
          _savePresets();
        }
      }
    }
  }

  Future changeChannel(String category, String name, int channel) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        presetsData[i]["channel"] = channel;
        return _savePresets();
      }
    }
    return Future.error("Preset not found");
  }

  Future changePresetCategory(
      String category, String name, String newCategory) {
    for (int i = 0; i < presetsData.length; i++) {
      if (presetsData[i]["category"] == category &&
          presetsData[i]["name"] == name) {
        presetsData[i]["category"] = newCategory;
        return _savePresets();
      }
    }
    return Future.error("Preset not found");
  }

  Future<List<String>> deleteCategory(String category) async {
    bool modified = false;
    List<String> uuids = [];
    for (int i = presetsData.length - 1; i >= 0; i--) {
      if (presetsData[i]["category"] == category) {
        uuids.add(presetsData[i]["uuid"]);
        presetsData.removeAt(i);
        modified = true;
      }
    }
    if (modified) {
      await _savePresets();
      return uuids;
    }
    return Future.error("Category not found");
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
    return Future.error("Category not found");
  }

  String? presetToJson(String category, String name) {
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
  String? presetsToJson([String? category]) {
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

  Future presetsFromJson(String jsonData) async {
    try {
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
    } on FormatException {
      return Future.error("Wrong File");
    }
  }

  _presetFromJson(
      String category, String name, Map<String, dynamic> presetData) async {
    int? p = findPreset(name, category);

    presetData = fixPresetCompatibility(presetData);
    String? _name = name;
    //check if exists
    if (p != null) {
      Map<String, dynamic> _p = presetsData[p];

      if (_presetsEquality(presetData, _p)) return;

      //difference - find free name and save as that
      _name = _findFreeName(name, category);
    }

    //highlight that the preset is new
    presetData["new"] = true;
    //save preset
    if (_name != null) savePreset(presetData, _name, category);
  }

  String? _findFreeName(String name, String category) {
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
    if (!presetData.containsKey("uuid")) {
      _addUuid(presetData);
    }
    return presetData;
  }

  void _addUuid(Map<String, dynamic> preset) {
    bool unique = true;
    do {
      String id = uuid.v4();
      // check unique
      presetsData.forEach((element) {
        if (element["uuid"] == id) unique = false;
      });
      preset["uuid"] = id;
    } while (unique == false);
  }
}
