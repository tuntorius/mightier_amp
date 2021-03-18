// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import '../../NuxConstants.dart';
import '../Processor.dart';

abstract class EFX extends Processor {
  //row 1871
  // 0 -Touch Wah, 1 - Uni Vibe, 2 - Tremolo, 3 - Phaser, 4 - Boost, 5 - TS Drive, 6 - Bass TS
  // 7 - 3 Band EQ, 8 - Muff, 9 - Crunch, 10 - Red Dist, 11 - Morning Drive, 12 - Dist One
  // The bass TS (6) is only available in bass preset mode, the rest are everywhere

  int get midiCCEnableValue => MidiCCValues.bCC_DistEnable;

  int get midiCCSelectionValue => MidiCCValues.bCC_DistMode;
}

class TouchWah extends EFX {
  final name = "Touch Wah";

  int get nuxIndex => 0;
  List<Parameter> parameters = [
    Parameter(
        name: "Type",
        handle: "type",
        value: 81,
        valueType:
            ValueType.percentage, //TODO: make it a 4 position switch or sth
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Wow",
        handle: "wow",
        value: 60,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Sense",
        handle: "sense",
        value: 27,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class UniVibe extends EFX {
  final name = "Uni Vibe";

  int get nuxIndex => 1;
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 73,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 83,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Mode",
        handle: "mode",
        value: 0,
        valueType: ValueType.vibeMode,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class TremoloEFX extends EFX {
  final name = "Tremolo";

  int get nuxIndex => 2;
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 58,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 73,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
  ];
}

class PhaserEFX extends EFX {
  final name = "Phaser";

  int get nuxIndex => 3;
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 78,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 54,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Feedback",
        handle: "feedback",
        value: 65,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class Boost extends EFX {
  final name = "Boost";

  int get nuxIndex => 4;
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 41,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 78,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
  ];
}

class TSDrive extends EFX {
  final name = "TS Drive";

  int get nuxIndex => 5;
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 41,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 67,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class BassTS extends EFX {
  final name = "Bass TS";

  int get nuxIndex => 6;
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 41,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 67,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class ThreeBandEQ extends EFX {
  final name = "3 Band EQ";

  int get nuxIndex => 7;
  List<Parameter> parameters = [
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class Muff extends EFX {
  final name = "Muff";

  int get nuxIndex => 8;
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 40,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 40,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class Crunch extends EFX {
  final name = "Crunch";

  int get nuxIndex => 9;
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 20,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 80,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class RedDist extends EFX {
  final name = "Red Dist";

  int get nuxIndex => 10;
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 45,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 85,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class MorningDrive extends EFX {
  final name = "Morning Drive";

  int get nuxIndex => 11;
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class DistOne extends EFX {
  final name = "Dist One";

  int get nuxIndex => 12;
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 40,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 55,
        valueType: ValueType.percentage,
        devicePresetIndex: PresetDataIndex.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}
