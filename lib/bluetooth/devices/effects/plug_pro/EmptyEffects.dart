import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

class WahDummyPro extends Processor {
  @override
  final name = "Wah";

  @override
  int get nuxIndex => 1;
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iWAH;
  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  @override
  int get nuxEnableMask => 0x40;
  @override
  bool get nuxEnableInverted => true;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iWAH;

  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iWAH;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Param1",
        handle: "param1",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.WAH_Para1,
        midiCC: MidiCCValuesPro.WAH_Para1),
    Parameter(
        name: "Param2",
        handle: "param2",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.WAH_Para2,
        midiCC: MidiCCValuesPro.WAH_Para2),
  ];
}
