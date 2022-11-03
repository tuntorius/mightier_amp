// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Ambience extends Processor {
  //TODO: check if correct
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexLite.delaytype;
  @override
  int? get nuxEnableIndex => PresetDataIndexLite.delayenable;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;

  @override
  int get midiCCEnableValue => MidiCCValues.bCC_ChorusEnable;
  @override
  int get midiCCSelectionValue => MidiCCValues.bCC_ChorusMode;
}

class Delay1 extends Ambience {
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

class Delay2 extends Ambience {
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

class Delay3 extends Ambience {
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

class Delay4 extends Ambience {
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

class RoomReverb extends Ambience {
  @override
  final name = "Room";

  @override
  int get nuxIndex => 10;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 64,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}

class HallReverb extends Ambience {
  @override
  final name = "Hall";

  @override
  int get nuxIndex => 11;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}

class PlateReverb extends Ambience {
  @override
  final name = "Plate";

  @override
  int get nuxIndex => 12;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 81,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 66,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}

class SpringReverb extends Ambience {
  @override
  final name = "Spring";

  @override
  int get nuxIndex => 13;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 32,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel)
  ];
}
