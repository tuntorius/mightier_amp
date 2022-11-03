import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Reverb extends Processor {
  //TODO: check if correct
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexLite.reverbtype;
  @override
  int? get nuxEnableIndex => PresetDataIndexLite.reverbenable;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValues.bCC_ReverbEnable;
  @override
  int get midiCCSelectionValue => MidiCCValues.bCC_ReverbMode;
}

class RoomReverb extends Reverb {
  @override
  final name = "Room";

  @override
  int get nuxIndex => 0;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 64,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}

class HallReverb extends Reverb {
  @override
  final name = "Hall";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}

class PlateReverb extends Reverb {
  @override
  final name = "Plate";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 81,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 66,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}

class SpringReverb extends Reverb {
  @override
  final name = "Spring";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 32,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}
