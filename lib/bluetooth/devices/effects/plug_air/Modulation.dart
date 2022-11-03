// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Modulation extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugAir.modfxtype;
  @override
  int? get nuxEnableIndex => PresetDataIndexPlugAir.modfxenable;
  //row 1247: 0-phaser, 1-chorus, 2-Stereo chorus, 3-Flanger, 4-Vibe, 5-Tremolo
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValues.bCC_ModfxEnable;
  @override
  int get midiCCSelectionValue => MidiCCValues.bCC_ModfxMode;
}

class Phaser extends Modulation {
  @override
  final name = "Phaser";

  @override
  int get nuxIndex => 0;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 39,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Feedback",
        handle: "feedback",
        value: 32,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class Chorus extends Modulation {
  @override
  final name = "Chorus";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 88,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 64,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class STChorus extends Modulation {
  @override
  final name = "ST Chorus";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 74,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 36,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class Flanger extends Modulation {
  @override
  final name = "Flanger";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 56,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 68,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class Vibe extends Modulation {
  @override
  final name = "U-Vibe";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 54,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Mode",
        handle: "mode",
        value: 0,
        formatter: ValueFormatters.vibeMode,
        devicePresetIndex: PresetDataIndexPlugAir.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class Tremolo extends Modulation {
  @override
  final name = "Tremolo";

  @override
  int get nuxIndex => 5;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 59,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
  ];
}

class PH100 extends Modulation {
  @override
  final name = "PH 100";

  @override
  int get nuxIndex => 0;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Intensity",
        handle: "depth",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar1rate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 39,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar2depth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
  ];
}

class CE1 extends Modulation {
  @override
  final name = "CE-1";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Intensity",
        handle: "mix",
        value: 64,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar1rate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 88,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar2depth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar3mix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class STChorusv2 extends Modulation {
  @override
  final name = "ST Chorus";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Intensity",
        handle: "mix",
        value: 36,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar1rate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Width",
        handle: "depth",
        value: 74,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar2depth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar3mix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}

class SCF extends Modulation {
  @override
  final name = "SCF";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Speed",
        handle: "rate",
        value: 56,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar1rate,
        midiCC: MidiCCValues.bCC_ModfxRate),
    Parameter(
        name: "Width",
        handle: "depth",
        value: 68,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar2depth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Intensity",
        handle: "mix",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar3mix,
        midiCC: MidiCCValues.bCC_ChorusLevel),
  ];
}
