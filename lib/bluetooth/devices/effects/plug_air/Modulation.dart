// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
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

  //MIDI foot controller stuff
  @override
  MidiControllerHandle? get midiControlOff => MidiControllerHandles.modOff;
  @override
  MidiControllerHandle? get midiControlOn => MidiControllerHandles.modOn;
  @override
  MidiControllerHandle? get midiControlToggle =>
      MidiControllerHandles.modToggle;
  @override
  MidiControllerHandle? get midiControlPrev => MidiControllerHandles.modPrev;
  @override
  MidiControllerHandle? get midiControlNext => MidiControllerHandles.modNext;
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Feedback",
        handle: "feedback",
        value: 32,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel,
        midiControllerHandle: MidiControllerHandles.modIntensity),
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 88,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 64,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel,
        midiControllerHandle: MidiControllerHandles.modIntensity),
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 74,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 36,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel,
        midiControllerHandle: MidiControllerHandles.modIntensity),
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 68,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel,
        midiControllerHandle: MidiControllerHandles.modIntensity),
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modIntensity),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 39,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar2depth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modRate),
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modIntensity),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 88,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar2depth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar3mix,
        midiCC: MidiCCValues.bCC_ChorusLevel,
        midiControllerHandle: MidiControllerHandles.modRate),
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modIntensity),
    Parameter(
        name: "Width",
        handle: "depth",
        value: 74,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar2depth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar3mix,
        midiCC: MidiCCValues.bCC_ChorusLevel,
        midiControllerHandle: MidiControllerHandles.modRate),
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
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Width",
        handle: "depth",
        value: 68,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar2depth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Intensity",
        handle: "mix",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.modfxvar3mix,
        midiCC: MidiCCValues.bCC_ChorusLevel,
        midiControllerHandle: MidiControllerHandles.modIntensity),
  ];
}
