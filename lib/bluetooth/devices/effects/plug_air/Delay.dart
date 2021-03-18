// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../Processor.dart';

abstract class Delay extends Processor {
  int get midiCCEnableValue => MidiCCValues.bCC_DelayEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_DelayMode;
}

class AnalogDelay extends Delay {
  final name = "Analog Delay";

  int get nuxIndex => 0;

  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
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
        value: 56,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 43,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 61,
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
        value: 49,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 68,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
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
        value: 45,
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
