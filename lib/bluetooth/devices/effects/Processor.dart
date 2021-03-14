// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';

import '../NuxConstants.dart';

enum ValueType { percentage, db, tempo, vibeMode }

class Parameter {
  static const delayTimeMstable = [
    .07972789115646259,
    .16124716553287982,
    .5031292517006802,
    .7398412698412699,
    1.1972789115646258
  ];

  static double percentageToTime(double p) {
    double t = p / 25;
    int lo = t.floor();
    int hi = t.ceil();
    var hiF = t - lo;
    var loF = 1 - hiF;
    return (delayTimeMstable[lo] * loF + delayTimeMstable[hi] * hiF);
  }

  static double percentageToBPM(double p) {
    return 60 / percentageToTime(p);
  }

  static double timeToPercentage(t) {
    return (t < delayTimeMstable[0]
        ? 0
        : t < delayTimeMstable[1]
            ? 25 *
                (t - delayTimeMstable[0]) /
                (delayTimeMstable[1] - delayTimeMstable[0])
            : t < delayTimeMstable[2]
                ? 25 *
                        (t - delayTimeMstable[1]) /
                        (delayTimeMstable[2] - delayTimeMstable[1]) +
                    25
                : t < delayTimeMstable[3]
                    ? 25 *
                            (t - delayTimeMstable[2]) /
                            (delayTimeMstable[3] - delayTimeMstable[2]) +
                        50
                    : t < delayTimeMstable[4]
                        ? 25 *
                                (t - delayTimeMstable[3]) /
                                (delayTimeMstable[4] - delayTimeMstable[3]) +
                            75
                        : 100);
  }

  Processor parent;
  ValueType valueType;
  String name;
  String handle;
  int midiCC;
  int devicePresetIndex;
  double value;

  Parameter(
      {this.value,
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
  String name;

  List<Parameter> parameters;

  int nuxIndex;

  int deviceSwitchIndex;

  int deviceSelectionIndex;

  bool isSeparator;

  String category;

  void setupFromNuxPayload(List<int> nuxData) {
    for (int i = 0; i < parameters.length; i++) {
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
