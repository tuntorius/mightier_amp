// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';
import 'Cabinet.dart';

abstract class PlugProAmplifier extends Amplifier {
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iAMP;
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  int get nuxEnableMask => 0x40;
  bool get nuxEnableInverted => true;

  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  int get midiCCEnableValue => MidiCCValuesPro.Head_iAMP;
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iAMP;
  int get defaultCab;
}

class JazzClean extends PlugProAmplifier {
  final name = "Jazz Clean";

  int get nuxIndex => 1;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 100,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class DeluxeRvb extends PlugProAmplifier {
  final name = "Deluxe Rvb";

  int get nuxIndex => 2;
  int get defaultCab => DR112Pro.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
  ];
}

class BassMate extends PlugProAmplifier {
  final name = "Bass Mate";

  int get defaultCab => BS410.cabIndex;
  int get nuxIndex => 3;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 85,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 100,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Tweedy extends PlugProAmplifier {
  final name = "Tweedy";

  int get defaultCab => DR112Pro.cabIndex;
  int get nuxIndex => 4;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 78,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, //check this
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class HiWire extends PlugProAmplifier {
  final name = "Hiwire";

  int get nuxIndex => 6;
  int get defaultCab => HIWIRE412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 76,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 75,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 62,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 54,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, //check this
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class CaliCrunch extends PlugProAmplifier {
  final name = "Cali Crunch";

  int get nuxIndex => 7;
  int get defaultCab => CALI112.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 92,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 42,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 59,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 66,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 49,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, //check this
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class ClassA30 extends PlugProAmplifier {
  final name = "Class A30";

  int get nuxIndex => 9;
  int get defaultCab => A212Pro.cabIndex;

  bool isSeparator = true;
  String category = "Drive";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Cut",
        handle: "cut",
        value: 40,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Plexi100 extends PlugProAmplifier {
  final name = "Plexi 100";

  int get nuxIndex => 10;
  int get defaultCab => GB412Pro.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 71,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 66,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 62,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 53,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 67,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, //check this
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Plexi45 extends PlugProAmplifier {
  final name = "Plexi 45";

  bool isSeparator = true;
  String category = "Overdrive";

  int get nuxIndex => 11;
  int get defaultCab => GB412Pro.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 26,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 53,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 62,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 53,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 67,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, //check this
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Brit800 extends PlugProAmplifier {
  final name = "Brit 800";

  int get nuxIndex => 12;
  int get defaultCab => M1960AV.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 44,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 81,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 71,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 52,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 58,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, //check this
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Pl1987x50 extends PlugProAmplifier {
  final name = "1987x50";

  int get nuxIndex => 13;
  int get defaultCab => M1960TV.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 44,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 81,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 71,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 52,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 58,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Slo100 extends PlugProAmplifier {
  final name = "Slo 100";

  int get nuxIndex => 14;
  int get defaultCab => SLO412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 44,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 81,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 71,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 52,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 58,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class FiremanHBE extends PlugProAmplifier {
  final name = "Fireman HBE";

  int get nuxIndex => 15;
  int get defaultCab => FIREMAN412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 77,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 55,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class DualRect extends PlugProAmplifier {
  final name = "Dual Rect";

  int get nuxIndex => 16;
  int get defaultCab => RECT412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 55,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class DIEVH4 extends PlugProAmplifier {
  final name = "DIE VH4";

  int get nuxIndex => 17;
  int get defaultCab => DIE412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 72,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 41,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 64,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Presence",
        handle: "presence",
        value: 51,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, //check this
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class MrZ38 extends PlugProAmplifier {
  final name = "Mr. Z38";

  int get nuxIndex => 20;
  int get defaultCab => Z212.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 44,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 81,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 71,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 52,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Cut",
        handle: "cut",
        value: 58,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, //check this
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class SuperRvb extends PlugProAmplifier {
  final name = "Super Rvb";

  int get nuxIndex => 21;
  int get defaultCab => SUPERVERB410.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 100,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class AGL extends PlugProAmplifier {
  final name = "AGL";

  int get nuxIndex => 26;
  int get defaultCab => AGLDB810.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 61,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 89,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 72,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, //check this
        midiCC: MidiCCValuesPro.AMP_Para6),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 63,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
  ];
}

class MLD extends PlugProAmplifier {
  final name = "MLD";

  bool isSeparator = true;
  String category = "Bass";

  int get nuxIndex => 27;
  int get defaultCab => MKB410.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 91,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 59,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 61,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
  ];
}

class OptimaAir extends PlugProAmplifier {
  final name = "Optima Air";

  bool isSeparator = true;
  String category = "Acoustic";

  int get nuxIndex => 28;
  int get defaultCab => GJ15Pro.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 72,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 100,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
  ];
}

class Stageman extends PlugProAmplifier {
  final name = "Stageman";

  int get nuxIndex => 29;
  int get defaultCab => MD45Pro.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 90,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
  ];
}

class Unknown0 extends PlugProAmplifier {
  final name = "Unknown 0";

  int get nuxIndex => 0;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Unknown5 extends PlugProAmplifier {
  final name = "Unknown 5";

  int get nuxIndex => 5;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Unknown8 extends PlugProAmplifier {
  final name = "Unknown 8";

  int get nuxIndex => 8;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Unknown18 extends PlugProAmplifier {
  final name = "Unknown 18";

  int get nuxIndex => 18;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Unknown19 extends PlugProAmplifier {
  final name = "Unknown 19";

  int get nuxIndex => 19;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Unknown22 extends PlugProAmplifier {
  final name = "Unknown 22";

  int get nuxIndex => 22;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Unknown23 extends PlugProAmplifier {
  final name = "Unknown 23";

  int get nuxIndex => 23;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Unknown24 extends PlugProAmplifier {
  final name = "Unknown 24";

  int get nuxIndex => 24;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Unknown25 extends PlugProAmplifier {
  final name = "Unknown 25";

  int get nuxIndex => 25;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}

class Unknown30 extends PlugProAmplifier {
  final name = "Unknown 30";

  int get nuxIndex => 30;
  int get defaultCab => JZ120Pro.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1,
        midiCC: MidiCCValuesPro.AMP_Para1),
    Parameter(
        name: "Master",
        handle: "master",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2,
        midiCC: MidiCCValuesPro.AMP_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3,
        midiCC: MidiCCValuesPro.AMP_Para3),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4,
        midiCC: MidiCCValuesPro.AMP_Para4),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5,
        midiCC: MidiCCValuesPro.AMP_Para5),
    Parameter(
        name: "Bright",
        handle: "bright",
        value: 50,
        formatter: ValueFormatters.brightModePro,
        devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6,
        midiCC: MidiCCValuesPro.AMP_Para6),
  ];
}
