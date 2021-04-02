import 'package:mighty_plug_manager/audio/models/trackAutomation.dart';

class JamTrack {
  TrackAutomation _automation = TrackAutomation();

  String _path = "";
  String _name = "";
  String _uuid = "";

  TrackAutomation get automation => _automation;

  JamTrack(
      {required path,
      required name,
      required uuid,
      List<dynamic>? automationData}) {
    _path = path;
    _name = name;
    _uuid = uuid;
    if (automationData != null) _automation.fromJson(automationData);
  }

  String get name => _name;
  String get path => _path;
  String get uuid => _uuid;

  set name(value) => _name = value;

  factory JamTrack.fromJson(dynamic json) {
    return JamTrack(
        name: json['name'] as String,
        path: json['path'] as String,
        uuid: json['uuid'] as String,
        automationData: json["events"]);
  }

  Map<String, dynamic> toJson() {
    var data = Map<String, dynamic>();
    data["path"] = _path;
    data["name"] = _name;
    data["uuid"] = _uuid;
    data["events"] = automation.toJson();
    return data;
  }
}
