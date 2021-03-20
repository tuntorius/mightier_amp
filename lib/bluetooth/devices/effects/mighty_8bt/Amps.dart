// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../Processor.dart';

abstract class M8BTAmplifier extends Amplifier {
  int get midiCCEnableValue => MidiCCValues.bCC_AmpEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_AmpModeSetup;
  int get defaultCab => 0;
}

class AmpClean extends M8BTAmplifier {
  final name = "Amplifier";

  int get nuxIndex => 0;

  bool isSeparator = false;
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_OverDriveTone),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Mic Level",
        handle: "miclevel",
        value: 50,
        valueType: ValueType.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "AMB Send",
        handle: "ambsend",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpMaster),
  ];
}
