import '../../NuxConstants.dart';
import '../Processor.dart';

abstract class Delay extends Processor {
  int get midiCCEnableValue => MidiCCValues.bCC_DelayEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_DelayMode;
}

class Delay1 extends Delay {
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

class Delay2 extends Delay {
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

class Delay3 extends Delay {
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

class Delay4 extends Delay {
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
