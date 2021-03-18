class JamTrack {
  String _path;
  String _name;

  JamTrack({path, name}) {
    _path = path;
    _name = name;
  }

  String get name => _name;
  String get path => _path;

  factory JamTrack.fromJson(dynamic json) {
    return JamTrack(name: json['name'] as String, path: json['path'] as String);
  }

  fromJson(Map<String, dynamic> data) {
    _path = data["path"];
    _name = data["name"];
  }

  Map<String, dynamic> toJson() {
    var data = Map<String, dynamic>();
    data["path"] = _path;
    data["name"] = _name;

    return data;
  }
}
