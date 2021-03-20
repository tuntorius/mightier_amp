// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../Processor.dart';

abstract class Ambience extends Processor {
  int get midiCCEnableValue => MidiCCValues.bCC_ChorusEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_ChorusMode;
}

class Delay1 extends Ambience {
  final name = "Delay 1";

  int get nuxIndex => 0;

  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexLite.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class Delay2 extends Ambience {
  final name = "Delay 2";

  int get nuxIndex => 1;

  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexLite.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class Delay3 extends Ambience {
  final name = "Delay 3";

  int get nuxIndex => 2;

  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexLite.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class Delay4 extends Ambience {
  final name = "Delay 4";

  int get nuxIndex => 3;

  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexLite.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class RoomReverb extends Ambience {
  final name = "Room";

  int get nuxIndex => 10;
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

class HallReverb extends Ambience {
  final name = "Hall";

  int get nuxIndex => 11;
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

class PlateReverb extends Ambience {
  final name = "Plate";

  int get nuxIndex => 12;
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

class SpringReverb extends Ambience {
  final name = "Spring";

  int get nuxIndex => 13;
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
