// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class Modulation extends Processor {
  //TODO: check if correct
  int? get nuxEffectTypeIndex => PresetDataIndexLite.modfxtype;
  int? get nuxEnableIndex => PresetDataIndexLite.modfxenable;
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  int get midiCCEnableValue => MidiCCValues.bCC_ModfxEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_ModfxMode;
}

class Phaser extends Modulation {
  final name = "Phaser";

  int get nuxIndex => 0;
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
  final name = "Chorus";

  int get nuxIndex => 1;
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
  final name = "Tremolo";

  int get nuxIndex => 2;
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
