// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

abstract class DelayPro extends Processor {
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

class AnalogDelay extends DelayPro {
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
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Time",
        handle: "echo",
        value: 45,
        formatter: ValueFormatters.tempoProAnalog,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 34,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
  ];
}

class AnalogDelayV2 extends DelayPro {
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
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 34,
        formatter: ValueFormatters.tempoProAnalog,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Echo",
        handle: "echo",
        value: 45,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayRepeat)
  ];
}

class DigitalDelay extends DelayPro {
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
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 48,
        formatter: ValueFormatters.tempoPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Feedback",
        handle: "feedback",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
  ];
}

class ModDelay extends DelayPro {
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
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 49,
        formatter: ValueFormatters.tempoProMod,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 48,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para4,
        midiCC: MidiCCValuesPro.DLY_Para4,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mod",
        handle: "mod",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayMod),
  ];
}

class TapeEcho extends DelayPro {
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
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 61,
        formatter: ValueFormatters.tempoProTapeEcho,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 56,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
  ];
}

class PanDelay extends DelayPro {
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
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        formatter: ValueFormatters.tempoPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
  ];
}

class PhiDelayPro extends DelayPro {
  @override
  final name = "Phi Delay";

  @override
  int get nuxIndex => 6;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        formatter: ValueFormatters.tempoPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mix",
        handle: "level",
        value: 45,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayLevel),
  ];
}
