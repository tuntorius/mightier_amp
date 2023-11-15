import 'package:mighty_plug_manager/bluetooth/devices/NuxConstants.dart';

import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';
import '../plug_air/Amps.dart';
import 'cabs.dart';

class MLD50BT extends PlugAirAmplifier {
  @override
  final name = "MLD";

  @override
  bool isSeparator = true;
  @override
  String category = "Bass";

  @override
  int get nuxIndex => 0;
  @override
  int get defaultCab => TRC50BT.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    /*
    Parameter(
        name: "Level",
        handle: "level",
        value: 91,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
        */
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 59,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 61,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
  ];
}

class AGL50BT extends PlugAirAmplifier {
  @override
  final name = "AGL";

  @override
  int get nuxIndex => 1;
  @override
  int get defaultCab => DB81050BT.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    /*
    Parameter(
        name: "Level",
        handle: "level",
        value: 91,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexPlugAir.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
        */
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 59,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Mid Freq",
        handle: "mid_freq",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.amptone,
        midiCC: MidiCCValues.bCC_AmpPresence,
        midiControllerHandle: MidiControllerHandles.ampTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 61,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
  ];
}

class BassGuy50BT extends PlugAirAmplifier {
  @override
  final name = "Bassguy";

  @override
  int get nuxIndex => 0;
  @override
  int get defaultCab => BassguyCab50BT.cabIndex;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.ampgain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 91,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexBass50BT.amplevel,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 59,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.ampbass,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.ampmiddle,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 61,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.amptreble,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampTreble),
  ];
}
