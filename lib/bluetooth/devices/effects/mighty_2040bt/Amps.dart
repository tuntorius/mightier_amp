// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class MXXBTAmplifier extends Amplifier {
  //TODO: check if correct
  int? get nuxEffectTypeIndex => PresetDataIndexLite.drivetype;
  int? get nuxEnableIndex => null;
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  int get midiCCEnableValue => MidiCCValues.bCC_AmpEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_NotUsed;
  int get defaultCab => 0;
}

class Amp1 extends MXXBTAmplifier {
  final name = "Amplifier";

  int get nuxIndex => 1;

  bool isSeparator = false;
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_AmpBass),
    Parameter(
        name: "Mid",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpMid),
    Parameter(
        name: "High",
        handle: "high",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpHigh),
  ];
}
/*
class AmpDrive2 extends MXXBTAmplifier {
  final name = "Amp - OverDrive 2";

  int get nuxIndex => 5;

  bool isSeparator = false;
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_AmpBass),
    Parameter(
        name: "Mid",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpMid),
    Parameter(
        name: "High",
        handle: "high",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpHigh),
  ];
}

class AmpClean1 extends MXXBTAmplifier {
  final name = "Amp - Clean 1";

  int get nuxIndex => 0;

  bool isSeparator = false;
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_AmpBass),
    Parameter(
        name: "Mid",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpMid),
    Parameter(
        name: "High",
        handle: "high",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpHigh),
  ];
}

class AmpClean2 extends MXXBTAmplifier {
  final name = "Amp - Clean 2";

  int get nuxIndex => 4;

  bool isSeparator = false;
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_AmpBass),
    Parameter(
        name: "Mid",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpMid),
    Parameter(
        name: "High",
        handle: "high",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpHigh),
  ];
}

class AmpMetal1 extends MXXBTAmplifier {
  final name = "Amp - Metal 1";

  int get nuxIndex => 2;

  bool isSeparator = false;
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_AmpBass),
    Parameter(
        name: "Mid",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpMid),
    Parameter(
        name: "High",
        handle: "high",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpHigh),
  ];
}

class AmpMetal2 extends MXXBTAmplifier {
  final name = "Amp - Metal 2";

  int get nuxIndex => 6;

  bool isSeparator = false;
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_AmpBass),
    Parameter(
        name: "Mid",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpMid),
    Parameter(
        name: "High",
        handle: "high",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpHigh),
  ];
}

class AmpLead1 extends MXXBTAmplifier {
  final name = "Amp - Lead 1";

  int get nuxIndex => 3;

  bool isSeparator = false;
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_AmpBass),
    Parameter(
        name: "Mid",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpMid),
    Parameter(
        name: "High",
        handle: "high",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpHigh),
  ];
}

class AmpLead2 extends MXXBTAmplifier {
  final name = "Amp - Lead 2";

  int get nuxIndex => 7;

  bool isSeparator = false;
  String category = "";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivegain,
        midiCC: MidiCCValues.bCC_AmpDrive),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        masterVolume: true,
        devicePresetIndex: PresetDataIndexLite.drivetone,
        midiCC: MidiCCValues.bCC_AmpMaster),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.drivelevel,
        midiCC: MidiCCValues.bCC_AmpBass),
    Parameter(
        name: "Mid",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.miclevel,
        midiCC: MidiCCValues.bCC_AmpMid),
    Parameter(
        name: "High",
        handle: "high",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.micambsend,
        midiCC: MidiCCValues.bCC_AmpHigh),
  ];
}
*/