// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class LiteAmplifier extends Amplifier {
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
}

class AmpClean extends LiteAmplifier {
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
        midiCC: MidiCCValues.bCC_OverDriveDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_OverDriveLevel),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivetone, //check this
        midiCC: MidiCCValues.bCC_OverDriveTone),
  ];
}
