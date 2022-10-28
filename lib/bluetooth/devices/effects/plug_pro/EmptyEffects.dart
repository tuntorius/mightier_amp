import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

class WahDummyPro extends Processor {
  final name = "Wah";

  int get nuxIndex => 1;
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iWAH;
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  int get nuxEnableMask => 0x40;
  bool get nuxEnableInverted => true;
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  int get midiCCEnableValue => MidiCCValuesPro.Head_iWAH;

  int get midiCCSelectionValue => MidiCCValuesPro.Head_iWAH;

  List<Parameter> parameters = [
    Parameter(
        name: "Sensitivity",
        handle: "sensitivity",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.WAH_Para1,
        midiCC: MidiCCValuesPro.WAH_Para1),
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.WAH_Para2,
        midiCC: MidiCCValuesPro.WAH_Para2),
  ];
}
