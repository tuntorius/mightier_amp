// (c) mighty-nam custom firmware — DSP processor stub.
// MIDI/SysEx transmission mapping is deferred to a later step.

import '../../../devices/effects/MidiControllerHandles.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

/// Pitch shifter processor for the mighty-nam firmware.
///
/// The "Pitch" parameter represents a semitone shift in the range -12 to +12.
/// [ValueFormatters.percentage] is used as a stand-in (0–100 maps to the full
/// range); the exact formatter will be replaced once the firmware protocol is
/// known.
///
/// All [Parameter.midiCC] and [Parameter.devicePresetIndex] values are
/// set to 0 as placeholders.
class NamPitch extends Processor {
  @override
  final String name = "Pitch";

  @override
  int get nuxIndex => 102;

  @override
  int? get nuxEffectTypeIndex => null;

  @override
  int? get nuxEnableIndex => null;

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;

  // Dummy values — replace with mighty-nam CC map when available.
  @override
  int get midiCCEnableValue => 0;

  @override
  int get midiCCSelectionValue => 0;

  // No foot-controller mapping defined yet.
  @override
  MidiControllerHandle? get midiControlOff => null;
  @override
  MidiControllerHandle? get midiControlOn => null;
  @override
  MidiControllerHandle? get midiControlToggle => null;
  @override
  MidiControllerHandle? get midiControlPrev => null;
  @override
  MidiControllerHandle? get midiControlNext => null;

  @override
  List<Parameter> parameters = [
    // Represents semitone shift (-12 to +12).
    // Using percentage as a placeholder formatter until a dedicated
    // semitone formatter is introduced.
    Parameter(
      name: "Pitch",
      handle: "pitch",
      value: 0,
      formatter: ValueFormatters.percentage,
      devicePresetIndex: 0,
      midiCC: 0,
    ),
    Parameter(
      name: "Mix",
      handle: "mix",
      value: 50,
      formatter: ValueFormatters.percentage,
      devicePresetIndex: 1,
      midiCC: 0,
    ),
  ];
}

