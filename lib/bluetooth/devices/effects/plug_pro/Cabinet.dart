// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:core';

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../Processor.dart';

abstract class CabinetPro extends Cabinet {
  int get nuxDataLength => 3;

  int get midiCCEnableValue => MidiCCValuesPro.Head_iCAB;
  int get midiCCSelectionValue => MidiCCValuesPro.Head_iCAB;

  String get name => cabName;

  @override
  List<Parameter> parameters = [
    Parameter(
        devicePresetIndex: PresetDataIndexPlugAir.cabgain,
        name: "Level",
        handle: "level",
        value: 0,
        formatter: ValueFormatters.decibelMPPro,
        midiCC: MidiCCValuesPro.CAB_Para4),
    Parameter(
        devicePresetIndex: PresetDataIndexPlugAir.cabgain,
        name: "Low Cut",
        handle: "lowcut",
        value: 0,
        formatter: ValueFormatters.percentage,
        midiCC: MidiCCValuesPro.CAB_Para5),
    Parameter(
        devicePresetIndex: PresetDataIndexPlugAir.cabgain,
        name: "High Cut",
        handle: "hicut",
        value: 100,
        formatter: ValueFormatters.percentage,
        midiCC: MidiCCValuesPro.CAB_Para6)
  ];
}

class JZ120Pro extends CabinetPro {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Electric IR";
  final cabName = "JZ120"; //Sunn A212???
  static int get cabIndex => 1;
  int get nuxIndex => cabIndex;
}

class DR112Pro extends CabinetPro {
  final cabName = "DR112";
  static int get cabIndex => 2;
  int get nuxIndex => cabIndex;
}

class TR212Pro extends CabinetPro {
  final cabName = "TR212";
  static int get cabIndex => 3;
  int get nuxIndex => cabIndex;
}

class HIWIRE412 extends CabinetPro {
  final cabName = "HIWIRE412";
  static int get cabIndex => 4;
  int get nuxIndex => cabIndex;
}

class CALI112 extends CabinetPro {
  final cabName = "CALI 112";
  static int get cabIndex => 5;
  int get nuxIndex => cabIndex;
}

class A112 extends CabinetPro {
  final cabName = "A112";
  int get nuxIndex => cabIndex;
  static int get cabIndex => 6;
}

class GB412Pro extends CabinetPro {
  final cabName = "GB412";
  static int get cabIndex => 7;
  int get nuxIndex => cabIndex;
}

class M1960AX extends CabinetPro {
  final cabName = "M1960AX";
  static int get cabIndex => 8;
  int get nuxIndex => cabIndex;
}

class M1960AV extends CabinetPro {
  final cabName = "M1960AV";
  static int get cabIndex => 9;
  int get nuxIndex => cabIndex;
}

class M1960TV extends CabinetPro {
  final cabName = "M1960TV";
  static int get cabIndex => 10;
  int get nuxIndex => cabIndex;
}

class SLO412 extends CabinetPro {
  final cabName = "SLO412";
  static int get cabIndex => 11;
  int get nuxIndex => cabIndex;
}

class FIREMAN412 extends CabinetPro {
  final cabName = "FIREMAN 412";
  static int get cabIndex => 12;
  int get nuxIndex => cabIndex;
}

class RECT412 extends CabinetPro {
  final cabName = "RECT 412";
  static int get cabIndex => 13;
  int get nuxIndex => cabIndex;
}

class DIE412 extends CabinetPro {
  final cabName = "DIE412";
  static int get cabIndex => 14;
  int get nuxIndex => cabIndex;
}

class MATCH212 extends CabinetPro {
  final cabName = "MATCH212";
  static int get cabIndex => 15;
  int get nuxIndex => cabIndex;
}

class UBER412 extends CabinetPro {
  final cabName = "UBER412";
  static int get cabIndex => 16;
  int get nuxIndex => cabIndex;
}

class BS410 extends CabinetPro {
  final cabName = "BS410";
  static int get cabIndex => 17;
  int get nuxIndex => cabIndex;
}

class A212Pro extends CabinetPro {
  final cabName = "A212";
  static int get cabIndex => 18;
  int get nuxIndex => cabIndex;
}

class M1960AHW extends CabinetPro {
  final cabName = "M1960AHW";
  static int get cabIndex => 19;
  int get nuxIndex => cabIndex;
}

class M1936 extends CabinetPro {
  final cabName = "M1936";
  static int get cabIndex => 20;
  int get nuxIndex => cabIndex;
}

class BUDDA112 extends CabinetPro {
  final cabName = "BUDDA112";
  static int get cabIndex => 21;
  int get nuxIndex => cabIndex;
}

class Z212 extends CabinetPro {
  final cabName = "Z212";
  static int get cabIndex => 22;
  int get nuxIndex => cabIndex;
}

class SUPERVERB410 extends CabinetPro {
  final cabName = "SUPERVERB410";
  static int get cabIndex => 23;
  int get nuxIndex => cabIndex;
}

class VIBROKING310 extends CabinetPro {
  final cabName = "VIBROKING310";
  static int get cabIndex => 24;
  int get nuxIndex => cabIndex;
}

//Bass amps
class AGLDB810 extends CabinetPro {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Bass IR";
  final cabName = "AGL_DB810";
  static int get cabIndex => 25;
  int get nuxIndex => cabIndex;
}

class AMPSV212 extends CabinetPro {
  final cabName = "AMP_SV212";
  static int get cabIndex => 26;
  int get nuxIndex => cabIndex;
}

class AMPSV410 extends CabinetPro {
  final cabName = "AMP_SV410";
  static int get cabIndex => 27;
  int get nuxIndex => cabIndex;
}

class AMPSV810 extends CabinetPro {
  final cabName = "AMP_SV810";
  static int get cabIndex => 28;
  int get nuxIndex => cabIndex;
}

class BASSGUY410 extends CabinetPro {
  final cabName = "BASSGUY410";
  static int get cabIndex => 29;
  int get nuxIndex => cabIndex;
}

class EDEN410 extends CabinetPro {
  final cabName = "EDEN410";
  static int get cabIndex => 30;
  int get nuxIndex => cabIndex;
}

class MKB410 extends CabinetPro {
  final cabName = "MKB410";
  static int get cabIndex => 31;
  int get nuxIndex => cabIndex;
}

class GHBIRDPro extends CabinetPro {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Acoustic IR";
  final cabName = "G-HBIRD";
  static int get cabIndex => 32;
  int get nuxIndex => cabIndex;
}

class GJ15Pro extends CabinetPro {
  final cabName = "G-J15";
  static int get cabIndex => 33;
  int get nuxIndex => cabIndex;
}

class MD45Pro extends CabinetPro {
  final cabName = "M-D45";
  static int get cabIndex => 34;
  int get nuxIndex => cabIndex;
}
