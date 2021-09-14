// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../NuxMightyPlugAir.dart';
import '../Processor.dart';

abstract class Delay extends Processor {
  int get nuxDataLength => 3;

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
        devicePresetIndex: PresetDataIndexPlugAir.delayvar2feedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar3mix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar1time,
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
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir21.index) return ModDelay().nuxIndex;
    return nuxIndex;
  }
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
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir21.index)
      return DigitalDelayv2().nuxIndex;
    return nuxIndex;
  }
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
        devicePresetIndex: PresetDataIndexPlugAir.delayvar2feedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar3mix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class DigitalDelayv2 extends Delay {
  final name = "Digital Delay";

  int get nuxIndex => 1;
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 49,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar2feedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 68,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar3mix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar1time,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index)
      return DigitalDelay().nuxIndex;
    return nuxIndex;
  }
}

class ModDelay extends Delay {
  final name = "Mod Delay";

  int get nuxIndex => 2;
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 49,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar2feedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 68,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar3mix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];

  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return TapeEcho().nuxIndex;
    return nuxIndex;
  }
}
