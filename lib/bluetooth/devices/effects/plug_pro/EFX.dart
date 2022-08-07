// (c) 2020-2022 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class EFX extends Processor {
  int get nuxDataLength => 3;

  int get midiCCEnableValue => MidiCCValuesPro.Head_iEFX;

  int get midiCCSelectionValue => MidiCCValuesPro.Head_iEFX;
}

class DistortionPlus extends EFX {
  final name = "Distortion+";

  int get nuxIndex => 1;
  List<Parameter> parameters = [
    Parameter(
        name: "Output",
        handle: "output",
        value: 75,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Sensitivity",
        handle: "sensitivity",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
  ];
}

class RCBoost extends EFX {
  final name = "RC Boost";

  int get nuxIndex => 2;
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para4,
        midiCC: MidiCCValuesPro.EFX_Para4),
  ];
}

class ACBoost extends EFX {
  final name = "AC Boost";

  int get nuxIndex => 3;
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para4,
        midiCC: MidiCCValuesPro.EFX_Para4),
  ];
}

class DistOne extends EFX {
  final name = "Dist One";

  int get nuxIndex => 4;
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}

class TSDrive extends EFX {
  final name = "T Screamer";
  int get nuxIndex => 5;
  List<Parameter> parameters = [
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Level",
        handle: "level",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}

class BluesDrive extends EFX {
  final name = "Blues Drive";

  int get nuxIndex => 6;
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}

class MorningDrive extends EFX {
  final name = "Morning Drive";

  int get nuxIndex => 7;
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}

class EatDist extends EFX {
  final name = "Eat Dist";

  int get nuxIndex => 8;
  List<Parameter> parameters = [
    Parameter(
        name: "Distortion",
        handle: "distortion",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Filter",
        handle: "filter",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}

class RedDirt extends EFX {
  final name = "Red Dirt";

  int get nuxIndex => 9;
  List<Parameter> parameters = [
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}

class Crunch extends EFX {
  final name = "Crunch";

  int get nuxIndex => 10;
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 25,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}

class MuffFuzz extends EFX {
  final name = "Muff Fuzz";

  int get nuxIndex => 8;
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}

class Katana extends EFX {
  final name = "Katana";

  int get nuxIndex => 12;

  List<Parameter> parameters = [
    Parameter(
        name: "Boost",
        handle: "boost",
        value: 100,
        formatter: ValueFormatters.boostMode,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
  ];
}

class STSinger extends EFX {
  final name = "ST Singer";

  int get nuxIndex => 13;
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2),
    Parameter(
        name: "Filter",
        handle: "filter",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}
