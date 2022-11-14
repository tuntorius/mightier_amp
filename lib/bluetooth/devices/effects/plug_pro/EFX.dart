// (c) 2020-2022 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
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
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Sensitivity",
        handle: "sensitivity",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
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
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para4,
        midiCC: MidiCCValuesPro.EFX_Para4),
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
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para4,
        midiCC: MidiCCValuesPro.EFX_Para4),
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
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 55,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
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
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
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
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
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
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
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
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Distortion",
        handle: "distortion",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Filter",
        handle: "filter",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
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
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
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
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 45,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
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
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
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
        midiCC: MidiCCValuesPro.EFX_Para2),
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
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Filter",
        handle: "filter",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}
