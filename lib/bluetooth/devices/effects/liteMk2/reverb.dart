import 'package:mighty_plug_manager/bluetooth/devices/effects/plug_pro/Reverb.dart';

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

class RoomReverbLiteMk2 extends Reverb {
  @override
  final name = "Room";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1,
        midiControllerHandle: MidiControllerHandles.reverbDecay),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2,
        midiControllerHandle: MidiControllerHandles.reverbMix),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para3,
        midiCC: MidiCCValuesPro.RVB_Para3,
        midiControllerHandle: MidiControllerHandles.reverbTone),
  ];
}

class HallReverbLiteMk2 extends Reverb {
  @override
  final name = "Hall";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1,
        midiControllerHandle: MidiControllerHandles.reverbDecay),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2,
        midiControllerHandle: MidiControllerHandles.reverbMix),
    Parameter(
        name: "Tone",
        handle: "liveliness",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para3,
        midiCC: MidiCCValuesPro.RVB_Para3,
        midiControllerHandle: MidiControllerHandles.reverbTone),
  ];
}

class DampReverbLiteMk2 extends DampReverbPro {
  @override
  int get nuxIndex => 5;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Decay",
        handle: "decay",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para1,
        midiCC: MidiCCValuesPro.RVB_Para1,
        midiControllerHandle: MidiControllerHandles.reverbDecay),
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.RVB_Para2,
        midiCC: MidiCCValuesPro.RVB_Para2,
        midiControllerHandle: MidiControllerHandles.reverbMix)
  ];
}
