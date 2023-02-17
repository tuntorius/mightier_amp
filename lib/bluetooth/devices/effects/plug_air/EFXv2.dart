import '../../NuxConstants.dart';
import '../../NuxMightyPlugAir.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';
import 'EFX.dart';

class PH100EFX extends EFX {
  @override
  final name = "PH 100";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Intensity",
        handle: "depth", //legacy
        value: 78,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 54,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxRate),
  ];
}

class STSinger extends EFX {
  @override
  final name = "ST Singer";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "level",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain,
        midiControllerHandle: MidiControllerHandles.efxLevel),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 78,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Filter",
        handle: "filter",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel,
        midiControllerHandle: MidiControllerHandles.efxTone),
  ];

  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return null;
    return nuxIndex;
  }
}

class Katana extends EFX {
  @override
  final name = "Katana";

  @override
  int get nuxIndex => 6;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Boost",
        handle: "gain",
        value: 100,
        formatter: ValueFormatters.boostMode,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Volume",
        handle: "level",
        value: 78,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxLevel),
  ];

  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Boost().nuxIndex;
    return nuxIndex;
  }
}

class RedDirt extends EFX {
  @override
  final name = "Red Dirt";

  @override
  int get nuxIndex => 10;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain,
        midiControllerHandle: MidiControllerHandles.efxGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 30,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxTone),
    Parameter(
        name: "Level",
        handle: "level",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel,
        midiControllerHandle: MidiControllerHandles.efxLevel),
  ];
}

class RoseComp extends EFX {
  @override
  final name = "Rose Comp";

  @override
  int get nuxIndex => 13;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone,
        midiControllerHandle: MidiControllerHandles.efxDepth),
    Parameter(
        name: "Level",
        handle: "level",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain,
        midiControllerHandle: MidiControllerHandles.efxLevel),
  ];

  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return null;
    return nuxIndex;
  }
}
