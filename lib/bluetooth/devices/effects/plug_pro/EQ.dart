// (c) 2020-2022 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class EQ extends Processor {
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iEQ;
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  int get nuxEnableMask => 0x40;
  bool get nuxEnableInverted => true;
  EffectEditorUI get editorUI => EffectEditorUI.EQ;

  int get midiCCEnableValue => MidiCCValuesPro.Head_iEQ;

  int get midiCCSelectionValue => MidiCCValuesPro.Head_iEQ;
}

class EQSixBand extends EQ {
  final name = "6-Band";

  int get nuxIndex => 1;

  List<Parameter> parameters = [
    Parameter(
        name: "100",
        handle: "eq_p1",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para1,
        midiCC: MidiCCValuesPro.EQ_Para1),
    Parameter(
        name: "220",
        handle: "eq_p2",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para2,
        midiCC: MidiCCValuesPro.EQ_Para2),
    Parameter(
        name: "500",
        handle: "eq_p3",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para3,
        midiCC: MidiCCValuesPro.EQ_Para3),
    Parameter(
        name: "1.2K",
        handle: "eq_p4",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para4,
        midiCC: MidiCCValuesPro.EQ_Para4),
    Parameter(
        name: "2.6K",
        handle: "eq_p5",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para5,
        midiCC: MidiCCValuesPro.EQ_Para5),
    Parameter(
        name: "6.4K",
        handle: "eq_p6",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para6,
        midiCC: MidiCCValuesPro.EQ_Para6),
  ];
}

class EQTenBand extends EQ {
  final name = "10-Band";

  int get nuxIndex => 3;

  List<Parameter> parameters = [
    Parameter(
        name: "Vol",
        handle: "eq_p1",
        value: 15,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para1,
        midiCC: MidiCCValuesPro.EQ_Para1),
    Parameter(
        name: "31",
        handle: "eq_p2",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para2,
        midiCC: MidiCCValuesPro.EQ_Para2),
    Parameter(
        name: "62",
        handle: "eq_p3",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para3,
        midiCC: MidiCCValuesPro.EQ_Para3),
    Parameter(
        name: "125",
        handle: "eq_p4",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para4,
        midiCC: MidiCCValuesPro.EQ_Para4),
    Parameter(
        name: "250",
        handle: "eq_p5",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para5,
        midiCC: MidiCCValuesPro.EQ_Para5),
    Parameter(
        name: "500",
        handle: "eq_p6",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para6,
        midiCC: MidiCCValuesPro.EQ_Para6),
    Parameter(
        name: "1K",
        handle: "eq_p7",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para7,
        midiCC: MidiCCValuesPro.EQ_Para7),
    Parameter(
        name: "2K",
        handle: "eq_p8",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para8,
        midiCC: MidiCCValuesPro.EQ_Para8),
    Parameter(
        name: "4K",
        handle: "eq_p9",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para9,
        midiCC: MidiCCValuesPro.EQ_Para9),
    Parameter(
        name: "8K",
        handle: "eq_p10",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para10,
        midiCC: MidiCCValuesPro.EQ_Para10),
    Parameter(
        name: "16K",
        handle: "eq_p11",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para11,
        midiCC: MidiCCValuesPro.EQ_Para11),
  ];
}
