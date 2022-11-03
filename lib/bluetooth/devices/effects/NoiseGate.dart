import '../NuxConstants.dart';
import '../value_formatters/ValueFormatter.dart';
import 'Processor.dart';

class NoiseGate2Param extends Processor {
  @override
  final name = "Noise Gate";

  @override
  int get nuxIndex => 0;
  @override
  int? get nuxEffectTypeIndex => null;
  @override
  int? get nuxEnableIndex => PresetDataIndexPlugAir.ngenable;

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValues.bCC_GateEnable;

  @override
  int get midiCCSelectionValue => 0;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Threshold",
        handle: "threshold",
        value: 41,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ngthresold,
        midiCC: MidiCCValues.bCC_GateThresold),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 47,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ngsustain,
        midiCC: MidiCCValues.bCC_GateDecay),
  ];
}

class NoiseGate1Param extends Processor {
  @override
  final name = "Noise Gate";

  @override
  int get nuxIndex => 0;

  //noise gate has no type specified
  @override
  int? get nuxEffectTypeIndex => null;
  @override
  int? get nuxEnableIndex => PresetDataIndexLite.ngenable;

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValues.bCC_GateEnable;

  @override
  int get midiCCSelectionValue => 0;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Threshold",
        handle: "threshold",
        value: 41,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ngthresold,
        midiCC: MidiCCValues.bCC_GateThresold),
  ];
}

class NoiseGatePro extends Processor {
  @override
  final name = "Noise Gate";

  @override
  int get nuxIndex => 1;

  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iNG;
  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  @override
  int get nuxEnableMask => 0x40;
  @override
  bool get nuxEnableInverted => true;

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iNG;

  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iNG;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Sensitivity",
        handle: "sensitivity",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.NG_Para1,
        midiCC: MidiCCValuesPro.NG_Para1),
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.NG_Para2,
        midiCC: MidiCCValuesPro.NG_Para2),
  ];
}
