// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';

enum ValueType {
  percentage,
  db,
  tempo,
  vibeMode,
  boostMode,
  brightMode,
  contourMode
}

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

  static double bpmToPercentage(double b) {
    return timeToPercentage(60 / b);
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

  ValueType valueType;
  String name;
  String handle;
  int midiCC;
  int devicePresetIndex;
  double value;
  bool masterVolume = false;

  Parameter(
      {required this.value,
      required this.handle,
      required this.valueType,
      required this.name,
      required this.midiCC,
      required this.devicePresetIndex,
      this.masterVolume = false});
}

class ProcessorInfo {
  String shortName;
  String longName;
  String keyName;
  Color color;
  IconData icon;
  ProcessorInfo(
      {required this.shortName,
      required this.longName,
      required this.keyName,
      required this.color,
      required this.icon});
}

abstract class Processor {
  String name = "";

  List<Parameter> parameters = <Parameter>[];

  //the number which the nux device uses to refer to the effect
  int get nuxIndex;

  int get nuxDataLength;

  //The CC command that switches the effect on/off
  int midiCCEnableValue = 0;

  //The CC command that selects the active effect for a certain slot
  int midiCCSelectionValue = 0;

  //used to declare that the device is a separator
  //Used in the selection popup menu
  bool isSeparator = false;

  //Used to sort various effects in a category
  //for example acoustic amps/electric amps
  //used in conjunction with isSeparator
  String category = "";

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

  List<int> getNuxPayload() {
    List<int> list = [];
    list.add(nuxIndex);
    for (int i = 0; i < parameters.length; i++) {
      if (parameters[i].valueType != ValueType.db)
        list.add(parameters[i].value.round());
      else
        list.add(((parameters[i].value + 6) * 8.3333).round());
    }
    var padding = nuxDataLength - parameters.length;
    for (int i = 0; i < padding; i++) list.add(0);

    return list;
  }

  //this is used for version transition
  int? getEquivalentEffect(int version) {
    return nuxIndex;
  }
}

abstract class Amplifier extends Processor {
  int get midiCCEnableValue;
  int get midiCCSelectionValue;
  int get defaultCab;
}
