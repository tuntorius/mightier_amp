// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../NuxConstants.dart';
import 'Processor.dart';

class Amplifier extends Processor {
  int get deviceSwitchIndex => MidiCCValues.bCC_AmpEnable;
  int get deviceSelectionIndex => MidiCCValues.bCC_AmpModeSetup;
}

class TwinVerb extends Amplifier {
  final name = "Twin Verb";

  int get nuxIndex => 0;

  bool isSeparator = true;
  String category = "Clean";

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
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class JZ120 extends Amplifier {
  final name = "JZ 120";

  int get nuxIndex => 1;
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
        value: 50,
        valueType: ValueType.percentage,
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
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class TweedDlx extends Amplifier {
  final name = "Tweed Dlx";

  int get nuxIndex => 2;

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
        value: 50,
        valueType: ValueType.percentage,
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
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
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
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class TopBoost extends Amplifier {
  final name = "Top Boost 30";

  int get nuxIndex => 4;
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
        value: 50,
        valueType: ValueType.percentage,
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
        handle: "mdl",
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
    Parameter(
        name: "Tone (Presence)",
        handle: "tone",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class Lead100 extends Amplifier {
  final name = "Lead 100";

  int get nuxIndex => 5;
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
        value: 50,
        valueType: ValueType.percentage,
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
        handle: "middle",
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
    Parameter(
        name: "Tone (Presence)",
        handle: "tone",
        value: 50,
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
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class DIEVH4 extends Amplifier {
  final name = "DIE VH4";

  int get nuxIndex => 7;
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
        value: 50,
        valueType: ValueType.percentage,
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
    Parameter(
        name: "Tone (Presence)",
        handle: "tone",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class Recto extends Amplifier {
  final name = "Recto";

  int get nuxIndex => 8;
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
        value: 50,
        valueType: ValueType.percentage,
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
    Parameter(
        name: "Tone (Presence)",
        handle: "tone",
        value: 50,
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
        value: 50,
        valueType: ValueType.percentage,
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
        value: 50,
        valueType: ValueType.percentage,
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
        value: 50,
        valueType: ValueType.percentage,
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
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class AGL extends Amplifier {
  final name = "AGL";

  int get nuxIndex => 12;
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
        value: 50,
        valueType: ValueType.percentage,
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
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}
