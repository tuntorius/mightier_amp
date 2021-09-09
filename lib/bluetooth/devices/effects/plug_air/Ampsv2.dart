import '../../NuxConstants.dart';
import '../../NuxMightyPlugAir.dart';
import '../Processor.dart';
import 'Amps.dart';
import 'Cabinet.dart';

class JazzClean extends PlugAirAmplifier {
  final name = "Jazz Clean";

  int get nuxIndex => 0;
  int get defaultCab => JZ120IR.cabIndex;

  bool isSeparator = true;
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 70,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Bright",
        handle: "tone",
        value: 100,
        valueType: ValueType.brightMode,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];

  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return JZ120().nuxIndex;
    return nuxIndex;
  }
}

class DeluxeRvb extends PlugAirAmplifier {
  final name = "Deluxe Rvb";

  int get nuxIndex => 1;
  int get defaultCab => DR112.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 80,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 70,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return TweedDlx().nuxIndex;
    return nuxIndex;
  }
}

class TwinRvbV2 extends PlugAirAmplifier {
  final name = "Twin Rvb";

  int get defaultCab => TR212.cabIndex;
  int get nuxIndex => 2;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 85,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass, //check this
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "middle",
        value: 70,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle, //check this
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble, //check this
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Bright",
        handle: "tone",
        value: 100,
        valueType: ValueType.brightMode,
        devicePresetIndex: PresetDataIndexPlugAir.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return TwinVerb().nuxIndex;
    return nuxIndex;
  }
}

class ClassA30 extends PlugAirAmplifier {
  final name = "Class A30";

  int get nuxIndex => 3;
  int get defaultCab => A212.cabIndex;

  bool isSeparator = true;
  String category = "Drive";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 80,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Cut",
        handle: "cut",
        value: 40,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
  ];

  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return TopBoost().nuxIndex;
    return nuxIndex;
  }
}

class Brit800 extends PlugAirAmplifier {
  final name = "Brit 800";

  int get nuxIndex => 4;
  int get defaultCab => V1960.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 44,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 81,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "middle",
        value: 71,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 52,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 58,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Lead100().nuxIndex;
    return nuxIndex;
  }
}

class Plexi1987x50 extends PlugAirAmplifier {
  final name = "1987x50";

  int get nuxIndex => 5;
  int get defaultCab => GB412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 44,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 81,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 71,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 52,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 58,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Plexi().nuxIndex;
    return nuxIndex;
  }
}

class FiremanHBE extends PlugAirAmplifier {
  final name = "Fireman HBE";

  int get nuxIndex => 6;
  int get defaultCab => V412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 70,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 77,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 70,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
}

class DualRect extends PlugAirAmplifier {
  final name = "Dual Rect";

  int get nuxIndex => 7;
  int get defaultCab => V412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 70,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Recto().nuxIndex;
    return nuxIndex;
  }
}

class DIEVH4v2 extends PlugAirAmplifier {
  final name = "DIE VH4";

  int get nuxIndex => 8;
  int get defaultCab => GB412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 80,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return DIEVH4().nuxIndex;
    return nuxIndex;
  }
}

class AGLv2 extends PlugAirAmplifier {
  final name = "AGL";

  int get nuxIndex => 9;
  int get defaultCab => AGLDB810.cabIndex;

  bool isSeparator = true;
  String category = "Bass";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 61,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 89,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 72,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 63,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return AGL().nuxIndex;
    return nuxIndex;
  }
}

class Starlift extends PlugAirAmplifier {
  final name = "Starlift";

  int get nuxIndex => 10;
  int get defaultCab => MKB410.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 70,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Contour",
        handle: "contour",
        value: 0,
        valueType: ValueType.contourMode,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 80,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return AGL().nuxIndex;
    return nuxIndex;
  }
}

class MLDv2 extends PlugAirAmplifier {
  final name = "MLD";

  int get nuxIndex => 11;
  int get defaultCab => TRC410.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 61,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 89,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 72,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 63,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return MLD().nuxIndex;
    return nuxIndex;
  }
}

class Stagemanv2 extends PlugAirAmplifier {
  final name = "Stageman";

  int get nuxIndex => 12;
  int get defaultCab => MD45.cabIndex;

  bool isSeparator = true;
  String category = "Acoustic";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 70,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 40,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
  ];
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Stageman().nuxIndex;
    return nuxIndex;
  }
}
