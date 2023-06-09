// (c) 2020-2022 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

abstract class EQ extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iEQ;
  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  @override
  int get nuxEnableMask => 0x40;
  @override
  bool get nuxEnableInverted => true;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.EQ;

  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iEQ;

  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iEQ;

  //MIDI foot controller stuff
  @override
  MidiControllerHandle? get midiControlOff => MidiControllerHandles.eqOff;
  @override
  MidiControllerHandle? get midiControlOn => MidiControllerHandles.eqOn;
  @override
  MidiControllerHandle? get midiControlToggle => MidiControllerHandles.eqToggle;
  @override
  MidiControllerHandle? get midiControlPrev => MidiControllerHandles.eqPrev;
  @override
  MidiControllerHandle? get midiControlNext => MidiControllerHandles.eqNext;
}

class EQSixBand extends EQ {
  @override
  final name = "6-Band";

  @override
  int get nuxIndex => 1;

  @override
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
  @override
  final name = "10-Band";

  @override
  int get nuxIndex => 3;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Vol",
        handle: "eq_vol",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para1,
        midiCC: MidiCCValuesPro.EQ_Para1),
    Parameter(
        name: "31",
        handle: "eq_b1",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para2,
        midiCC: MidiCCValuesPro.EQ_Para2),
    Parameter(
        name: "62",
        handle: "eq_b2",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para3,
        midiCC: MidiCCValuesPro.EQ_Para3),
    Parameter(
        name: "125",
        handle: "eq_b3",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para4,
        midiCC: MidiCCValuesPro.EQ_Para4),
    Parameter(
        name: "250",
        handle: "eq_b4",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para5,
        midiCC: MidiCCValuesPro.EQ_Para5),
    Parameter(
        name: "500",
        handle: "eq_b5",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para6,
        midiCC: MidiCCValuesPro.EQ_Para6),
    Parameter(
        name: "1K",
        handle: "eq_b6",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para7,
        midiCC: MidiCCValuesPro.EQ_Para7),
    Parameter(
        name: "2K",
        handle: "eq_b7",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para8,
        midiCC: MidiCCValuesPro.EQ_Para8),
    Parameter(
        name: "4K",
        handle: "eq_b8",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para9,
        midiCC: MidiCCValuesPro.EQ_Para9),
    Parameter(
        name: "8K",
        handle: "eq_b9",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para10,
        midiCC: MidiCCValuesPro.EQ_Para10),
    Parameter(
        name: "16K",
        handle: "eq_b10",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para11,
        midiCC: MidiCCValuesPro.EQ_Para11),
  ];
}

class EQTenBandBT extends EQ {
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Vol",
        handle: "eq_vol",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para1,
        midiCC: MidiCCValuesPro.AUX_BAND_1),
    Parameter(
        name: "31",
        handle: "eq_b1",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para2,
        midiCC: MidiCCValuesPro.AUX_BAND_2),
    Parameter(
        name: "62",
        handle: "eq_b2",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para3,
        midiCC: MidiCCValuesPro.AUX_BAND_3),
    Parameter(
        name: "125",
        handle: "eq_b3",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para4,
        midiCC: MidiCCValuesPro.AUX_BAND_4),
    Parameter(
        name: "250",
        handle: "eq_b4",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para5,
        midiCC: MidiCCValuesPro.AUX_BAND_5),
    Parameter(
        name: "500",
        handle: "eq_b5",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para6,
        midiCC: MidiCCValuesPro.AUX_BAND_6),
    Parameter(
        name: "1K",
        handle: "eq_b6",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para7,
        midiCC: MidiCCValuesPro.AUX_BAND_7),
    Parameter(
        name: "2K",
        handle: "eq_b7",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para8,
        midiCC: MidiCCValuesPro.AUX_BAND_8),
    Parameter(
        name: "4K",
        handle: "eq_b8",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para9,
        midiCC: MidiCCValuesPro.AUX_BAND_9),
    Parameter(
        name: "8K",
        handle: "eq_b9",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para10,
        midiCC: MidiCCValuesPro.AUX_BAND_10),
    Parameter(
        name: "16K",
        handle: "eq_b10",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para11,
        midiCC: MidiCCValuesPro.AUX_BAND_11),
  ];

  //TODO: this might not be needed
  List<int> getNuxCommand() {
    List<int> data = [];

    for (int i = 0; i < parameters.length; i++) {
      data.add(parameters[i].midiValue);
    }
    return data;
  }

  @override
  void setupFromNuxPayload(List<int> nuxData) {
    for (int i = 0; i < parameters.length; i++) {
      parameters[i].midiValue = nuxData[i];
    }
  }

  @override
  String get name => "Bluetooth EQ";

  @override
  int get nuxIndex => 0;
}

class EQTenBandSpeaker extends EQ {
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Vol",
        handle: "eq_vol",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para1,
        midiCC: MidiCCValuesPro.SPK_EQ_VOL),
    Parameter(
        name: "31",
        handle: "eq_b1",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para2,
        midiCC: MidiCCValuesPro.SPK_EQ_1),
    Parameter(
        name: "62",
        handle: "eq_b2",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para3,
        midiCC: MidiCCValuesPro.SPK_EQ_2),
    Parameter(
        name: "125",
        handle: "eq_b3",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para4,
        midiCC: MidiCCValuesPro.SPK_EQ_3),
    Parameter(
        name: "250",
        handle: "eq_b4",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para5,
        midiCC: MidiCCValuesPro.SPK_EQ_4),
    Parameter(
        name: "500",
        handle: "eq_b5",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para6,
        midiCC: MidiCCValuesPro.SPK_EQ_5),
    Parameter(
        name: "1K",
        handle: "eq_b6",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para7,
        midiCC: MidiCCValuesPro.SPK_EQ_6),
    Parameter(
        name: "2K",
        handle: "eq_b7",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para8,
        midiCC: MidiCCValuesPro.SPK_EQ_7),
    Parameter(
        name: "4K",
        handle: "eq_b8",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para9,
        midiCC: MidiCCValuesPro.SPK_EQ_8),
    Parameter(
        name: "8K",
        handle: "eq_b9",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para10,
        midiCC: MidiCCValuesPro.SPK_EQ_9),
    Parameter(
        name: "16K",
        handle: "eq_b10",
        value: 0,
        formatter: ValueFormatters.decibelEQ,
        devicePresetIndex: PresetDataIndexPlugPro.EQ_Para11,
        midiCC: MidiCCValuesPro.SPK_EQ_10),
  ];

  //TODO: this might not be needed
  List<int> getNuxCommand() {
    List<int> data = [];

    for (int i = 0; i < parameters.length; i++) {
      data.add(parameters[i].midiValue);
    }
    return data;
  }

  @override
  void setupFromNuxPayload(List<int> nuxData) {
    for (int i = 0; i < parameters.length; i++) {
      parameters[i].midiValue = nuxData[i];
    }
  }

  @override
  String get name => "Speaker EQ";

  @override
  int get nuxIndex => 0;
}
