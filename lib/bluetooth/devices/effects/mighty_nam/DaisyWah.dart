// (c) mighty-nam custom firmware — DSP processor stub.
// MIDI/SysEx transmission mapping is deferred to a later step.

import '../../../devices/effects/MidiControllerHandles.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

/// Daisy Wah processor for the mighty-nam firmware.
///
/// All [Parameter.midiCC] and [Parameter.devicePresetIndex] values are
/// set to 0 as placeholders; they will be mapped to the actual custom
/// SysEx/MIDI protocol in a later step.
class DaisyWah extends Processor {
  @override
  final String name = "Daisy Wah";

  @override
  int get nuxIndex => 103;

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
    Parameter(
      name: "Sensitivity",
      handle: "sense",
      value: 50,
      formatter: ValueFormatters.percentage,
      devicePresetIndex: 0,
      midiCC: 0,
    ),
    Parameter(
      name: "Resonance",
      handle: "res",
      value: 50,
      formatter: ValueFormatters.percentage,
      devicePresetIndex: 1,
      midiCC: 0,
    ),
    Parameter(
      name: "Mix",
      handle: "mix",
      value: 100,
      formatter: ValueFormatters.percentage,
      devicePresetIndex: 2,
      midiCC: 0,
    ),
  ];
}

