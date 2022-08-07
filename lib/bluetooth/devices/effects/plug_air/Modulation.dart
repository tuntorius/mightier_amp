// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Modulation extends Processor {
  int get nuxDataLength => 3;
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
  final name = "Chorus";

  int get nuxIndex => 1;
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
  final name = "ST Chorus";

  int get nuxIndex => 2;
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
  final name = "Flanger";

  int get nuxIndex => 3;
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
  final name = "U-Vibe";

  int get nuxIndex => 4;
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
  final name = "Tremolo";

  int get nuxIndex => 5;
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
  final name = "PH 100";

  int get nuxIndex => 0;
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
  final name = "CE-1";

  int get nuxIndex => 1;
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
  final name = "ST Chorus";

  int get nuxIndex => 2;
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
  final name = "SCF";

  int get nuxIndex => 3;
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
