// (c) 2020-2022 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Compressor extends Processor {
  int get nuxDataLength => 4;
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  int get midiCCEnableValue => MidiCCValuesPro.Head_iCMP;
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iCMP;
}

class RoseComp extends Compressor {
  final name = "Rose Comp";

  int get nuxIndex => 1;

  List<Parameter> parameters = [
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para1,
        midiCC: MidiCCValuesPro.CMP_Para1),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para2,
        midiCC: MidiCCValuesPro.CMP_Para2),
  ];
}

class KComp extends Compressor {
  final name = "K Comp";

  int get nuxIndex => 2;

  List<Parameter> parameters = [
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para1,
        midiCC: MidiCCValuesPro.CMP_Para1),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para2,
        midiCC: MidiCCValuesPro.CMP_Para2),
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
  final name = "Studio Comp";

  int get nuxIndex => 3;

  List<Parameter> parameters = [
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
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para3,
        midiCC: MidiCCValuesPro.CMP_Para3),
    Parameter(
        name: "Release",
        handle: "release",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para4,
        midiCC: MidiCCValuesPro.CMP_Para4)
  ];
}
