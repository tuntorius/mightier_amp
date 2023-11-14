import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';
import '../plug_pro/EFX.dart';

class RoseCompLiteMk2 extends EFXPro {
  @override
  final name = "Rose Comp";

  @override
  int get nuxIndex => 14;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.compSustain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.compLevel),
  ];
}

class KCompLiteMk2 extends EFXPro {
  @override
  final name = "K Comp";

  @override
  int get nuxIndex => 15;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.compSustain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.CMP_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.compLevel),
    Parameter(
        name: "Clipping",
        handle: "clipping",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.compThreshold),
  ];
}

class TouchWahLiteMk2 extends EFXPro {
  @override
  int get nuxIndex => 16;

  @override
  final name = "Touch Wah";

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Type",
        handle: "type",
        value: 81,
        formatter: ValueFormatters.touchWahFormatterLiteMk2,
        devicePresetIndex: 0,
        midiCC: MidiCCValuesPro.EFX_Para1),
    Parameter(
        name: "Wow",
        handle: "wow",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: 0,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Sense",
        handle: "sense",
        value: 27,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: 0,
        midiCC: MidiCCValuesPro.EFX_Para3,
        midiControllerHandle: MidiControllerHandles.efxRate),
  ];
}

class TremoloEFXLiteMk2 extends EFXPro {
  @override
  final name = "Tremolo";

  @override
  int get nuxIndex => 17;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 70,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 15,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxDepth),
  ];
}

class VibeEFXLiteMk2 extends EFXPro {
  @override
  final name = "U-Vibe";

  @override
  int get nuxIndex => 18;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "Rate",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.efxRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.efxDepth),
    Parameter(
        name: "Mode",
        handle: "mode",
        value: 0,
        formatter: ValueFormatters.vibeModePro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para3,
        midiCC: MidiCCValuesPro.EFX_Para3),
  ];
}

class PH100LiteMk2 extends EFXPro {
  @override
  final name = "PH 100";

  @override
  int get nuxIndex => 19;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Intensity",
        handle: "depth",
        value: 60,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para1,
        midiCC: MidiCCValuesPro.EFX_Para1,
        midiControllerHandle: MidiControllerHandles.modIntensity),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 39,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.EFX_Para2,
        midiCC: MidiCCValuesPro.EFX_Para2,
        midiControllerHandle: MidiControllerHandles.modRate),
  ];
}
