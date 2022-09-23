// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../NuxMightyPlugAir.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Reverb extends Processor {
  int get nuxDataLength => 3;
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  int get midiCCEnableValue => MidiCCValues.bCC_ReverbEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_ReverbMode;
}

class RoomReverb extends Reverb {
  final name = "Room";

  int get nuxIndex => 0;
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
  final name = "Hall";

  int get nuxIndex => 1;
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
  final name = "Plate";

  int get nuxIndex => 2;
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
  final name = "Spring";

  int get nuxIndex => 3;
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
  final name = "Shimmer Reverb";

  int get nuxIndex => 4;
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
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir21.index)
      return SpringReverb().nuxIndex;
    return nuxIndex;
  }
}

class RoomReverbv2 extends Reverb {
  final name = "Room";

  int get nuxIndex => 0;
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
  final name = "Hall";

  int get nuxIndex => 1;
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
  final name = "Plate";

  int get nuxIndex => 2;
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
