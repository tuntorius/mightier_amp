// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/devices/value_formatters/ValueFormatter.dart';

import '../utilities/MathEx.dart';

class Parameter {
  ValueFormatter formatter;
  String name;
  String handle;
  int midiCC;
  int devicePresetIndex;
  double value;
  bool masterVolume = false;

  Parameter(
      {required this.value,
      required this.handle,
      required this.formatter,
      required this.name,
      required this.midiCC,
      required this.devicePresetIndex,
      this.masterVolume = false});

  int get midiValue => formatter.valueToMidi7Bit(value);
  int get masterVolMidiValue =>
      formatter.valueToMidi7Bit(value * NuxDeviceControl().masterVolume * 0.01);
  set midiValue(mv) => value = formatter.midi7BitToValue(mv);
  String get label => formatter.toLabel(value);

  double toHumanInput() {
    return formatter.toHumanInput(value);
  }

  double fromHumanInput(double val) {
    value = formatter.fromHumanInput(val);
    return value;
  }
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

  //at least for Mighty Plug MP-2, the NuxPayload values are 0-100, not 0,127
  void setupFromNuxPayload(List<int> nuxData) {
    for (int i = 0; i < parameters.length; i++) {
      parameters[i].value = MathEx.map(
          nuxData[parameters[i].devicePresetIndex].toDouble(),
          0,
          100,
          parameters[i].formatter.min.toDouble(),
          parameters[i].formatter.max.toDouble());
    }
  }

  List<int> getNuxPayload() {
    List<int> list = [];
    list.add(nuxIndex);
    for (int i = 0; i < parameters.length; i++) {
      MathEx.map(parameters[i].value, parameters[i].formatter.min.toDouble(),
          parameters[i].formatter.max.toDouble(), 0, 100);
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

abstract class Cabinet extends Processor {
  String get cabName;
}
