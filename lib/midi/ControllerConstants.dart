import 'package:flutter/material.dart';

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
  DelayTapTempo,
  MasterVolumeSet,
  EffectDecrement,
  EffectIncrement,
  DrumsStartStop,
  DrumsVolume,
  DrumsTempoMinus1,
  DrumsTempoPlus1,
  DrumsTempoMinus5,
  DrumsTempoPlus5,
  DrumsTempoTap,
  DrumsPreviousStyle,
  DrumsNextStyle,
  LooperRecord,
  LooperStop,
  LooperClear,
  LooperUndoRedo,
  LooperLevel,
  JamTracksPlayPause,
  JamTracksPreviousTrack,
  JamTracksNextTrack,
  JamTracksRewind,
  JamTracksFF,
  JamTracksABRepeat,
  PreviousPresetGlobal,
  NextPresetGlobal,
  PreviousPresetCategory,
  NextPresetCategory
}

extension HotkeyLabel on HotkeyControl {
  String? get label {
    switch (this) {
      case HotkeyControl.DrumsStartStop:
        return 'Start/Stop';
      case HotkeyControl.DrumsVolume:
        return 'Volume';
      case HotkeyControl.DrumsTempoMinus1:
        return 'Tempo -1';
      case HotkeyControl.DrumsTempoPlus1:
        return 'Tempo +1';
      case HotkeyControl.DrumsTempoMinus5:
        return 'Tempo -5';
      case HotkeyControl.DrumsTempoPlus5:
        return 'Tempo +5';
      case HotkeyControl.DrumsTempoTap:
        return "Tap Tempo";
      case HotkeyControl.DrumsPreviousStyle:
        return "Previous Style";
      case HotkeyControl.DrumsNextStyle:
        return "Next Style";

      case HotkeyControl.LooperRecord:
        return 'Record/Play/Overdub';
      case HotkeyControl.LooperStop:
        return "Stop";
      case HotkeyControl.LooperClear:
        return "Clear";
      case HotkeyControl.LooperUndoRedo:
        return "Undo/Redo";
      case HotkeyControl.LooperLevel:
        return "Level";

      case HotkeyControl.JamTracksPlayPause:
        return "Play/Pause";
      case HotkeyControl.JamTracksPreviousTrack:
        return "Previous Track";
      case HotkeyControl.JamTracksNextTrack:
        return "Next Track";
      case HotkeyControl.JamTracksRewind:
        return "Rewind";
      case HotkeyControl.JamTracksFF:
        return "Fast Forward";
      case HotkeyControl.JamTracksABRepeat:
        return "A-B Repeat";
      default:
        return null;
    }
  }

  IconData? get icon {
    switch (this) {
      case HotkeyControl.DrumsStartStop:
        return Icons.play_arrow;
      case HotkeyControl.DrumsVolume:
        return Icons.volume_up;
      case HotkeyControl.DrumsTempoMinus1:
        return Icons.keyboard_arrow_left;
      case HotkeyControl.DrumsTempoPlus1:
        return Icons.keyboard_arrow_right;
      case HotkeyControl.DrumsTempoMinus5:
        return Icons.keyboard_double_arrow_left;
      case HotkeyControl.DrumsTempoPlus5:
        return Icons.keyboard_double_arrow_right;
      case HotkeyControl.DrumsTempoTap:
        return Icons.touch_app;
      case HotkeyControl.DrumsPreviousStyle:
        return Icons.keyboard_arrow_up;
      case HotkeyControl.DrumsNextStyle:
        return Icons.keyboard_arrow_down;
      case HotkeyControl.LooperRecord:
        return Icons.fiber_manual_record;
      case HotkeyControl.LooperStop:
        return Icons.stop;
      case HotkeyControl.LooperClear:
        return Icons.clear;
      case HotkeyControl.LooperUndoRedo:
        return Icons.undo;
      case HotkeyControl.LooperLevel:
        return Icons.volume_up;
      case HotkeyControl.JamTracksPlayPause:
        return Icons.play_arrow;
      case HotkeyControl.JamTracksPreviousTrack:
        return Icons.skip_previous;
      case HotkeyControl.JamTracksNextTrack:
        return Icons.skip_next;
      case HotkeyControl.JamTracksRewind:
        return Icons.fast_rewind;
      case HotkeyControl.JamTracksFF:
        return Icons.fast_forward;
      case HotkeyControl.JamTracksABRepeat:
        return Icons.repeat;
      default:
        return null;
    }
  }

  bool get sliderMode {
    switch (this) {
      case HotkeyControl.ParameterSet:
      case HotkeyControl.DrumsVolume:
      case HotkeyControl.LooperLevel:
        return true;
      default:
        return false;
    }
  }
}

enum HotkeyCategory {
  Channels,
  EffectSlots,
  EffectParameters,
  Drums,
  JamTracks,
  Looper
}
