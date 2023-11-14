import 'package:mighty_plug_manager/bluetooth/devices/value_formatters/ValueFormatter.dart';

import '../../NuxConstants.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';
import '../plug_pro/Delay.dart';

class AnalogDelayLiteMk2 extends DelayPro {
  @override
  final name = "Analog";

  @override
  int get nuxIndex => 1;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Time",
        handle: "rate",
        value: 50,
        formatter: ValueFormatters.tempoProAnalog,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Repeat",
        handle: "echo",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mix",
        handle: "intensity",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayLevel),
  ];
}

class DigitalDelayLiteV2 extends DelayPro {
  @override
  final name = "Digital";

  @override
  int get nuxIndex => 2;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        formatter: ValueFormatters.tempoProAnalog,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Repeat",
        handle: "feedback",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mix",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayLevel),
  ];
}

class ModDelayLiteMk2 extends DelayPro {
  @override
  final name = "Modulation";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Time",
        handle: "time",
        value: 49,
        formatter: ValueFormatters.tempoProMod,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 48,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mix",
        handle: "level",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayLevel),
    Parameter(
        name: "Mod",
        handle: "mod",
        value: 68,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para4,
        midiCC: MidiCCValuesPro.DLY_Para4,
        midiControllerHandle: MidiControllerHandles.delayMod),
  ];
}

class TapeEchoLiteMk2 extends DelayPro {
  @override
  final name = "Tape Echo";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Time",
        handle: "time",
        value: 61,
        formatter: ValueFormatters.tempoProTapeEcho,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 56,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mix",
        handle: "level",
        value: 43,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayLevel),
  ];
}

class PhiDelayLiteMk2 extends DelayPro {
  @override
  final name = "Phi Delay";

  @override
  int get nuxIndex => 5;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        formatter: ValueFormatters.tempoPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para1,
        midiCC: MidiCCValuesPro.DLY_Para1,
        midiControllerHandle: MidiControllerHandles.delayTime),
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para2,
        midiCC: MidiCCValuesPro.DLY_Para2,
        midiControllerHandle: MidiControllerHandles.delayRepeat),
    Parameter(
        name: "Mix",
        handle: "level",
        value: 45,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.DLY_Para3,
        midiCC: MidiCCValuesPro.DLY_Para3,
        midiControllerHandle: MidiControllerHandles.delayLevel),
  ];
}
