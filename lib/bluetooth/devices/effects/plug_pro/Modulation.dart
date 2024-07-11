// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:mighty_plug_manager/bluetooth/devices/effects/MidiControllerHandles.dart';

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Modulation extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iMOD;
  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  @override
  int get nuxEnableMask => 0x40;
  @override
  bool get nuxEnableInverted => true;
  //row 1247: 0-phaser, 1-chorus, 2-Stereo chorus, 3-Flanger, 4-Vibe, 5-Tremolo
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iMOD;
  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iMOD;

  //MIDI foot controller stuff
  @override
  MidiControllerHandle? get midiControlOff => MidiControllerHandles.modOff;
  @override
  MidiControllerHandle? get midiControlOn => MidiControllerHandles.modOn;
  @override
  MidiControllerHandle? get midiControlToggle =>
      MidiControllerHandles.modToggle;
  @override
  MidiControllerHandle? get midiControlPrev => MidiControllerHandles.modPrev;
  @override
  MidiControllerHandle? get midiControlNext => MidiControllerHandles.modNext;
}

class ModCE1 extends Modulation {
  @override
  final name = "CE-1";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 39,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para3,
        midiCC: MidiCCValuesPro.MOD_Para3,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Intensity",
        handle: "intensity",
        value: 32,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modIntensity),
  ];
}

class ModCE2 extends Modulation {
  @override
  final name = "CE-2";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modDepth),
  ];
}

class STChorusPro extends Modulation {
  @override
  final name = "ST Chorus";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para3,
        midiCC: MidiCCValuesPro.MOD_Para3,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Width",
        handle: "width",
        value: 36,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Intensity",
        handle: "intensity",
        value: 74,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modIntensity),
  ];
}

class Vibrato extends Modulation {
  @override
  final name = "Vibrato";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 56,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modDepth)
  ];
}

class Detune extends Modulation {
  @override
  final name = "Detune";

  @override
  int get nuxIndex => 5;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Shift-L",
        handle: "shift_l",
        value: 54,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Shift-R",
        handle: "shift_r",
        value: 0,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para3,
        midiCC: MidiCCValuesPro.MOD_Para3,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modIntensity),
  ];
}

class FlangerPro extends Modulation {
  @override
  final name = "Flanger";

  @override
  int get nuxIndex => 6;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 59,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Width",
        handle: "width",
        value: 63,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para3,
        midiCC: MidiCCValuesPro.MOD_Para3,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Level",
        handle: "level",
        value: 59,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modIntensity),
    Parameter(
        name: "Feedback",
        handle: "feedback",
        value: 63,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para4,
        midiCC: MidiCCValuesPro.MOD_Para4),
  ];
}

class Phase90 extends Modulation {
  @override
  final name = "Phase 90";

  @override
  int get nuxIndex => 7;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Speed",
        handle: "speed",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
  ];
}

class Phase100 extends Modulation {
  @override
  final name = "Phase 100";

  @override
  int get nuxIndex => 8;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Speed",
        handle: "speed",
        value: 39,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Intensity",
        handle: "intensity",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modIntensity),
  ];
}

class SCFPro extends Modulation {
  @override
  final name = "S.C.F.";

  @override
  int get nuxIndex => 9;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Speed",
        handle: "speed",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Width",
        handle: "width",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Intensity",
        handle: "intensity",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para4,
        midiCC: MidiCCValuesPro.MOD_Para4,
        midiControllerHandle: MidiControllerHandles.modIntensity),
    Parameter(
        name: "Mode",
        handle: "mode",
        value: 1,
        formatter: ValueFormatters.scfMode,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para3,
        midiCC: MidiCCValuesPro.MOD_Para3),
  ];
}

class VibePro extends Modulation {
  @override
  final name = "U-Vibe";

  @override
  int get nuxIndex => 10;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Speed",
        handle: "speed",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modIntensity),
    Parameter(
        name: "Intensity",
        handle: "intensity",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para3,
        midiCC: MidiCCValuesPro.MOD_Para3,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Mode",
        handle: "mode",
        value: 0,
        formatter: ValueFormatters.vibeModePro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para4,
        midiCC: MidiCCValuesPro.MOD_Para4),
  ];
}

class TremoloPro extends Modulation {
  @override
  final name = "Tremolo";

  @override
  int get nuxIndex => 11;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 15,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modDepth),
  ];
}

class Rotary extends Modulation {
  @override
  final name = "Rotary";

  @override
  int get nuxIndex => 12;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Speed",
        handle: "speed",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Balance",
        handle: "balance",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modDepth),
  ];
}

class SCH1Pro extends Modulation {
  @override
  final name = "SCH-1";

  @override
  int get nuxIndex => 13;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 30,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para3,
        midiCC: MidiCCValuesPro.MOD_Para3,
        midiControllerHandle: MidiControllerHandles.modIntensity),
  ];
}

class MonoOctave extends Modulation {
  @override
  final name = "Mono Octave";

  @override
  int get nuxIndex => 14;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Sub",
        handle: "sub",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Dry",
        handle: "dry",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modIntensity),
    Parameter(
        name: "Up",
        handle: "up",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para3,
        midiCC: MidiCCValuesPro.MOD_Para3,
        midiControllerHandle: MidiControllerHandles.modDepth),
  ];
}
