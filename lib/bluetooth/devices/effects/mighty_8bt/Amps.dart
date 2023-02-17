// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

abstract class M8BTAmplifier extends Amplifier {
  //TODO: check if correct
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexLite.drivetype;
  @override
  int? get nuxEnableIndex => null;

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValues.bCC_AmpEnable;
  @override
  int get midiCCSelectionValue => MidiCCValues.bCC_NotUsed;
  @override
  int get defaultCab => 0;

  //MIDI foot controller stuff
  @override
  MidiControllerHandle? get midiControlOff => null;
  @override
  MidiControllerHandle? get midiControlOn => null;
  @override
  MidiControllerHandle? get midiControlToggle => null;
  @override
  MidiControllerHandle? get midiControlPrev => null;
  @override
  MidiControllerHandle? get midiControlNext => null;
}

class AmpClean extends M8BTAmplifier {
  @override
  final name = "Amplifier";

  @override
  int get nuxIndex => 0;

  @override
  bool isSeparator = false;
  @override
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_OverDriveDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_OverDriveTone,
        midiControllerHandle: MidiControllerHandles.ampTone),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_OverDriveLevel,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Mic Level",
        handle: "miclevel",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "AMB Send",
        handle: "ambsend",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpMaster),
  ];
}
