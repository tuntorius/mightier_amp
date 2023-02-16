class MidiConstants {
  static const NoteOn = 0x90;
  static const NoteOff = 0x80;
  static const PolyAfterTouch = 0xa0;
  static const ControlChange = 0xb0;
  static const ProgramChange = 0xc0;
  static const ChannelPressure = 0xd0;
  static const PitchBend = 0xe0;
}

enum HotkeyControl {
  PreviousChannel,
  NextChannel,
  ChannelByIndex,
  EffectSlotEnable,
  EffectSlotDisable,
  EffectSlotToggle,
  ParameterSet,
  EffectDecrement,
  EffectIncrement,
}

enum HotkeyCategory { Channels, EffectSlots, EffectParameters }
