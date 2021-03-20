import '../../NuxConstants.dart';
import '../Processor.dart';

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
        value: 64,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
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
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
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
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 66,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
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
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}
