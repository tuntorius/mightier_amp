// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

abstract class Modulation extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexLite.modfxtype;
  @override
  int? get nuxEnableIndex => PresetDataIndexLite.modfxenable;

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  //row 1247: 0-phaser, 1-chorus, 2-Stereo chorus, 3-Flanger, 4-Vibe, 5-Tremolo

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
        devicePresetIndex: PresetDataIndexLite.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
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
        devicePresetIndex: PresetDataIndexLite.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 88,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
  ];
}

class Tremolo extends Modulation {
  @override
  final name = "Tremolo";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 59,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
  ];
}

class Vibe extends Modulation {
  @override
  final name = "Vibe";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 54,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
  ];
}
