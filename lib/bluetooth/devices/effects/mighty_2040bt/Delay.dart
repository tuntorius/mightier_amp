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
        devicePresetIndex: PresetDataIndexPlugAir.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class ModulationDelay extends Delay {
  final name = "Modulation";

  int get nuxIndex => 1;
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 56,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 43,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 61,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
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
        devicePresetIndex: PresetDataIndexPlugAir.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 68,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}
