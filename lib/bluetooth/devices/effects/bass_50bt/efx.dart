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

class RCBoostBass extends EFX {
  @override
  final name = "RC Boost";

  @override
  int get nuxIndex => 5;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Volume",
        handle: "volume",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel,
        midiControllerHandle: MidiControllerHandles.efxBass),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar4,
        midiCC: MidiCCValues.bCC_DelayLevel,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class TSDriveBass extends EFX {
  @override
  final name = "T Scream";

  @override
  int get nuxIndex => 6;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 41,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 67,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}

class MuffBass extends EFX {
  @override
  final name = "Muff";

  @override
  int get nuxIndex => 7;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxDepth),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];
}
