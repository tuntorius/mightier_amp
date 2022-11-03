// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../NuxMightyPlugAir.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Reverb extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugAir.reverbtype;
  @override
  int? get nuxEnableIndex => PresetDataIndexPlugAir.reverbenable;
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
        devicePresetIndex: PresetDataIndexPlugAir.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbmix,
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
        devicePresetIndex: PresetDataIndexPlugAir.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbmix,
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
        devicePresetIndex: PresetDataIndexPlugAir.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Damp",
        handle: "damp",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbdamp,
        midiCC: MidiCCValues.bCC_ReverbRouting),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 66,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbmix,
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
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar1decay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar2damp,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}

class ShimmerReverb extends Reverb {
  @override
  final name = "Shimmer Reverb";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir21.index)
      return SpringReverb().nuxIndex;
    return nuxIndex;
  }
}

class RoomReverbv2 extends Reverb {
  @override
  final name = "Room";

  @override
  int get nuxIndex => 0;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar1decay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 25,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar2damp,
        midiCC: MidiCCValues.bCC_ReverbLevel),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar3mix,
        midiCC: MidiCCValues.bCC_ReverbRouting)
  ];
}

class HallReverbv2 extends Reverb {
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
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar1decay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar2damp,
        midiCC: MidiCCValues.bCC_ReverbLevel),
    Parameter(
        name: "Damp",
        handle: "damp",
        value: 85,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar3mix,
        midiCC: MidiCCValues.bCC_ReverbRouting)
  ];
}

class PlateReverbv2 extends Reverb {
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
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar1decay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 66,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.reverbvar2damp,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}
