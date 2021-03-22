// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';

enum AutomationEventType { preset, loop }

class AutomationEvent {
  AutomationEventType type;
  Duration eventTime;

  bool cabinetLevelOverrideEnable = false;
  double cabinetLevelOverride = 0;
  String get name => _preset.containsKey("name") ? _preset["name"] : "";
  int get channel => _preset.containsKey("channel") ? _preset["channel"] : 0;
  //uuids for presets per each device
  String _presetUuid = "";

  //values if type is presetChange
  Map _preset = {};

  AutomationEvent({required this.eventTime, required this.type});

  void setPresetUuid(String presetUuid) {
    _presetUuid = presetUuid;
    if (presetUuid == "") return;
    var _p = PresetsStorage().findPresetByUuid(presetUuid);
    if (_p != null) {
      if (_p.containsKey("cabinet"))
        cabinetLevelOverride = _p["cabinet"]["level"];
      _preset = _p;
    }
  }

  String getPresetUuid() {
    return _presetUuid;
  }

  dynamic getPreset() {
    return _preset;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["type"] = type.index;
    data["time"] = eventTime.inMilliseconds;
    data["preset_id"] = _presetUuid;
    data["cab_override"] = cabinetLevelOverrideEnable;
    data["cab_level"] = cabinetLevelOverride;

    return data;
  }

  factory AutomationEvent.fromJson(dynamic json) {
    var type = AutomationEventType.values[json["type"] ?? 0];
    Duration time = Duration(milliseconds: json["time"] ?? 0);
    AutomationEvent _event = AutomationEvent(eventTime: time, type: type);
    _event.setPresetUuid(json['preset_id'] ?? "");
    _event.cabinetLevelOverrideEnable = json["cab_override"] ?? false;
    _event.cabinetLevelOverride = json["cab_level"] ?? 0;
    return _event;
  }
}

class TrackAutomation {
  AutomationEvent _initialEvent = AutomationEvent(
      eventTime: Duration(seconds: 0), type: AutomationEventType.preset);

  final _events = <AutomationEvent>[];

  List<AutomationEvent> get events => _events;
  AutomationEvent get initialEvent => _initialEvent;

  TrackAutomation();
  fromJson(List<dynamic> jsonData) {
    if (jsonData.length > 0)
      _initialEvent = AutomationEvent.fromJson(jsonData[0]);

    for (int i = 1; i < jsonData.length; i++)
      events.add(AutomationEvent.fromJson(jsonData[i]));
  }

  void sortEvents() {
    _events.sort((a, b) => a.eventTime.compareTo(b.eventTime));
  }

  List<dynamic> toJson() {
    List<Map<String, dynamic>> ev = [];

    ev.add(initialEvent.toJson());

    for (int i = 0; i < events.length; i++) ev.add(events[i].toJson());
    return ev;
  }
}
