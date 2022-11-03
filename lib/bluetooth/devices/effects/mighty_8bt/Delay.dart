import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Delay extends Processor {
  //TODO: check if correct
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexLite.delaytype;
  @override
  int? get nuxEnableIndex => PresetDataIndexLite.delayenable;

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValues.bCC_DelayEnable;
  @override
  int get midiCCSelectionValue => MidiCCValues.bCC_DelayMode;
}

class Delay1 extends Delay {
  @override
  final name = "Delay 1";

  @override
  int get nuxIndex => 0;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexLite.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class Delay2 extends Delay {
  @override
  final name = "Delay 2";

  @override
  int get nuxIndex => 1;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexLite.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class Delay3 extends Delay {
  @override
  final name = "Delay 3";

  @override
  int get nuxIndex => 2;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexLite.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class Delay4 extends Delay {
  @override
  final name = "Delay 4";

  @override
  int get nuxIndex => 3;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 34,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexLite.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}
