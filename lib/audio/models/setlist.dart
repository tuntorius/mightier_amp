import 'package:mighty_plug_manager/audio/models/jamTrack.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';

class SetlistItem {
  String trackUuid = "";
  JamTrack? trackReference;

  SetlistItem({required this.trackUuid, required this.trackReference});
}

class Setlist {
  String name = "";
  List<SetlistItem> items = <SetlistItem>[];

  Setlist(_name, List _items) {
    name = _name;
    for (int i = 0; i < _items.length; i++) addTrackByUuid(_items[i]);
  }

  void addTrackByUuid(String uuid) {
    JamTrack? track = TrackData().findByUuid(uuid);
    if (track != null)
      items.add(SetlistItem(trackUuid: track.uuid, trackReference: track));
    else
      print("Track with uuid $uuid not found!");
  }

  void addTrack(JamTrack track) {
    items.add(SetlistItem(trackUuid: track.uuid, trackReference: track));
  }

  void clear() {
    items.clear();
  }

  factory Setlist.fromJson(Map<String, dynamic> json) {
    return Setlist(json["name"] ?? "Untitled", json["tracks"]);
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    var tracks = <String>[];
    for (int i = 0; i < items.length; i++) tracks.add(items[i].trackUuid);

    json["name"] = name;
    json["tracks"] = tracks;
    return json;
  }
}
