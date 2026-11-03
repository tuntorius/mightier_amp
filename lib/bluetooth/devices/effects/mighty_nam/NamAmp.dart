import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

/// NAM Amp processor for the mighty-nam firmware.
///
/// Maps the 6 NAM tone stack controls directly to NUX amplifier parameter
/// registers (AMP_Para1 through AMP_Para6) used by the custom firmware.
class NamAmp extends Amplifier {
  @override
  final String name = "NAM Model";

  @override
  int get nuxIndex => 0;

  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iAMP;

  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;

  @override
  int get nuxEnableMask => 0x40;

  @override
  bool get nuxEnableInverted => true;

  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;

  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iAMP;

  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iAMP;

  @override
  int get defaultCab => 0;

  @override
  MidiControllerHandle? get midiControlOff => MidiControllerHandles.ampOff;
  @override
  MidiControllerHandle? get midiControlOn => MidiControllerHandles.ampOn;
  @override
  MidiControllerHandle? get midiControlToggle => MidiControllerHandles.ampToggle;
  @override
  MidiControllerHandle? get midiControlPrev => MidiControllerHandles.ampPrev;
  @override
  MidiControllerHandle? get midiControlNext => MidiControllerHandles.ampNext;

  @override
  List<Parameter> parameters = [
    Parameter(
      name: "Input",
      handle: "gain",
      value: 50,
      formatter: ValueFormatters.percentageMPPro,
      devicePresetIndex: PresetDataIndexPlugPro.AMP_Para1, // 27
      midiCC: MidiCCValuesPro.AMP_Para1, // 23
      midiControllerHandle: MidiControllerHandles.ampGain,
    ),
    Parameter(
      name: "Bass",
      handle: "bass",
      value: 50,
      formatter: ValueFormatters.percentageMPPro,
      devicePresetIndex: PresetDataIndexPlugPro.AMP_Para2, // 28
      midiCC: MidiCCValuesPro.AMP_Para2, // 24
      midiControllerHandle: MidiControllerHandles.ampBass,
    ),
    Parameter(
      name: "Middle",
      handle: "middle",
      value: 50,
      formatter: ValueFormatters.percentageMPPro,
      devicePresetIndex: PresetDataIndexPlugPro.AMP_Para3, // 29
      midiCC: MidiCCValuesPro.AMP_Para3, // 25
      midiControllerHandle: MidiControllerHandles.ampMiddle,
    ),
    Parameter(
      name: "Treble",
      handle: "treble",
      value: 50,
      formatter: ValueFormatters.percentageMPPro,
      devicePresetIndex: PresetDataIndexPlugPro.AMP_Para4, // 30
      midiCC: MidiCCValuesPro.AMP_Para4, // 26
      midiControllerHandle: MidiControllerHandles.ampTreble,
    ),
    Parameter(
      name: "Mix",
      handle: "mix",
      value: 100,
      formatter: ValueFormatters.percentageMPPro,
      devicePresetIndex: PresetDataIndexPlugPro.AMP_Para5, // 31
      midiCC: MidiCCValuesPro.AMP_Para5, // 27
    ),
    Parameter(
      name: "Output",
      handle: "level",
      value: 50,
      formatter: ValueFormatters.percentageMPPro,
      masterVolume: true,
      devicePresetIndex: PresetDataIndexPlugPro.AMP_Para6, // 32
      midiCC: MidiCCValuesPro.AMP_Para6, // 28
      midiControllerHandle: MidiControllerHandles.ampVolume,
    ),
  ];
}