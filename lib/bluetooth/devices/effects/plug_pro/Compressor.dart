// (c) 2020-2022 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Compressor extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iCMP;
  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  @override
  int get nuxEnableMask => 0x40;
  @override
  bool get nuxEnableInverted => true;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iCMP;
  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iCMP;
}

class RoseComp extends Compressor {
  @override
  final name = "Rose Comp";

  @override
  int get nuxIndex => 1;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para2,
        midiCC: MidiCCValuesPro.CMP_Para2),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para1,
        midiCC: MidiCCValuesPro.CMP_Para1),
  ];
}

class KComp extends Compressor {
  @override
  final name = "K Comp";

  @override
  int get nuxIndex => 2;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para2,
        midiCC: MidiCCValuesPro.CMP_Para2),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para1,
        midiCC: MidiCCValuesPro.CMP_Para1),
    Parameter(
        name: "Clipping",
        handle: "clipping",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para3,
        midiCC: MidiCCValuesPro.CMP_Para3),
  ];
}

class StudioComp extends Compressor {
  @override
  final name = "Studio Comp";

  @override
  int get nuxIndex => 3;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para3,
        midiCC: MidiCCValuesPro.CMP_Para3),
    Parameter(
        name: "Threshold",
        handle: "threshold",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para1,
        midiCC: MidiCCValuesPro.CMP_Para1),
    Parameter(
        name: "Ratio",
        handle: "ratio",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para2,
        midiCC: MidiCCValuesPro.CMP_Para2),
    Parameter(
        name: "Release",
        handle: "release",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para4,
        midiCC: MidiCCValuesPro.CMP_Para4)
  ];
}
