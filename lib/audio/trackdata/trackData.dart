// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:convert';
import 'dart:io';
import 'package:mighty_plug_manager/audio/models/jamTrack.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class TrackData {
  static final TrackData _storage = TrackData._();
  static const tracksFile = "tracks.json";

  final Uuid uuid = Uuid();

  factory TrackData() {
    return _storage;
  }

  String tracksPath = "";
  late Directory? storageDirectory;
  late File _tracksFile;

  List<JamTrack> _tracksData = <JamTrack>[];
  List<JamTrack> get tracks => _tracksData;

  TrackData._() {
    _init();
  }

  _init() async {
    _tracksData = <JamTrack>[];
    await _getDirectory();
    await _loadTracks();
  }

  _getDirectory() async {
    if (Platform.isAndroid) {
      storageDirectory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      storageDirectory = await getApplicationDocumentsDirectory();
    }
    tracksPath = path.join(storageDirectory?.path ?? "", tracksFile);
    _tracksFile = File(tracksPath);
  }

  _loadTracks() async {
    try {
      var _presetJson = await _tracksFile.readAsString();
      var data = json.decode(_presetJson);
      _tracksData =
          data.map<JamTrack>((json) => JamTrack.fromJson(json)).toList();
    } catch (e) {
      print(e);
      //   //no file
      //   print("Presets file not available");
    }
  }

  addTrack(String file, String name) {
    _tracksData.add(JamTrack(name: name, path: file, uuid: _generateUuid()));
    _saveTracks();
  }

  _saveTracks() async {
    String _json = json.encode(_tracksData);
    await _tracksFile.writeAsString(_json);
  }

  String _generateUuid() {
    String id = "";
    bool unique = true;
    do {
      String id = uuid.v4();
      // check unique
      _tracksData.forEach((element) {
        if (element.uuid == id) unique = false;
      });
    } while (unique == false);
    return id;
  }
}
