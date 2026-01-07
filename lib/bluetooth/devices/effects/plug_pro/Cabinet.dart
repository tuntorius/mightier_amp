// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:core';

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

abstract class CabinetPro extends Cabinet {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugPro.Head_iCAB;
  @override
  int? get nuxEnableIndex => nuxEffectTypeIndex;
  @override
  int get nuxEnableMask => 0x40;
  @override
  bool get nuxEnableInverted => true;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValuesPro.Head_iCAB;
  @override
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iCAB;

  //MIDI foot controller stuff
  @override
  MidiControllerHandle? get midiControlOff => MidiControllerHandles.cabOff;
  @override
  MidiControllerHandle? get midiControlOn => MidiControllerHandles.cabOn;
  @override
  MidiControllerHandle? get midiControlToggle =>
      MidiControllerHandles.cabToggle;
  @override
  MidiControllerHandle? get midiControlPrev => MidiControllerHandles.cabPrev;
  @override
  MidiControllerHandle? get midiControlNext => MidiControllerHandles.cabNext;

  @override
  String get name => cabName;

  @override
  List<Parameter> parameters = [
    Parameter(
        devicePresetIndex: PresetDataIndexPlugPro.CAB_Para4,
        name: "Level",
        handle: "level",
        value: 0,
        formatter: ValueFormatters.decibelMPPro,
        midiCC: MidiCCValuesPro.CAB_Para4,
        midiControllerHandle: MidiControllerHandles.cabLevel),
    Parameter(
        devicePresetIndex: PresetDataIndexPlugPro.CAB_Para5,
        name: "Low Cut",
        handle: "lowcut",
        value: 20,
        formatter: ValueFormatters.lowFreqFormatter,
        midiCC: MidiCCValuesPro.CAB_Para5,
        midiControllerHandle: MidiControllerHandles.cabLoCut),
    Parameter(
        devicePresetIndex: PresetDataIndexPlugPro.CAB_Para6,
        name: "High Cut",
        handle: "hicut",
        value: 100,
        formatter: ValueFormatters.highFreqFormatter,
        midiCC: MidiCCValuesPro.CAB_Para6,
        midiControllerHandle: MidiControllerHandles.cabHiCut)
  ];
}

class JZ120Pro extends CabinetPro {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Electric IR";
  @override
  final cabName = "Roland JC-120";
  static int get cabIndex => 1;
  @override
  int get nuxIndex => cabIndex;
}

class DR112Pro extends CabinetPro {
  @override
  final cabName = "Fender Deluxe Reverb";
  static int get cabIndex => 2;
  @override
  int get nuxIndex => cabIndex;
}

class TR212Pro extends CabinetPro {
  @override
  final cabName = "Fender Twin Reverb";
  static int get cabIndex => 3;
  @override
  int get nuxIndex => cabIndex;
}

class HIWIRE412 extends CabinetPro {
  @override
  final cabName = "Hiwatt SE412";
  static int get cabIndex => 4;
  @override
  int get nuxIndex => cabIndex;
}

class CALI112 extends CabinetPro {
  @override
  final cabName = "Mesa Boogie Cali Tweed 1x12";
  static int get cabIndex => 5;
  @override
  int get nuxIndex => cabIndex;
}

class A112 extends CabinetPro {
  @override
  final cabName = "Vox AC15 1x12";
  @override
  int get nuxIndex => cabIndex;
  static int get cabIndex => 6;
}

class GB412Pro extends CabinetPro {
  @override
  final cabName = "Genz Benz GB412";
  static int get cabIndex => 7;
  @override
  int get nuxIndex => cabIndex;
}

class M1960AX extends CabinetPro {
  @override
  final cabName = "Marshall 1960AX";
  static int get cabIndex => 8;
  @override
  int get nuxIndex => cabIndex;
}

class M1960AV extends CabinetPro {
  @override
  final cabName = "Marshall 1960AV";
  static int get cabIndex => 9;
  @override
  int get nuxIndex => cabIndex;
}

class M1960TV extends CabinetPro {
  @override
  final cabName = "Marshall 1960TV";
  static int get cabIndex => 10;
  @override
  int get nuxIndex => cabIndex;
}

class SLO412 extends CabinetPro {
  @override
  final cabName = "Soldano 4x12";
  static int get cabIndex => 11;
  @override
  int get nuxIndex => cabIndex;
}

class FIREMAN412 extends CabinetPro {
  @override
  final cabName = "Friedman 4x12";
  static int get cabIndex => 12;
  @override
  int get nuxIndex => cabIndex;
}

class RECT412 extends CabinetPro {
  @override
  final cabName = "Mesa Boogie Rectifier 4x12";
  static int get cabIndex => 13;
  @override
  int get nuxIndex => cabIndex;
}

class DIE412 extends CabinetPro {
  @override
  final cabName = "Diezel 4x12";
  static int get cabIndex => 14;
  @override
  int get nuxIndex => cabIndex;
}

class MATCH212 extends CabinetPro {
  @override
  final cabName = "Matchless DC-30 2x12";
  static int get cabIndex => 15;
  @override
  int get nuxIndex => cabIndex;
}

class UBER412 extends CabinetPro {
  @override
  final cabName = "Bogner Uberkab 4x12";
  static int get cabIndex => 16;
  @override
  int get nuxIndex => cabIndex;
}

class BS410 extends CabinetPro {
  @override
  final cabName = "Fender Bassman 4x10";
  static int get cabIndex => 17;
  @override
  int get nuxIndex => cabIndex;
}

class A212Pro extends CabinetPro {
  @override
  final cabName = "VOX AC30 2x12";
  static int get cabIndex => 18;
  @override
  int get nuxIndex => cabIndex;
}

class M1960AHW extends CabinetPro {
  @override
  final cabName = "Marshall 1960AHW";
  static int get cabIndex => 19;
  @override
  int get nuxIndex => cabIndex;
}

class M1936 extends CabinetPro {
  @override
  final cabName = "Marshall 1936 2x12";
  static int get cabIndex => 20;
  @override
  int get nuxIndex => cabIndex;
}

class BUDDA112 extends CabinetPro {
  @override
  final cabName = "Budda Superdrive 1x12";
  static int get cabIndex => 21;
  @override
  int get nuxIndex => cabIndex;
}

class Z212 extends CabinetPro {
  @override
  final cabName = "Dr. Z Z-Best 2x12";
  static int get cabIndex => 22;
  @override
  int get nuxIndex => cabIndex;
}

class SUPERVERB410 extends CabinetPro {
  @override
  final cabName = "Fender Super Reverb 4x10";
  static int get cabIndex => 23;
  @override
  int get nuxIndex => cabIndex;
}

class VIBROKING310 extends CabinetPro {
  @override
  final cabName = "Fender Vibro-King 3x10";
  static int get cabIndex => 24;
  @override
  int get nuxIndex => cabIndex;
}

//Bass amps
class AGLDB810 extends CabinetPro {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Bass IR";
  @override
  final cabName = "Aguilar DB 810";
  static int get cabIndex => 25;
  @override
  int get nuxIndex => cabIndex;
}

class AMPSV212 extends CabinetPro {
  @override
  final cabName = "Ampeg SVT 2x12";
  static int get cabIndex => 26;
  @override
  int get nuxIndex => cabIndex;
}

class AMPSV410 extends CabinetPro {
  @override
  final cabName = "Ampeg SVT 4x10";
  static int get cabIndex => 27;
  @override
  int get nuxIndex => cabIndex;
}

class AMPSV810 extends CabinetPro {
  @override
  final cabName = "Ampeg SVT 8x10";
  static int get cabIndex => 28;
  @override
  int get nuxIndex => cabIndex;
}

class BASSGUY410 extends CabinetPro {
  @override
  final cabName = "Fender Bassman 4x10";
  static int get cabIndex => 29;
  @override
  int get nuxIndex => cabIndex;
}

class EDEN410 extends CabinetPro {
  @override
  final cabName = "Eden D410XLT";
  static int get cabIndex => 30;
  @override
  int get nuxIndex => cabIndex;
}

class MKB410 extends CabinetPro {
  @override
  final cabName = "Marbass 4x10";
  static int get cabIndex => 31;
  @override
  int get nuxIndex => cabIndex;
}

class GHBIRDPro extends CabinetPro {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Acoustic IR";
  @override
  final cabName = "Gibson Hummingbird";
  static int get cabIndex => 32;
  @override
  int get nuxIndex => cabIndex;
}

class GJ15Pro extends CabinetPro {
  @override
  final cabName = "Gibson J15";
  static int get cabIndex => 33;
  @override
  int get nuxIndex => cabIndex;
}

class MD45Pro extends CabinetPro {
  @override
  final cabName = "Martin D45";
  static int get cabIndex => 34;
  @override
  int get nuxIndex => cabIndex;
}

class UserCab extends CabinetPro {
  String _cabinetName = "...";
  late int _nuxIndex;
  @override
  String get cabName => _cabinetName;

  @override
  int get nuxIndex => _nuxIndex;

  void setName(String name) {
    _cabinetName = name;
  }

  void setNuxIndex(int index) {
    _nuxIndex = index;
  }

  void setActive(bool active) {}
}
