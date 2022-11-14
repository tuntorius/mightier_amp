// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Reverb extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iRVB;
  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  @override
  int get nuxEnableMask => 0x40;
  @override
  bool get nuxEnableInverted => true;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iRVB;
  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iRVB;
}

class RoomReverb extends Reverb {
  @override
  final name = "Room";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para3,
        midiCC: MidiCCValuesPro.RVB_Para3),
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2),
  ];
}

class HallReverb extends Reverb {
  @override
  final name = "Hall";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para4,
        midiCC: MidiCCValuesPro.RVB_Para4),
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Pre Delay",
        handle: "predelay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2),
    Parameter(
        name: "Liveliness",
        handle: "liveliness",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para3,
        midiCC: MidiCCValuesPro.RVB_Para3),
  ];
}

class PlateReverb extends Reverb {
  @override
  final name = "Plate";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2),
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
  ];
}

class SpringReverb extends Reverb {
  @override
  final name = "Spring";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2),
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 32,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
  ];
}

class ShimmerReverb extends Reverb {
  @override
  final name = "Shimmer";

  @override
  int get nuxIndex => 5;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2),
    Parameter(
        name: "Shimmer",
        handle: "shimmer",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para3,
        midiCC: MidiCCValuesPro.RVB_Para3)
  ];
}

class DampReverb extends Reverb {
  @override
  final name = "Damp";

  @override
  int get nuxIndex => 6;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2)
  ];
}
