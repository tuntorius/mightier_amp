// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:convert';
import 'dart:io';
import 'package:audio_picker/audio_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mighty_plug_manager/audio/models/jamTrack.dart';
import 'package:mighty_plug_manager/audio/models/setlist.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../platform/platformUtils.dart';

class TrackData {
  static final TrackData _storage = TrackData._();
  static const tracksFile = "tracks.json";
  static const setlistsFile = "setlists.json";

  final Uuid uuid = const Uuid();

  factory TrackData() {
    return _storage;
  }

  String tracksPath = "";
  String setlistsPath = "";
  late Directory? storageDirectory;
  late File _tracksFile, _setlistsFile;

  List<JamTrack> _tracksData = <JamTrack>[];
  List<JamTrack> get tracks => _tracksData;

  List<Setlist> _setlistsData = <Setlist>[];
  final Setlist _allTracks = Setlist("All Tracks", []);
  List<Setlist> get setlistsFull => [_allTracks] + _setlistsData;
  Setlist get allTracks => _allTracks;
  List<Setlist> get setlists => _setlistsData;

  bool _tracksReady = false;

  TrackData._() {
    _init();
  }

  _init() async {
    _tracksData = <JamTrack>[];
    await _getDirectory();
    await _loadTracks();
    AudioPicker().regusterOnStaleBookmark(_onBookmarkUpdated);
  }

  _getDirectory() async {
    storageDirectory = await PlatformUtils.getAppDataDirectory();
    tracksPath = path.join(storageDirectory?.path ?? "", tracksFile);
    setlistsPath = path.join(storageDirectory?.path ?? "", setlistsFile);
    _tracksFile = File(tracksPath);
    _setlistsFile = File(setlistsPath);
  }

  _loadTracks() async {
    try {
      var exists = await _tracksFile.exists();
      if (exists) {
        var tracksJson = await _tracksFile.readAsString();
        var data = json.decode(tracksJson);
        _tracksData =
            data.map<JamTrack>((json) => JamTrack.fromJson(json)).toList();

        //read setlists
        exists = await _setlistsFile.exists();
        if (exists) {
          var setlistsJson = await _setlistsFile.readAsString();
          data = json.decode(setlistsJson);

          _setlistsData =
              data.map<Setlist>((json) => Setlist.fromJson(json)).toList();
        }
        _createAllTracksSetlist();
      }
      _tracksReady = true;
    } catch (e) {
      debugPrint(e.toString());
      //still ready
      _tracksReady = true;
      //   //no file
      //   print("Presets file not available");
    }
  }

  _createAllTracksSetlist() {
    _allTracks.clear();
    for (int i = 0; i < _tracksData.length; i++) {
      _allTracks.addTrack(_tracksData[i]);
    }
  }

  Future waitLoading() async {
    for (int i = 0; i < 20; i++) {
      if (_tracksReady) break;
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  addTrack(String file, String name, bool save) {
    _tracksData.add(JamTrack(
      name: name,
      path: file,
      uuid: _generateUuid(),
    ));
    if (save) saveTracks();
  }

  JamTrack? findByUuid(String uuid) {
    for (int i = 0; i < _tracksData.length; i++) {
      if (_tracksData[i].uuid == uuid) return _tracksData[i];
    }

    return null;
  }

  removeTrack(JamTrack track) async {
    if (_tracksData.contains(track)) {
      _tracksData.remove(track);

      bool tracklistChanged = false;
      //remove any setlist instances
      for (int i = 0; i < _setlistsData.length; i++) {
        for (int j = _setlistsData[i].items.length - 1; j >= 0; j--) {
          if (_setlistsData[i].items[j].trackUuid == track.uuid) {
            _setlistsData[i].items.removeAt(j);
            tracklistChanged = true;
          }
        }
      }

      if (tracklistChanged) await saveSetlists();

      await saveTracks();
    }
  }

  removeTracks(List<JamTrack> tracks) async {
    bool tracklistChanged = false;
    for (var element in tracks) {
      _tracksData.remove(element);

      //remove any setlist instances
      for (int i = 0; i < _setlistsData.length; i++) {
        for (int j = _setlistsData[i].items.length - 1; j >= 0; j--) {
          if (_setlistsData[i].items[j].trackUuid == element.uuid) {
            _setlistsData[i].items.removeAt(j);
            tracklistChanged = true;
          }
        }
      }
    }

    if (tracklistChanged) await saveSetlists();
    await saveTracks();
  }

  bool isPresetInUse(String presetUuid) {
    for (int i = 0; i < _tracksData.length; i++) {
      if (_tracksData[i].automation.initialEvent.getPresetUuid() ==
          presetUuid) {
        return true;
      }
      var e = _tracksData[i].automation.events;
      for (int j = 0; j < e.length; j++) {
        if (e[j].getPresetUuid() == presetUuid) return true;
      }
    }
    return false;
  }

  bool isAnyPresetInUse(List<String> presetsUuid) {
    for (int i = 0; i < _tracksData.length; i++) {
      if (presetsUuid.contains(
          _tracksData[i].automation.initialEvent.getPresetUuid())) return true;
      var e = _tracksData[i].automation.events;
      for (int j = 0; j < e.length; j++) {
        if (presetsUuid.contains(e[j].getPresetUuid())) return true;
      }
    }
    return false;
  }

  void removePresetInstances(String presetUuid) {
    for (int i = 0; i < _tracksData.length; i++) {
      if (_tracksData[i].automation.initialEvent.getPresetUuid() ==
          presetUuid) {
        _tracksData[i].automation.initialEvent.clearPreset();
      }

      var e = _tracksData[i].automation.events;
      for (int j = e.length - 1; j >= 0; j--) {
        if (e[j].getPresetUuid() == presetUuid) e[j].clearPreset();
      }
    }
    saveTracks();
  }

  void removeMultiplePresetsInstances(List<String> presetsUuid) {
    for (int i = 0; i < _tracksData.length; i++) {
      if (presetsUuid
          .contains(_tracksData[i].automation.initialEvent.getPresetUuid())) {
        _tracksData[i].automation.initialEvent.clearPreset();
      }

      var e = _tracksData[i].automation.events;
      for (int j = e.length - 1; j >= 0; j--) {
        var uuid = e[j].getPresetUuid();
        if (presetsUuid.contains(uuid)) {
          e[j].clearPreset();
        }
      }
    }
    saveTracks();
  }

  saveTracks() async {
    _createAllTracksSetlist();
    String jsonData = json.encode(_tracksData);
    await _tracksFile.writeAsString(jsonData);
  }

  addSetlist(String name) {
    var setlist = Setlist(name, []);
    _setlistsData.add(setlist);
    saveSetlists();
  }

  Setlist? findSetlist(String name) {
    for (int i = 0; i < _setlistsData.length; i++) {
      if (_setlistsData[i].name == name) return _setlistsData[i];
    }
    return null;
  }

  removeSetlist(Setlist setlist) async {
    if (_setlistsData.contains(setlist)) {
      _setlistsData.remove(setlist);
      await saveSetlists();
    }
  }

  saveSetlists() async {
    String jsonData = json.encode(_setlistsData);
    await _setlistsFile.writeAsString(jsonData);
  }

  String _generateUuid() {
    String id = "";
    bool unique = true;
    do {
      id = uuid.v4();
      // check unique
      for (var element in _tracksData) {
        if (element.uuid == id) unique = false;
      }
    } while (unique == false);
    return id;
  }

  void _onBookmarkUpdated(String oldBookmark, String newBookmark)
  {
    for (var track in _tracksData)
    {
      if (track.path == oldBookmark) {
        track.path = newBookmark;
        saveTracks();
      }

    }
  }
}
