// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../NuxConstants.dart';
import 'Processor.dart';

abstract class Reverb extends Processor {
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
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbmix,
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
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbmix,
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
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Damp",
        handle: "damp",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbdamp,
        midiCC: MidiCCValues.bCC_ReverbRouting),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbmix,
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
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbmix,
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
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}
