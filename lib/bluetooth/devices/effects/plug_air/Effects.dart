library plug_air_effects;

import '../../NuxConstants.dart';
import '../Processor.dart';

class NoiseGate extends Processor {
  final name = "Noise Gate";

  int get nuxIndex => 0;

  int get midiCCEnableValue => MidiCCValues.bCC_GateEnable;

  int get midiCCSelectionValue => 0;

  List<Parameter> parameters = [
    Parameter(
        name: "Threshold",
        handle: "threshold",
        value: 41,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ngthresold,
        midiCC: MidiCCValues.bCC_GateThresold),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 47,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.ngsustain,
        midiCC: MidiCCValues.bCC_GateDecay),
  ];
}
