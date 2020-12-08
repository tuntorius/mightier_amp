// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../NuxConstants.dart';
import 'Processor.dart';

class DelayTapTimer {
  final timeout = 1500;
  List<DateTime> timeArray = List<DateTime>();

  addClickTime() {
    timeArray.add(DateTime.now());
    while (timeArray.length > 3) timeArray.removeAt(0);
  }

  calculate() {
    if (timeArray.length < 2) return false;
    var length = timeArray.length;
    var current = timeArray[length - 1].millisecondsSinceEpoch;
    var last = timeArray[length - 2].millisecondsSinceEpoch;
    //check for timeout and clear if it is

    if (length > 2 && (current - last >= this.timeout)) {
      while (timeArray.length > 1) timeArray.removeAt(0);

      return false;
    }

    if (length == 2) return current - last;

    var first = timeArray[length - 3].millisecondsSinceEpoch;
    return (current - first) / 2;
  }
}

abstract class Delay extends Processor {
  int get deviceSwitchIndex => MidiCCValues.bCC_DelayEnable;
  int get deviceSelectionIndex => MidiCCValues.bCC_DelayMode;
}

class AnalogDelay extends Delay {
  final name = "Analog Delay";

  int get nuxIndex => 0;

  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndex.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class TapeEcho extends Delay {
  final name = "Tape Echo";

  int get nuxIndex => 1;
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndex.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class DigitalDelay extends Delay {
  final name = "Digital Delay";

  int get nuxIndex => 2;
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndex.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}

class PingPong extends Delay {
  final name = "Ping Pong";

  int get nuxIndex => 3;
  List<Parameter> parameters = [
    Parameter(
        name: "Repeat",
        handle: "repeat",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delayfeedback,
        midiCC: MidiCCValues.bCC_DelayRepeat),
    Parameter(
        name: "Mix",
        handle: "mix",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.delaymix,
        midiCC: MidiCCValues.bCC_DelayLevel),
    Parameter(
        name: "Time",
        handle: "time",
        value: 50,
        valueType: ValueType.tempo,
        devicePresetIndex: PresetDataIndex.delaytime,
        midiCC: MidiCCValues.bCC_DelayTime),
  ];
}
