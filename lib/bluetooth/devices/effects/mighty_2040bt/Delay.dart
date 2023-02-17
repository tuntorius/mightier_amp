// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
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

  //MIDI foot controller stuff
  @override
  MidiControllerHandle? get midiControlOff => MidiControllerHandles.delayOff;
  @override
  MidiControllerHandle? get midiControlOn => MidiControllerHandles.delayOn;
  @override
  MidiControllerHandle? get midiControlToggle =>
      MidiControllerHandles.delayToggle;
  @override
  MidiControllerHandle? get midiControlPrev => MidiControllerHandles.delayPrev;
  @override
  MidiControllerHandle? get midiControlNext => MidiControllerHandles.delayNext;
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
        devicePresetIndex: PresetDataIndexPlugAir.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 52,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime,
        midiControllerHandle: MidiControllerHandles.delayTime),
  ];
}

class ModulationDelay extends Delay {
  @override
  final name = "Modulation";

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
        midiCC: MidiCCValues.bCC_DelayRepeat,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 43,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 61,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime,
        midiControllerHandle: MidiControllerHandles.delayTime),
  ];
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
        midiCC: MidiCCValues.bCC_DelayRepeat,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 68,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
        formatter: ValueFormatters.tempo,
        devicePresetIndex: PresetDataIndexPlugAir.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime,
        midiControllerHandle: MidiControllerHandles.delayTime),
  ];
}
