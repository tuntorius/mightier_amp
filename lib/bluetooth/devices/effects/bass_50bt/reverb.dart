import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';
import '../plug_air/Reverb.dart';

class RoomReverbBass extends Reverb {
  @override
  final name = "Room";

  @override
  int get nuxIndex => 0;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 35,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay,
        midiControllerHandle: MidiControllerHandles.reverbDecay),
    Parameter(
        name: "Level",
        handle: "level",
        value: 25,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbRouting,
        midiControllerHandle: MidiControllerHandles.reverbMix),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbLevel,
        midiControllerHandle: MidiControllerHandles.reverbTone)
  ];
}

class HallReverbBass extends Reverb {
  @override
  final name = "Hall";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 70,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay,
        midiControllerHandle: MidiControllerHandles.reverbDecay),
    Parameter(
        name: "Level",
        handle: "level",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbRouting,
        midiControllerHandle: MidiControllerHandles.reverbMix)
  ];
}

class PlateReverbBass extends Reverb {
  @override
  final name = "Plate";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 81,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay,
        midiControllerHandle: MidiControllerHandles.reverbDecay),
    Parameter(
        name: "Level",
        handle: "level",
        value: 66,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbRouting,
        midiControllerHandle: MidiControllerHandles.reverbMix)
  ];
}

class SpringReverbBass extends Reverb {
  @override
  final name = "Spring";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 32,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.reverbdecay,
        midiCC: MidiCCValues.bCC_ReverbDecay,
        midiControllerHandle: MidiControllerHandles.reverbDecay),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexBass50BT.reverbmix,
        midiCC: MidiCCValues.bCC_ReverbRouting,
        midiControllerHandle: MidiControllerHandles.reverbMix)
  ];
}
