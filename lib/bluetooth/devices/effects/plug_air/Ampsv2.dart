import '../../NuxConstants.dart';
import '../../NuxMightyPlugAir.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';
import 'Amps.dart';
import 'Cabinet.dart';

class JazzClean extends PlugAirAmplifier {
  @override
  final name = "Jazz Clean";

  @override
  int get nuxIndex => 0;
  @override
  int get defaultCab => JZ120IR.cabIndex;

  @override
  bool isSeparator = true;
  @override
  String category = "Clean";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 70,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
    Parameter(
        name: "Bright",
        handle: "tone",
        value: 100,
        formatter: ValueFormatters.brightMode,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];

  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return JZ120().nuxIndex;
    return nuxIndex;
  }
}

class DeluxeRvb extends PlugAirAmplifier {
  @override
  final name = "Deluxe Rvb";

  @override
  int get nuxIndex => 1;
  @override
  int get defaultCab => DR112.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 80,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return TweedDlx().nuxIndex;
    return nuxIndex;
  }
}

class TwinRvbV2 extends PlugAirAmplifier {
  @override
  final name = "Twin Rvb";

  @override
  int get defaultCab => TR212.cabIndex;
  @override
  int get nuxIndex => 2;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 85,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass, //check this
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "middle",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle, //check this
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble, //check this
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
    Parameter(
        name: "Bright",
        handle: "tone",
        value: 100,
        formatter: ValueFormatters.brightMode,
        devicePresetIndex: PresetDataIndexPlugAir.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return TwinVerb().nuxIndex;
    return nuxIndex;
  }
}

class ClassA30 extends PlugAirAmplifier {
  @override
  final name = "Class A30";

  @override
  int get nuxIndex => 3;
  @override
  int get defaultCab => A212.cabIndex;

  @override
  bool isSeparator = true;
  @override
  String category = "Drive";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 80,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Cut",
        handle: "cut",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
  ];

  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return TopBoost().nuxIndex;
    return nuxIndex;
  }
}

class Brit800 extends PlugAirAmplifier {
  @override
  final name = "Brit 800";

  @override
  int get nuxIndex => 4;
  @override
  int get defaultCab => V1960.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 44,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 81,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "middle",
        value: 71,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 52,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 58,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone, //check this
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Lead100().nuxIndex;
    return nuxIndex;
  }
}

class Plexi1987x50 extends PlugAirAmplifier {
  @override
  final name = "1987x50";

  @override
  int get nuxIndex => 5;
  @override
  int get defaultCab => GB412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 44,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 81,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 71,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 52,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 58,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Plexi().nuxIndex;
    return nuxIndex;
  }
}

class FiremanHBE extends PlugAirAmplifier {
  @override
  final name = "Fireman HBE";

  @override
  int get nuxIndex => 6;
  @override
  int get defaultCab => V412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 77,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
  ];
}

class DualRect extends PlugAirAmplifier {
  @override
  final name = "Dual Rect";

  @override
  int get nuxIndex => 7;
  @override
  int get defaultCab => V412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 70,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Recto().nuxIndex;
    return nuxIndex;
  }
}

class DIEVH4v2 extends PlugAirAmplifier {
  @override
  final name = "DIE VH4";

  @override
  int get nuxIndex => 8;
  @override
  int get defaultCab => GB412.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 80,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
    Parameter(
        name: "Presence",
        handle: "tone",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return DIEVH4().nuxIndex;
    return nuxIndex;
  }
}

class AGLv2 extends PlugAirAmplifier {
  @override
  final name = "AGL";

  @override
  int get nuxIndex => 9;
  @override
  int get defaultCab => AGLDB810.cabIndex;

  @override
  bool isSeparator = true;
  @override
  String category = "Bass";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 61,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 89,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 72,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return AGL().nuxIndex;
    return nuxIndex;
  }
}

class Starlift extends PlugAirAmplifier {
  @override
  final name = "Starlift";

  @override
  int get nuxIndex => 10;
  @override
  int get defaultCab => MKB410.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
    Parameter(
        name: "Contour",
        handle: "contour",
        value: 0,
        formatter: ValueFormatters.contourMode,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 80,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return AGL().nuxIndex;
    return nuxIndex;
  }
}

class MLDv2 extends PlugAirAmplifier {
  @override
  final name = "MLD";

  @override
  int get nuxIndex => 11;
  @override
  int get defaultCab => TRC410.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 61,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 89,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 72,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return MLD().nuxIndex;
    return nuxIndex;
  }
}

class Stagemanv2 extends PlugAirAmplifier {
  @override
  final name = "Stageman";

  @override
  int get nuxIndex => 12;
  @override
  int get defaultCab => MD45.cabIndex;

  @override
  bool isSeparator = true;
  @override
  String category = "Acoustic";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 70,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
  ];
  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Stageman().nuxIndex;
    return nuxIndex;
  }
}
