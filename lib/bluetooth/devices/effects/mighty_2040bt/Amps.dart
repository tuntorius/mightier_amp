// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

abstract class MXXBTAmplifier extends Amplifier {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndex2040BT.amp_type;
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

class Amp1 extends MXXBTAmplifier {
  @override
  final name = "Amplifier";

  @override
  int get nuxIndex => 1;

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
        devicePresetIndex: PresetDataIndex2040BT.amp_gain,
        midiCC: MidiCCValues.bCC_AmpDrive,
        midiControllerHandle: MidiControllerHandles.ampGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndex2040BT.amp_level,
        midiCC: MidiCCValues.bCC_AmpMaster,
        midiControllerHandle: MidiControllerHandles.ampVolume),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndex2040BT.amp_bass,
        midiCC: MidiCCValues.bCC_AmpBass,
        midiControllerHandle: MidiControllerHandles.ampBass),
    Parameter(
        name: "Mid",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndex2040BT.amp_mid,
        midiCC: MidiCCValues.bCC_AmpMid,
        midiControllerHandle: MidiControllerHandles.ampMiddle),
    Parameter(
        name: "High",
        handle: "high",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndex2040BT.amp_high,
        midiCC: MidiCCValues.bCC_AmpHigh,
        midiControllerHandle: MidiControllerHandles.ampTreble),
  ];
}
