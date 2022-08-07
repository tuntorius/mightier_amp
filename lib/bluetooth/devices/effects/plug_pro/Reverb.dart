// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Reverb extends Processor {
  int get nuxDataLength => 3;

  int get midiCCEnableValue => MidiCCValuesPro.Head_iRVB;
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iRVB;
}

class RoomReverb extends Reverb {
  final name = "Room";

  int get nuxIndex => 1;
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para3,
        midiCC: MidiCCValuesPro.RVB_Para3)
  ];
}

class HallReverb extends Reverb {
  final name = "Hall";

  int get nuxIndex => 2;
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Pre Delay",
        handle: "predelay",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2),
    Parameter(
        name: "Liveliness",
        handle: "liveliness",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para3,
        midiCC: MidiCCValuesPro.RVB_Para3),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para4,
        midiCC: MidiCCValuesPro.RVB_Para4)
  ];
}

class PlateReverb extends Reverb {
  final name = "Plate";

  int get nuxIndex => 3;
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2)
  ];
}

class SpringReverb extends Reverb {
  final name = "Spring";

  int get nuxIndex => 4;
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 32,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2)
  ];
}

class ShimmerReverb extends Reverb {
  final name = "Shimmer";

  int get nuxIndex => 5;
  List<Parameter> parameters = [
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2),
    Parameter(
        name: "Shimmer",
        handle: "shimmer",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para3,
        midiCC: MidiCCValuesPro.RVB_Para3)
  ];
}

class DampReverb extends Reverb {
  final name = "Damp";

  int get nuxIndex => 6;
  List<Parameter> parameters = [
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2)
  ];
}
