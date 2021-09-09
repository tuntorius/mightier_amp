import '../../NuxConstants.dart';
import '../../NuxMightyPlugAir.dart';
import '../Processor.dart';
import 'EFX.dart';

class PH100EFX extends EFX {
  final name = "PH 100";

  int get nuxIndex => 3;
  List<Parameter> parameters = [
    Parameter(
        name: "Intensity",
        handle: "depth", //legacy
        value: 78,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 54,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
  ];
}

class STSinger extends EFX {
  final name = "ST Singer";

  int get nuxIndex => 4;
  List<Parameter> parameters = [
    Parameter(
        name: "Volume",
        handle: "level",
        value: 35,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 78,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Filter",
        handle: "filter",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];

  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return null;
    return nuxIndex;
  }
}

class Katana extends EFX {
  final name = "Katana";

  int get nuxIndex => 6;

  List<Parameter> parameters = [
    Parameter(
        name: "Boost",
        handle: "gain",
        value: 100,
        valueType: ValueType.boostMode,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Volume",
        handle: "level",
        value: 78,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
  ];

  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return Boost().nuxIndex;
    return nuxIndex;
  }
}

class RedDirt extends EFX {
  final name = "Red Dirt";

  int get nuxIndex => 10;
  List<Parameter> parameters = [
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 80,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 30,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Level",
        handle: "level",
        value: 40,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
  ];
}

class RoseComp extends EFX {
  final name = "Rose Comp";

  int get nuxIndex => 13;
  List<Parameter> parameters = [
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Level",
        handle: "level",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
  ];

  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir15.index) return null;
    return nuxIndex;
  }
}
