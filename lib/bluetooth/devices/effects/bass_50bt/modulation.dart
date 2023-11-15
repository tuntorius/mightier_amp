import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';
import '../plug_air/Modulation.dart';

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
