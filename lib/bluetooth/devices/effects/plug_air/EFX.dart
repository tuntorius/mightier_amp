// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugAir.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/plug_air/EFXv2.dart';

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class EFX extends Processor {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugAir.efxtype;
  @override
  int? get nuxEnableIndex => PresetDataIndexPlugAir.efxenable;
  //row 1871
  // 0 -Touch Wah, 1 - Uni Vibe, 2 - Tremolo, 3 - Phaser, 4 - Boost, 5 - TS Drive, 6 - Bass TS
  // 7 - 3 Band EQ, 8 - Muff, 9 - Crunch, 10 - Red Dist, 11 - Morning Drive, 12 - Dist One
  // The bass TS (6) is only available in bass preset mode, the rest are everywhere
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValues.bCC_DistEnable;

  @override
  int get midiCCSelectionValue => MidiCCValues.bCC_DistMode;
}

class TouchWah extends EFX {
  @override
  final name = "Touch Wah";

  @override
  int get nuxIndex => 0;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Type",
        handle: "type",
        value: 81,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Wow",
        handle: "wow",
        value: 60,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Sense",
        handle: "sense",
        value: 27,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class UniVibe extends EFX {
  @override
  final name = "Uni Vibe";

  @override
  int get nuxIndex => 1;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 73,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 83,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Mode",
        handle: "mode",
        value: 0,
        formatter: ValueFormatters.vibeMode,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class TremoloEFX extends EFX {
  @override
  final name = "Tremolo";

  @override
  int get nuxIndex => 2;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 58,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 73,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
  ];
}

class PhaserEFX extends EFX {
  @override
  final name = "Phaser";

  @override
  int get nuxIndex => 3;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "rate",
        value: 78,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Depth",
        handle: "depth",
        value: 54,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Feedback",
        handle: "feedback",
        value: 65,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class Boost extends EFX {
  @override
  final name = "Boost";

  @override
  int get nuxIndex => 4;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 41,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Level",
        handle: "level",
        value: 78,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
  ];

  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir21.index) return Katana().nuxIndex;
    return nuxIndex;
  }
}

class TSDrive extends EFX {
  @override
  final name = "T Screamer";

  @override
  int get nuxIndex => 5;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 41,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 67,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class BassTS extends EFX {
  @override
  final name = "Bass TS";

  @override
  int get nuxIndex => 6;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 41,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 67,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];

  @override
  int? getEquivalentEffect(int version) {
    if (version == PlugAirVersion.PlugAir21.index) return null;
    return nuxIndex;
  }
}

class ThreeBandEQ extends EFX {
  @override
  final name = "3 Band EQ";

  @override
  int get nuxIndex => 7;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Bass",
        handle: "bass",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Middle",
        handle: "mid",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Treble",
        handle: "treble",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class Muff extends EFX {
  @override
  final name = "Muff Fuzz";

  @override
  int get nuxIndex => 8;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Sustain",
        handle: "sustain",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class Crunch extends EFX {
  @override
  final name = "Crunch";

  @override
  int get nuxIndex => 9;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 20,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 80,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Gain",
        handle: "gain",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class RedDist extends EFX {
  @override
  final name = "Red Dist";

  @override
  int get nuxIndex => 10;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 45,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 85,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class MorningDrive extends EFX {
  @override
  final name = "Morning Drive";

  @override
  int get nuxIndex => 11;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}

class DistOne extends EFX {
  @override
  final name = "Dist One";

  @override
  int get nuxIndex => 12;
  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Level",
        handle: "level",
        value: 50,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar1,
        midiCC: MidiCCValues.bCC_DistGain),
    Parameter(
        name: "Tone",
        handle: "tone",
        value: 40,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar2,
        midiCC: MidiCCValues.bCC_DistTone),
    Parameter(
        name: "Drive",
        handle: "drive",
        value: 55,
        formatter: ValueFormatters.percentage,
        devicePresetIndex: PresetDataIndexPlugAir.efxvar3,
        midiCC: MidiCCValues.bCC_DistLevel),
  ];
}
