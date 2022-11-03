// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Modulation extends Processor {
  //TODO: check if correct
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexLite.modfxtype;
  @override
  int? get nuxEnableIndex => PresetDataIndexLite.modfxenable;
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
        name: "Depth",
        handle: "depth",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 39,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate)
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
        name: "Depth",
        handle: "depth",
        value: 88,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate),
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
        name: "Depth",
        handle: "depth",
        value: 63,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 59,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexLite.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate)
  ];
}
