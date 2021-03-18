// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../Processor.dart';

abstract class Modulation extends Processor {
  //row 1247: 0-phaser, 1-chorus, 2-Stereo chorus, 3-Flanger, 4-Vibe, 5-Tremolo

  int get midiCCEnableValue => MidiCCValues.bCC_ModfxEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_ModfxMode;
}

class Phaser extends Modulation {
  final name = "Phaser";

  int get nuxIndex => 0;
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 39,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Feedback",
        handle: "feedback",
        value: 32,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class Chorus extends Modulation {
  final name = "Chorus";

  int get nuxIndex => 1;
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 88,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 64,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class STChorus extends Modulation {
  final name = "ST Chorus";

  int get nuxIndex => 2;
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 74,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 36,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class Flanger extends Modulation {
  final name = "Flanger";

  int get nuxIndex => 3;
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 56,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 68,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 80,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class Vibe extends Modulation {
  final name = "Vibe";

  int get nuxIndex => 4;
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 54,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 80,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Mode",
        handle: "mode",
        value: 0,
        valueType: ValueType.vibeMode,
        devicePresetIndex: PresetDataIndex.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class Tremolo extends Modulation {
  final name = "Tremolo";

  int get nuxIndex => 5;
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 59,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 63,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
  ];
}
