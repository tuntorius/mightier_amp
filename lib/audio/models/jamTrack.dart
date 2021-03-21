class JamTrack {
  String _path = "";
  String _name = "";
  String _uuid = "";

  JamTrack({required path, required name, required uuid}) {
    _path = path;
    _name = name;
    _uuid = uuid;
  }

  String get name => _name;
  String get path => _path;
  String get uuid => _uuid;

  factory JamTrack.fromJson(dynamic json) {
    return JamTrack(
        name: json['name'] as String,
        path: json['path'] as String,
        uuid: json['uuid'] as String);
  }

  Map<String, dynamic> toJson() {
    var data = Map<String, dynamic>();
    data["path"] = _path;
    data["name"] = _name;
    data["uuid"] = _uuid;
    return data;
  }
}
