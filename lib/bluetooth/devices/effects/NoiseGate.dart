import '../NuxConstants.dart';
import '../value_formatters/ValueFormatter.dart';
import 'Processor.dart';

class NoiseGate2Param extends Processor {
  final name = "Noise Gate";

  int get nuxIndex => 0;
  int? get nuxEffectTypeIndex => null;
  int? get nuxEnableIndex => PresetDataIndexPlugAir.ngenable;

  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  int get midiCCEnableValue => MidiCCValues.bCC_GateEnable;

  int get midiCCSelectionValue => 0;

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
  final name = "Noise Gate";

  int get nuxIndex => 0;

  //noise gate has no type specified
  int? get nuxEffectTypeIndex => null;
  int? get nuxEnableIndex => PresetDataIndexLite.ngenable;

  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  int get midiCCEnableValue => MidiCCValues.bCC_GateEnable;

  int get midiCCSelectionValue => 0;

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
  final name = "Noise Gate";

  int get nuxIndex => 1;

  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iNG;
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  int get nuxEnableMask => 0x40;
  bool get nuxEnableInverted => true;

  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  int get midiCCEnableValue => MidiCCValuesPro.Head_iNG;

  int get midiCCSelectionValue => MidiCCValuesPro.Head_iNG;

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
