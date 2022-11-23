// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../NuxMightyPlugAir.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Delay extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugAir.delaytype;
  @override
  int? get nuxEnableIndex => PresetDataIndexPlugAir.delayenable;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValues.bCC_DelayEnable;
  @override
  int get midiCCSelectionValue => MidiCCValues.bCC_DelayMode;
}

class AnalogDelay extends Delay {
  @override
  final name = "Analog Delay";

  @override
  int get nuxIndex => 0;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar2feedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar3mix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar1time,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class TapeEcho extends Delay {
  @override
  final name = "Tape Echo";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 56,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 43,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 61,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir21.index) return ModDelay().nuxIndex;
    return nuxIndex;
  }
}

class DigitalDelay extends Delay {
  @override
  final name = "Digital Delay";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 49,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 68,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir21.index)
      return DigitalDelayv2().nuxIndex;
    return nuxIndex;
  }
}

class PingPong extends Delay {
  @override
  final name = "Ping Pong";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar2feedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar3mix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class DigitalDelayv2 extends Delay {
  @override
  final name = "Digital Delay";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 49,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar2feedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 68,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar3mix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar1time,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) {
      return DigitalDelay().nuxIndex;
    }
    return nuxIndex;
  }
}

class ModDelay extends Delay {
  @override
  final name = "Mod Delay";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 49,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar2feedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 68,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delayvar3mix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];

  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return TapeEcho().nuxIndex;
    return nuxIndex;
  }
}
