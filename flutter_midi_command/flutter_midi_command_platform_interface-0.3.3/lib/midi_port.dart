enum MidiPortType { IN, OUT }

class MidiPort {
  MidiPortType type;
  int id;
  bool connected = false;

  MidiPort(this.id, this.type);

  Map<String, Object> get toDictionary {
    return {"id": id, "type": type.toString(), "connected": connected};
  }
}
