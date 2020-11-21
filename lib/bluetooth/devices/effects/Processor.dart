import 'package:flutter/material.dart';

import '../NuxConstants.dart';

enum ValueType { percentage, db, tempo }

class Parameter {
  Processor parent;
  ValueType valueType;
  String name;
  String handle;
  int midiCC;
  int devicePresetIndex;
  double value;

  Parameter(
      { //this.index,
      this.value,
      this.handle,
      this.valueType,
      this.name,
      this.midiCC,
      this.devicePresetIndex});
}

class ProcessorInfo {
  String shortName;
  String longName;
  String keyName;
  Color color;
  IconData icon;
  ProcessorInfo(
      {this.shortName, this.longName, this.keyName, this.color, this.icon});
}

abstract class Processor {
  static List<ProcessorInfo> processorList = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        color: Colors.green,
        icon: Icons.account_tree),
    ProcessorInfo(
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        color: Colors.deepPurpleAccent,
        icon: Icons.account_tree),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        color: null,
        icon: Icons.speaker_phone),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cabinet",
        keyName: "cabinet",
        color: Colors.blue,
        icon: Icons.speaker),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        color: Colors.cyan[300],
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "Delay",
        longName: "Delay",
        keyName: "delay",
        color: Colors.blueAccent,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "Reverb",
        longName: "Reverb",
        keyName: "reverb",
        color: Colors.orange,
        icon: Icons.blur_on),
  ];

  String name;

  List<Parameter> parameters;

  int nuxIndex;

  int deviceSwitchIndex;

  int deviceSelectionIndex;

  bool isSeparator;

  String category;

  void setupFromNuxPayload(List<int> nuxData) {
    for (int i = 0; i < parameters.length; i++) {
      //TODO: See what happens with tempo, db and others
      if (parameters[i].valueType != ValueType.db)
        parameters[i].value =
            nuxData[parameters[i].devicePresetIndex].toDouble();
      else
        parameters[i].value =
            (nuxData[parameters[i].devicePresetIndex].toDouble() - 50) / 8.3334;
    }
  }
}

class NoiseGate extends Processor {
  final name = "Noise Gate";

  int get nuxIndex => 0;

  int get deviceSwitchIndex => MidiCCValues.bCC_GateEnable;

  int get deviceSelectionIndex => 0;

//row 1388: 0-
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
