// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:core';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

//cabinets are 3 categories - electric, acoustic and bass
abstract class CabinetMP2 extends Cabinet {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexPlugAir.cabtype;
  @override
  int? get nuxEnableIndex => PresetDataIndexPlugAir.cabenable;
  @override
  EffectEditorUI get editorUI => EffectEditorUI.Sliders;
  @override
  int get midiCCEnableValue => MidiCCValues.bCC_CabEnable;
  @override
  int get midiCCSelectionValue => MidiCCValues.bCC_CabMode;

  //MIDI foot controller stuff
  @override
  MidiControllerHandle? get midiControlOff => null;
  @override
  MidiControllerHandle? get midiControlOn => null;
  @override
  MidiControllerHandle? get midiControlToggle => null;
  @override
  MidiControllerHandle? get midiControlPrev => MidiControllerHandles.cabPrev;
  @override
  MidiControllerHandle? get midiControlNext => MidiControllerHandles.cabNext;

  @override
  String get cabName;
  @override
  String get name {
    var name = SharedPrefs().getCustomCabinetName(
        NuxDeviceControl.instance().device.productStringId, nuxIndex);
    return name ?? cabName;
  }

  Parameter value = Parameter(
      devicePresetIndex: PresetDataIndexPlugAir.cabgain,
      name: "Level",
      handle: "level",
      value: 0,
      formatter: ValueFormatters.decibelMP2,
      midiCC: MidiCCValues.bCC_Routing,
      midiControllerHandle: MidiControllerHandles.cabLevel);

  @override
  List<Parameter> get parameters => [value];
}

class V1960 extends CabinetMP2 {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Electric IR";
  @override
  final cabName = "Marshall 1960A";
  static int get cabIndex => 0;
  @override
  int get nuxIndex => cabIndex;
}

class A212 extends CabinetMP2 {
  @override
  final cabName = "VOX AC30 2x12"; //Sunn A212???
  static int get cabIndex => 1;
  @override
  int get nuxIndex => cabIndex;
}

class BS410 extends CabinetMP2 {
  @override
  final cabName = "Fender Bassman 4x10";
  static int get cabIndex => 2;
  @override
  int get nuxIndex => cabIndex;
}

class DR112 extends CabinetMP2 {
  @override
  final cabName = "Fender Deluxe Reverb";
  static int get cabIndex => 3;
  @override
  int get nuxIndex => cabIndex;
}

class GB412 extends CabinetMP2 {
  @override
  final cabName = "Genz Benz GB412";
  static int get cabIndex => 4;
  @override
  int get nuxIndex => cabIndex;
}

class JZ120IR extends CabinetMP2 {
  @override
  final cabName = "Roland JC-120";
  static int get cabIndex => 5;
  @override
  int get nuxIndex => cabIndex;
}

class TR212 extends CabinetMP2 {
  @override
  final cabName = "Fender Twin Reverb";
  @override
  int get nuxIndex => cabIndex;
  static int get cabIndex => 6;
}

class V412 extends CabinetMP2 {
  @override
  final cabName = "Victory Amps V412";
  static int get cabIndex => 7;
  @override
  int get nuxIndex => cabIndex;
}

class AGLDB810 extends CabinetMP2 {
  @override
  bool get isSeparator => true;

  @override
  String get category => "Bass IR";
  @override
  final cabName = "Aguilar DB 810";
  static int get cabIndex => 8;
  @override
  int get nuxIndex => cabIndex;
}

class AMPSV810 extends CabinetMP2 {
  @override
  final cabName = "Ampeg SVT 8x10";
  static int get cabIndex => 9;
  @override
  int get nuxIndex => cabIndex;
}

class MKB410 extends CabinetMP2 {
  @override
  final cabName = "Marbass 4x10";
  static int get cabIndex => 10;
  @override
  int get nuxIndex => cabIndex;
}

class TRC410 extends CabinetMP2 {
  @override
  final cabName = "Trace Elliot 4x10";
  static int get cabIndex => 11;
  @override
  int get nuxIndex => cabIndex;
}

class GHBird extends CabinetMP2 {
  @override
  bool get isSeparator => true;

  @override
  String get category => "Acoustic IR";
  @override
  final cabName = "Gibson Hummingbird";
  static int get cabIndex => 12;
  @override
  int get nuxIndex => cabIndex;
}

class GJ15 extends CabinetMP2 {
  @override
  final cabName = "Gibson J-15";
  static int get cabIndex => 13;
  @override
  int get nuxIndex => cabIndex;
}

class MD45 extends CabinetMP2 {
  @override
  final cabName = "Martin D-45";
  static int get cabIndex => 14;
  @override
  int get nuxIndex => cabIndex;
}

class GIBJ200 extends CabinetMP2 {
  @override
  final cabName = "Gibson J-200";
  static int get cabIndex => 15;
  @override
  int get nuxIndex => cabIndex;
}

class GIBJ45 extends CabinetMP2 {
  @override
  final cabName = "Gibson J-45";
  static int get cabIndex => 16;
  @override
  int get nuxIndex => cabIndex;
}

class TL314 extends CabinetMP2 {
  @override
  final cabName = "Taylor 314";
  static int get cabIndex => 17;
  @override
  int get nuxIndex => cabIndex;
}

class MHD28 extends CabinetMP2 {
  @override
  final cabName = "Martin HD-28";
  static int get cabIndex => 18;
  @override
  int get nuxIndex => cabIndex;
}
