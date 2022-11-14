// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Delay extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iDLY;
  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  @override
  int get nuxEnableMask => 0x40;
  @override
  bool get nuxEnableInverted => true;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iDLY;
  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iDLY;
}

class AnalogDelay extends Delay {
  @override
  final name = "Analog";

  @override
  int get nuxIndex => 1;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Intensity",
        handle: "intensity",
        value: 52,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3),
    Parameter(
        name: "Time",
        handle: "echo",
        value: 45,
        formatter: ValueFormatters.tempoProAnalog,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 34,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1),
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
        name: "E.Level",
        handle: "level",
        value: 49,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
        formatter: ValueFormatters.tempoPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3),
    Parameter(
        name: "Feedback",
        handle: "feedback",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2),
  ];
}

class ModDelay extends Delay {
  @override
  final name = "Modulation";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2),
    Parameter(
        name: "Time",
        handle: "time",
        value: 49,
        formatter: ValueFormatters.tempoProMod,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 48,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para4,
        midiCC: MidiCCValuesPro.DLY_Para4),
    Parameter(
        name: "Mod",
        handle: "mod",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3),
  ];
}

class TapeEcho extends Delay {
  @override
  final name = "Tape Echo";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 43,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2),
    Parameter(
        name: "Time",
        handle: "time",
        value: 61,
        formatter: ValueFormatters.tempoProTapeEcho,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 56,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3),
  ];
}

class PanDelay extends Delay {
  @override
  final name = "Pan Delay";

  @override
  int get nuxIndex => 5;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 45,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        formatter: ValueFormatters.tempoPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2),
  ];
}
