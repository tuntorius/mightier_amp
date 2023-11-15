import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';
import '../plug_air/Modulation.dart';

class STChorusBass extends Modulation {
  @override
  final name = "ST Chorus";

  @override
  int get nuxIndex => 0;

  //The parameters look wrong inside the app
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 74,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 36,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel,
        midiControllerHandle: MidiControllerHandles.modIntensity),
  ];
}

class FlangerBass extends Modulation {
  @override
  final name = "Flanger";

  @override
  int get nuxIndex => 1;

  //these are also suspicios
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 68,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.modfxrate,
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 56,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.modfxdepth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Width",
        handle: "width",
        value: 24,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.modfxmix,
        midiCC: MidiCCValues.bCC_ChorusLevel,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Feedback",
        handle: "feedback",
        value: 24,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar4,
        midiCC: MidiCCValues.bCC_DelayRepeat,
        midiControllerHandle: MidiControllerHandles.modIntensity)
  ];
}

class PH100BassMod extends Modulation {
  @override
  final name = "Phase 100";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Intensity",
        handle: "depth",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.modfxvar1rate,
        midiCC: MidiCCValues.bCC_ModfxRate,
        midiControllerHandle: MidiControllerHandles.modIntensity),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 39,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.modfxvar2depth,
        midiCC: MidiCCValues.bCC_ModfxDepth,
        midiControllerHandle: MidiControllerHandles.modRate),
  ];
}
