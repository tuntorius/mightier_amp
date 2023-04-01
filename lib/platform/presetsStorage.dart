// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugAir.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../platform/platformUtils.dart';
import 'presetStorageListener.dart';

enum PresetChangeDirection { previous, next }

class PresetsStorage extends ChangeNotifier {
  static final PresetsStorage _storage = PresetsStorage._();
  static const presetsFile = "presets.json";
  static const presetsVersion = 2;

  static const presetsSingle = "preset-single";
  static const presetsMultiple = "preset-multiple";

  //Preset JSON keys
  static const inactiveEffectsKey = "inactiveEffects";
  static const uuidKey = "uuid";
  final Uuid uuid = const Uuid();

  factory PresetsStorage() {
    return _storage;
  }

  String presetsPath = "";
  Directory? storageDirectory;
  File? _presetsFile;
  bool _presetsReady = false;

  List<PresetStorageListener> _changeListeners = [];

  List presetsData = [];
  List<String> _categoriesCache = <String>[];

  PresetsStorage._() {
    _init();
  }

  _init() async {
    _categoriesCache = <String>[];
    await _getDirectory();
    await _loadPresets();
  }

  _getDirectory() async {
    storageDirectory = await PlatformUtils.getAppDataDirectory();

    if (storageDirectory != null) {
      presetsPath = path.join(storageDirectory!.path, presetsFile);
      _presetsFile = File(presetsPath);
    }
  }

  _loadPresets() async {
    try {
      if (_presetsFile != null) {
        var _presetJson = await _presetsFile!.readAsString();
        var data = json.decode(_presetJson);

        if (data is List) {
          debugPrint("Old preset format");

          //fix any old compatibility issues
          for (int i = 0; i < data.length; i++) {
            data[i] = fixPresetCompatibility(data[i]);
          }

          data = _convertOldToNewFormat(data);
          presetsData = data["Categories"];
          _savePresets();
        } else {
          presetsData = data["Categories"];
          if (data["Version"] < presetsVersion) {
            upgradeDataVersion(data["Version"]);
            _savePresets();
          }
        }

        _buildCategoryCache();
        _presetsReady = true;
      }
    } catch (e) {
      _presetsReady = true;
    }
  }

  _savePresets() async {
    _buildCategoryCache();

    Map<String, dynamic> file = _createFileOuterObject(presetsData);

    String jsonData = json.encode(file);
    await _presetsFile!.writeAsString(jsonData);
    notifyListeners();
  }

  _createFileOuterObject(List<dynamic> data) {
    Map<String, dynamic> file = {"Version": presetsVersion, "Categories": data};
    return file;
  }

  Future waitLoading() async {
    for (int i = 0; i < 20; i++) {
      if (_presetsReady) break;
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  List<String> getCategories() {
    return _categoriesCache;
  }

  _buildCategoryCache() {
    _categoriesCache.clear();
    for (var element in presetsData) {
      _categoriesCache.add(element["name"]);
    }
  }

  Map<String, dynamic>? _findCategory(String category) {
    for (Map<String, dynamic> cat in presetsData) {
      if (cat["name"] == category) return cat;
    }
    return null;
  }

  bool presetExists(String name, String category) =>
      findPreset(name, category) != null;

  Map<String, dynamic>? findPreset(String name, String category) {
    var cat = _findCategory(category);

    return findPresetInCategory(name, cat);
  }

  Map<String, dynamic>? findPresetInCategory(
      String name, Map<String, dynamic>? category) {
    if (category != null) {
      for (Map<String, dynamic> preset in category["presets"]) {
        if (preset["name"] == name) return preset;
      }
    }
    return null;
  }

  dynamic findPresetByUuid(String uuid) {
    for (var cat in presetsData) {
      for (var preset in cat["presets"]) {
        if (preset[uuidKey] == uuid) return preset;
      }
    }
    return null;
  }

  dynamic findAdjacentPreset(
      String uuid, bool acrossCategories, PresetChangeDirection direction) {
    int catsCount = presetsData.length;
    int catIndex = 0;

    if (uuid.isEmpty) {
      return _getAdjacentPreset(0, -1, direction, acrossCategories);
    }
    for (catIndex = 0; catIndex < catsCount; catIndex++) {
      int pIndex = 0;
      var cat = presetsData[catIndex];
      var presets = cat["presets"];
      int pCount = presets.length;
      for (pIndex = 0; pIndex < pCount; pIndex++) {
        if (presets[pIndex]?["uuid"] == uuid) {
          return _getAdjacentPreset(
              catIndex, pIndex, direction, acrossCategories);
        }
      }
    }
    return _getAdjacentPreset(0, -1, direction, acrossCategories);
  }

  Map<String, dynamic>? findCategoryOfPreset(Map<String, dynamic> preset) {
    for (var cat in presetsData) {
      for (var pr in cat["presets"]) {
        if (pr[uuidKey] == preset[uuidKey]) return cat;
      }
    }
    return null;
  }

  Map<String, dynamic> _findOrCreateCategory(String name) {
    var category = _findCategory(name);

    if (category == null) {
      category = {"name": name, "uuid": uuid.v4(), "presets": []};
      presetsData.add(category);
    }

    return category;
  }

  String savePreset(
      Map<String, dynamic> preset, String name, String categoryName) {
    preset["name"] = name;
    String uuid;
    bool newPreset = false;
    var category = _findOrCreateCategory(categoryName);

    var data = findPresetInCategory(name, category);
    if (data != null) {
      //overwrite preset
      for (var key in preset.keys) {
        if (key != uuidKey) data[key] = preset[key];
      }
      uuid = data[uuidKey];
    } else {
      _addUuid(preset);
      category["presets"].add(preset);
      uuid = preset[uuidKey];
      newPreset = true;
    }

    if (newPreset) {
      _presetCreated(preset);
    } else {
      _presetUpdated(preset);
    }
    _savePresets();
    return uuid;
  }

  Future deletePreset(Map<String, dynamic> preset) {
    var cat = findCategoryOfPreset(preset);

    if (cat != null) {
      _presetDeleted(preset["uuid"]);
      (cat["presets"] as List).remove(preset);
      return _savePresets();
    }

    return Future.error("Preset not found");
  }

  Future duplicatePreset(String category, String name) {
    var cat = _findCategory(category);

    if (cat != null) {
      List presets = cat["presets"];

      for (int i = 0; i < presets.length; i++) {
        if (presets[i]["name"] == name) {
          var clone = json.decode(json.encode(presets[i]));

          //get new uuid

          _addUuid(clone);

          String? lName = _findFreeName(name, category);
          if (lName != null) {
            clone["name"] = lName;
            cat["presets"].insert(i + 1, clone);
            return _savePresets();
          }
        }
      }
    }
    return Future.error("Can't clone preset");
  }

  Future renamePreset(Map<String, dynamic> preset, String newName) {
    preset["name"] = newName;
    _presetUpdated(preset);
    return _savePresets();
  }

  void reorderCategories(int oldListIndex, int newListIndex) {
    var movedList = presetsData.removeAt(oldListIndex);
    presetsData.insert(newListIndex, movedList);
    _categoryReordered(oldListIndex, newListIndex);
    _savePresets();
  }

  bool reorderPresets(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    var preset = presetsData[oldListIndex]["presets"][oldItemIndex];
    var newCatName = presetsData[newListIndex];

    //if preset with the same name exists, avoid reordering
    if (oldListIndex != newListIndex &&
        findPresetInCategory(preset["name"], newCatName) != null) {
      return false;
    }

    var movedItem = presetsData[oldListIndex]["presets"].removeAt(oldItemIndex);
    presetsData[newListIndex]["presets"].insert(newItemIndex, movedItem);

    _savePresets();
    return true;
  }

  clearNewFlag(Map<String, dynamic> preset) {
    if (preset.containsKey("new")) {
      preset.remove("new");
      _savePresets();
    }
  }

  Future changeChannel(Map<String, dynamic> preset, int channel) {
    preset["channel"] = channel;
    return _savePresets();
  }

  Future changePresetCategory(
      String category, String name, String newCategory) {
    var cat1 = _findCategory(category);
    var cat2 = _findCategory(newCategory);
    if (cat1 != null && cat2 != null) {
      var p = findPresetInCategory(name, cat1);
      if (p != null) {
        (cat1["presets"] as List).remove(p);
        (cat2["presets"] as List).add(p);
        return _savePresets();
      }
    }

    return Future.error("Preset not found");
  }

  Future<List<String>> deleteCategory(String category) async {
    bool modified = false;

    var cat = _findCategory(category);

    if (cat != null) {
      List<String> uuids = [];
      List presets = cat["presets"];

      for (var p in presets) {
        uuids.add(p[uuidKey]);
      }
      presetsData.remove(cat);

      for (var uuid in uuids) {
        _presetDeleted(uuid);
      }

      await _savePresets();
      return uuids;
    }

    return Future.error("Category not found");
  }

  Future renameCategory(String category, String newName) {
    var cat = _findCategory(category);

    if (cat != null) {
      cat["name"] = newName;
      return _savePresets();
    }

    return Future.error("Category not found");
  }

  String? presetToJson(String category, String name) {
    var finalData = <String, dynamic>{};

    var p = findPreset(name, category);

    if (p != null) {
      var copy = json.decode(json.encode(p));
      finalData["type"] = presetsSingle;

      copy["category"] = category;
      finalData["data"] = copy;
      return json.encode(finalData);
    }

    return null;
  }

  //converts a category to json
  //if parameter left empty, then the full preset list is converted
  String? presetsToJson([String? category]) {
    //TODO: These presets don't have the category key
    List presets = [];
    if (category == null || category.isEmpty) {
      for (var cat in presetsData) {
        for (var p in cat["presets"]) {
          var copy = json.decode(json.encode(p));
          copy["category"] = cat["name"];
          presets.add(copy);
        }
      }
    } else {
      for (var p in _findCategory(category)?["presets"]) {
        var copy = json.decode(json.encode(p));
        copy["category"] = category;
        presets.add(copy);
      }
    }

    if (presets.isNotEmpty) {
      var finalData = <String, dynamic>{};
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
    var p = findPreset(name, category);

    presetData = fixPresetCompatibility(presetData);
    presetData.remove("category");

    String? _name = name;
    //check if exists
    if (p != null) {
      if (_presetsEquivalent(presetData, p)) return;

      //difference - find free name and save as that
      _name = _findFreeName(name, category);
    }

    //highlight that the preset is new
    presetData["new"] = true;

    //save preset
    if (_name != null) savePreset(presetData, _name, category);
  }

  dynamic _getAdjacentPreset(int catIndex, int pIndex,
      PresetChangeDirection direction, bool acrossCategory) {
    if (presetsData.length <= catIndex) return null;
    var catLength = presetsData[catIndex]["presets"].length;
    if (direction == PresetChangeDirection.previous) {
      pIndex--;
    } else {
      pIndex++;
    }

    if (pIndex < 0) {
      if (!acrossCategory) {
        pIndex = catLength - 1;
      } else {
        do {
          catIndex--;
          if (catIndex < 0) {
            catIndex = presetsData.length - 1;
          }
        } while (presetsData[catIndex]["presets"].length == 0);
        pIndex = presetsData[catIndex]["presets"].length - 1;
      }
    } else if (pIndex >= catLength) {
      if (!acrossCategory) {
        pIndex = 0;
      } else {
        do {
          catIndex++;
          if (catIndex >= presetsData.length) {
            catIndex = 0;
          }
        } while (presetsData[catIndex]["presets"].length == 0);
        pIndex = 0;
      }
    }
    return presetsData[catIndex]["presets"][pIndex];
  }

  String? _findFreeName(String name, String category) {
    for (int i = 1; i < 1000; i++) {
      RegExp regex = RegExp(r"\((\d+)\)$");
      String newName = "";

      RegExpMatch? match = regex.firstMatch(name);
      if (match != null) {
        //already has a number in the name
        String? numStr = match.group(1);
        if (numStr != null) {
          int? num = int.tryParse(numStr);
          if (num != null) {
            num++;
            newName = name.replaceFirst(regex, "($num)");
            name = newName;
          }
        }
      }

      if (newName == "") {
        newName = "$name ($i)";
      }
      if (findPreset(newName, category) == null) return newName;
    }

    return null;
  }

  bool _presetsEquivalent(Map<String, dynamic> p1, Map<String, dynamic> p2) {
    for (String k in p1.keys) {
      if (k == "uuid") continue;
      if (!p2.containsKey(k)) return false;

      //check sub-maps
      if (p1[k] is Map && p2[k] is Map) {
        bool equal = _presetsEquivalent(p1[k], p2[k]);
        if (equal == false) return false;
        continue;
      }

      if (p1[k] != p2[k]) return false;
    }
    return true;
  }

  Map<String, dynamic> fixPresetCompatibility(Map<String, dynamic> presetData) {
    //old style preset didn't contain mighty plug
    if (!presetData.containsKey("product_id")) {
      presetData["product_id"] = NuxMightyPlug.defaultNuxId;
    }
    if (!presetData.containsKey(uuidKey)) {
      _addUuid(presetData);
    }
    return presetData;
  }

  void upgradeDataVersion(int version) {
    if (version < 2) {
      //add guids to categories
      for (Map cat in presetsData) {
        if (!cat.containsKey("uuid")) {
          cat["uuid"] = uuid.v4();
        }
      }
    }
  }

  List<dynamic> _getPresetsInCategoryOldFormat(
      List<dynamic> oldPresets, String category) {
    List<dynamic> presets = [];
    for (int i = 0; i < oldPresets.length; i++) {
      if (oldPresets[i]["category"] == category) presets.add(oldPresets[i]);
    }
    return presets;
  }

  Map<String, dynamic> _convertOldToNewFormat(List<dynamic> oldFormat) {
    _buildCategoryCache();
    var old = json.encode(presetsData);

    //build categories list
    List<String> categoriesList = [];
    for (var element in oldFormat) {
      if (!categoriesList.contains(element["category"])) {
        categoriesList.add(element["category"]);
      }
    }

    List<Map<String, dynamic>> categories = [];

    for (var cat in categoriesList) {
      Map<String, dynamic> category = {};
      category["name"] = cat;
      var presets = _getPresetsInCategoryOldFormat(oldFormat, cat);

      for (Map preset in presets) {
        preset.remove("category");
      }
      category["presets"] = presets;
      categories.add(category);
    }

    Map<String, dynamic> file = _createFileOuterObject(categories);

    return file;
  }

  void _addUuid(Map<String, dynamic> preset) {
    bool unique = true;
    do {
      String id = uuid.v4();
      // check unique
      for (var cat in presetsData) {
        for (var p in cat["presets"]) {
          if (p[uuidKey] == id) unique = false;
        }
      }
      preset[uuidKey] = id;
    } while (unique == false);
  }

  void registerPresetStorageListener(PresetStorageListener listener) {
    _changeListeners.add(listener);
  }

  void _presetCreated(Map<String, dynamic> preset) {
    for (var listener in _changeListeners) {
      listener.onPresetCreated(preset);
    }
  }

  void _presetUpdated(Map<String, dynamic> preset) {
    for (var listener in _changeListeners) {
      listener.onPresetUpdated(preset);
    }
  }

  void _presetDeleted(String uuid) {
    for (var listener in _changeListeners) {
      listener.onPresetDeleted(uuid);
    }
  }

  void _categoryReordered(int from, int to) {
    for (var listener in _changeListeners) {
      listener.onCategoryReordered(from, to);
    }
  }
}
