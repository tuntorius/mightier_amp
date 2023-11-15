import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';
import '../plug_air/EFX.dart';

class KCompBass extends EFX {
  @override
  final name = "K Comp";

  @override
  int get nuxIndex => 0;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 59,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Level",
        handle: "Level",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Clipping",
        handle: "sense",
        value: 19,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel,
        midiControllerHandle: MidiControllerHandles.efxRate),
  ];
}

class RoseCompBass extends EFX {
  @override
  final name = "Rose Comp";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 59,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Level",
        handle: "Level",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxLevel)
  ];
}

class TouchWahBass extends EFX {
  @override
  final name = "Touch Wah";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Wow",
        handle: "wow",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar1,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Sense",
        handle: "sense",
        value: 27,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxRate),
    Parameter(
        name: "Type",
        handle: "type",
        value: 1,
        formatter: ValueFormatters.touchWahFormatter,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class UniVibeBass extends UniVibe {
  @override
  int get nuxIndex => 3;
}

class Phase100Bass extends EFX {
  @override
  final name = "Phase 100";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Intensity",
        handle: "intensity",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Speed",
        handle: "speed",
        value: 39,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxRate),
  ];
}
