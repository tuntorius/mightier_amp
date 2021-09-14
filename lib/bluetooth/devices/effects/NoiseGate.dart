import '../NuxConstants.dart';
import 'Processor.dart';

class NoiseGate2Param extends Processor {
  final name = "Noise Gate";

  int get nuxIndex => 0;

  int get midiCCEnableValue => MidiCCValues.bCC_GateEnable;

  int get midiCCSelectionValue => 0;

  int get nuxDataLength => 2;

  List<Parameter> parameters = [
    Parameter(
        name: "Threshold",
        handle: "threshold",
        value: 41,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ngthresold,
        midiCC: MidiCCValues.bCC_GateThresold),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 47,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ngsustain,
        midiCC: MidiCCValues.bCC_GateDecay),
  ];
}

class NoiseGate1Param extends Processor {
  final name = "Noise Gate";

  int get nuxIndex => 0;

  int get midiCCEnableValue => MidiCCValues.bCC_GateEnable;

  int get midiCCSelectionValue => 0;

  int get nuxDataLength => 1;

  List<Parameter> parameters = [
    Parameter(
        name: "Threshold",
        handle: "threshold",
        value: 41,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.ngthresold,
        midiCC: MidiCCValues.bCC_GateThresold),
  ];
}
