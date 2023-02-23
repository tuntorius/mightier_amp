// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/devices/value_formatters/ValueFormatter.dart';

import '../NuxFXID.dart';
import '../utilities/MathEx.dart';
import '../value_formatters/SwitchFormatters.dart';
import 'MidiControllerHandles.dart';

class Parameter {
  ValueFormatter formatter;
  String name;
  String handle;
  int midiCC;
  int devicePresetIndex;
  double value;
  bool masterVolume = false;
  MidiControllerHandle? midiControllerHandle;

  Parameter(
      {required this.value,
      required this.handle,
      required this.formatter,
      required this.name,
      required this.midiCC,
      required this.devicePresetIndex,
      this.midiControllerHandle,
      this.masterVolume = false});

  int get midiValue => formatter.valueToMidi7Bit(value);
  int get masterVolMidiValue => formatter
      .valueToMidi7Bit(value * (NuxDeviceControl().masterVolume * 0.01));
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
  NuxFXID nuxFXID;
  Color color;
  IconData icon;
  ProcessorInfo(
      {required this.shortName,
      required this.longName,
      required this.keyName,
      required this.nuxFXID,
      required this.color,
      required this.icon});
}

enum EffectEditorUI { Sliders, EQ }

abstract class Processor {
  String get name;

  List<Parameter> get parameters;

  //the number which the nux device uses to refer to the effect
  int get nuxIndex;

  //index in nux data array where the effect type is set
  int? get nuxEffectTypeIndex;

  int? get nuxEnableIndex;
  int get nuxEnableMask => 0x7f;
  bool get nuxEnableInverted => false;

  EffectEditorUI get editorUI;
  //The CC command that switches the effect on/off
  int get midiCCEnableValue;

  //The CC command that selects the active effect for a certain slot
  int get midiCCSelectionValue;

  //MIDI foot controller stuff
  MidiControllerHandle? get midiControlOff;
  MidiControllerHandle? get midiControlOn;
  MidiControllerHandle? get midiControlToggle;
  MidiControllerHandle? get midiControlPrev;
  MidiControllerHandle? get midiControlNext;

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
      if (parameters[i].formatter is SwitchFormatter) {
        parameters[i].value =
            nuxData[parameters[i].devicePresetIndex].toDouble();
      } else {
        parameters[i].value = MathEx.map(
            nuxData[parameters[i].devicePresetIndex].toDouble(),
            0,
            100,
            parameters[i].formatter.min.toDouble(),
            parameters[i].formatter.max.toDouble());
      }
    }
  }

  void getNuxPayload(List<int> nuxData, bool enabled) {
    if (nuxEffectTypeIndex != null) nuxData[nuxEffectTypeIndex!] = nuxIndex;
    for (int i = 0; i < parameters.length; i++) {
      //TODO: isn't this supposed to use valueformatter valueToMidi7Bit()
      int value = MathEx.map(
              parameters[i].value,
              parameters[i].formatter.min.toDouble(),
              parameters[i].formatter.max.toDouble(),
              0,
              100)
          .round();
      nuxData[parameters[i].devicePresetIndex] = value;
    }
    if (nuxEnableIndex != null) {
      int value = (enabled != nuxEnableInverted ? 0xff : 0) & nuxEnableMask;
      nuxData[nuxEnableIndex!] |= value;
    }
  }

  //this is used for version transition
  int? getEquivalentEffect(int version) {
    return nuxIndex;
  }
}

abstract class Amplifier extends Processor {
  @override
  int get midiCCEnableValue;
  @override
  int get midiCCSelectionValue;
  int get defaultCab;
}

abstract class Cabinet extends Processor {
  String get cabName;
}
