import '../NuxConstants.dart';
import 'Processor.dart';

abstract class Delay extends Processor {
  //~3300
// 0-Analog delay, 1 - Tape Echo, 2 - Digital Delay, 3 - Ping Pong

  int get deviceSwitchIndex => MidiCCValues.bCC_DelayEnable;
  int get deviceSelectionIndex => MidiCCValues.bCC_DelayMode;
}

class AnalogDelay extends Delay {
  final name = "Analog Delay";

  int get nuxIndex => 0;

  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndex.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class TapeEcho extends Delay {
  final name = "Tape Echo";

  int get nuxIndex => 1;
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndex.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class DigitalDelay extends Delay {
  final name = "Digital Delay";

  int get nuxIndex => 2;
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndex.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class PingPong extends Delay {
  final name = "Ping Pong";

  int get nuxIndex => 3;
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndex.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}
