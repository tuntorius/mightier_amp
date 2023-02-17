// (c) 2020-2022 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

abstract class EFX extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iEFX;
  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  @override
  int get nuxEnableMask => 0x40;
  @override
  bool get nuxEnableInverted => true;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iEFX;

  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iEFX;

  //MIDI foot controller stuff
  @override
  MidiControllerHandle? get midiControlOff => MidiControllerHandles.efxOff;
  @override
  MidiControllerHandle? get midiControlOn => MidiControllerHandles.efxOn;
  @override
  MidiControllerHandle? get midiControlToggle =>
      MidiControllerHandles.efxToggle;
  @override
  MidiControllerHandle? get midiControlPrev => MidiControllerHandles.efxPrev;
  @override
  MidiControllerHandle? get midiControlNext => MidiControllerHandles.efxNext;
}

class DistortionPlus extends EFX {
  @override
  final name = "Distortion+";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Output",
        handle: "output",
        value: 75,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Sensitivity",
        handle: "sensitivity",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxGain),
  ];
}

class RCBoost extends EFX {
  @override
  final name = "RC Boost";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxBass),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para4,
        midiCC: MidiCCValuesPro.EFX_Para4,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class ACBoost extends EFX {
  @override
  final name = "AC Boost";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxBass),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para4,
        midiCC: MidiCCValuesPro.EFX_Para4,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class DistOne extends EFX {
  @override
  final name = "Dist One";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 55,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class TSDrive extends EFX {
  @override
  final name = "T Screamer";
  @override
  int get nuxIndex => 5;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 55,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class BluesDrive extends EFX {
  @override
  final name = "Blues Drive";

  @override
  int get nuxIndex => 6;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class MorningDrive extends EFX {
  @override
  final name = "Morning Drive";

  @override
  int get nuxIndex => 7;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class EatDist extends EFX {
  @override
  final name = "Eat Dist";

  @override
  int get nuxIndex => 8;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Distortion",
        handle: "distortion",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Filter",
        handle: "filter",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class RedDirt extends EFX {
  @override
  final name = "Red Dirt";

  @override
  int get nuxIndex => 9;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class Crunch extends EFX {
  @override
  final name = "Crunch";

  @override
  int get nuxIndex => 10;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 25,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 45,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class MuffFuzz extends EFX {
  @override
  final name = "Muff Fuzz";

  @override
  int get nuxIndex => 11;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxDepth),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class Katana extends EFX {
  @override
  final name = "Katana";

  @override
  int get nuxIndex => 12;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 45,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Boost",
        handle: "boost",
        value: 0,
        formatter: ValueFormatters.boostModePro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
  ];
}

class STSinger extends EFX {
  @override
  final name = "ST Singer";

  @override
  int get nuxIndex => 13;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Filter",
        handle: "filter",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}
