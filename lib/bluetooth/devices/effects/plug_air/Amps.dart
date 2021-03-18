// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../Processor.dart';
import 'Cabinet.dart';

abstract class Amplifier extends Processor {
  int get midiCCEnableValue => MidiCCValues.bCC_AmpEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_AmpModeSetup;
  int get defaultCab;
}

class TwinVerb extends Amplifier {
  final name = "Twin Verb";

  int get defaultCab => TR212.cabIndex;
  int get nuxIndex => 0;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 78,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 80,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 68,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class JZ120 extends Amplifier {
  final name = "JZ 120";

  int get nuxIndex => 1;
  int get defaultCab => JZ120IR.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 76,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 75,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 62,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 54,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class TweedDlx extends Amplifier {
  final name = "Tweed Dlx";

  int get nuxIndex => 2;
  int get defaultCab => DR112.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 92,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 42,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 59,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 66,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 49,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class Plexi extends Amplifier {
  final name = "Plexi";

  bool isSeparator = true;
  String category = "Overdrive";

  int get nuxIndex => 3;
  int get defaultCab => GB412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 26,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 53,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 70,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class TopBoost extends Amplifier {
  final name = "Top Boost 30";

  int get nuxIndex => 4;
  int get defaultCab => A212.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 44,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 81,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mdl",
        value: 71,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 52,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Tone (Presence)",
        handle: "tone",
        value: 58,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class Lead100 extends Amplifier {
  final name = "Lead 100";

  int get nuxIndex => 5;
  int get defaultCab => BS410.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 71,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 66,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "middle",
        value: 62,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 53,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Tone (Presence)",
        handle: "tone",
        value: 67,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class Fireman extends Amplifier {
  final name = "Fireman";

  bool isSeparator = true;
  String category = "Distortion";

  int get nuxIndex => 6;
  int get defaultCab => V412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 54,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 69,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 53,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class DIEVH4 extends Amplifier {
  final name = "DIE VH4";

  int get nuxIndex => 7;
  int get defaultCab => V412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 68,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 72,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 41,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 64,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Tone (Presence)",
        handle: "tone",
        value: 51,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class Recto extends Amplifier {
  final name = "Recto";

  int get nuxIndex => 8;
  int get defaultCab => V412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 73,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 60,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 69,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 35,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 46,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Tone (Presence)",
        handle: "tone",
        value: 63,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class Optima extends Amplifier {
  final name = "Optima";

  bool isSeparator = true;
  String category = "Acoustic";

  int get nuxIndex => 9;
  int get defaultCab => MD45.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 72,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 100,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
  ];
}

class Stageman extends Amplifier {
  final name = "Stageman";

  int get nuxIndex => 10;
  int get defaultCab => MD45.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 90,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
  ];
}

class MLD extends Amplifier {
  final name = "MLD";

  bool isSeparator = true;
  String category = "Bass";

  int get nuxIndex => 11;
  int get defaultCab => TRC410.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 70,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 91,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 59,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 61,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class AGL extends Amplifier {
  final name = "AGL";

  int get nuxIndex => 12;
  int get defaultCab => AGLDB810.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 61,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 89,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 72,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 63,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}
