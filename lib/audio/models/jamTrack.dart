import 'package:mighty_plug_manager/audio/models/trackAutomation.dart';

class JamTrack {
  final TrackAutomation _automation = TrackAutomation();

  String _path = "";
  String _name = "";
  String _uuid = "";

  bool _loopEnable = false;
  bool _useLoopPoints = false;
  int _loopTimes = 0;

  double _speed = 1;
  int _pitch = 0;

  TrackAutomation get automation => _automation;

  JamTrack(
      {required path,
      required name,
      required uuid,
      bool loopEnable = false,
      bool useLoopPoints = false,
      int loopTimes = 0,
      double speed = 1,
      int pitch = 0,
      List<dynamic>? automationData}) {
    _path = path;
    _name = name;
    _uuid = uuid;
    _loopEnable = loopEnable;
    _useLoopPoints = useLoopPoints;
    _loopTimes = loopTimes;
    _speed = speed;
    _pitch = pitch;
    if (automationData != null) _automation.fromJson(automationData);
  }

  String get name => _name;
  String get path => _path;
  set path(val) => _path = val;
  String get uuid => _uuid;

  set name(value) => _name = value;

  bool get loopEnable => _loopEnable;
  set loopEnable(val) => _loopEnable = val;

  bool get useLoopPoints => _useLoopPoints;
  set useLoopPoints(val) => _useLoopPoints = val;

  int get loopTimes => _loopTimes;
  set loopTimes(val) => _loopTimes = val;

  double get speed => _speed;
  set speed(val) => _speed = val;

  int get pitch => _pitch;
  set pitch(val) => _pitch = val;

  factory JamTrack.fromJson(dynamic json) {
    return JamTrack(
        name: json['name'] as String,
        path: json['path'] as String,
        uuid: json['uuid'] as String,
        loopEnable: json['loop_enable'] ?? false,
        useLoopPoints: json['loop_use_points'] ?? false,
        loopTimes: json['loop_times'] ?? 0,
        speed: json['speed'] ?? 1,
        pitch: json['pitch'] ?? 0,
        automationData: json["events"]);
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data["path"] = _path;
    data["name"] = _name;
    data["uuid"] = _uuid;
    data["events"] = automation.toJson();
    data['loop_enable'] = _loopEnable;
    data['loop_use_points'] = _useLoopPoints;
    data['loop_times'] = _loopTimes;
    data['speed'] = _speed;
    data['pitch'] = _pitch;
    return data;
  }
}
