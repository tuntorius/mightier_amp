// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:core';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';

import '../../NuxConstants.dart';
import '../Processor.dart';

//cabinets are 3 categories - electric, acoustic and bass
abstract class Cabinet extends Processor {
  int get nuxDataLength => 1;

  int get midiCCEnableValue => MidiCCValues.bCC_CabEnable;
  int get midiCCSelectionValue => MidiCCValues.bCC_CabMode;

  String get cabName;
  String get name {
    var _name = SharedPrefs().getCustomCabinetName(
        NuxDeviceControl().device.productStringId, nuxIndex);
    return _name ?? cabName;
  }

  Parameter value = Parameter(
      devicePresetIndex: PresetDataIndexPlugAir.cabgain,
      name: "Level",
      handle: "level",
      value: 0,
      valueType: ValueType.db,
      midiCC: MidiCCValues.bCC_Routing);

  List<Parameter> get parameters => [value];
}

class V1960 extends Cabinet {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Electric IR";
  final cabName = "V1960";
  static int get cabIndex => 0;
  int get nuxIndex => cabIndex;
}

class A212 extends Cabinet {
  final cabName = "A212"; //Sunn A212???
  static int get cabIndex => 1;
  int get nuxIndex => cabIndex;
}

class BS410 extends Cabinet {
  final cabName = "BS410";
  static int get cabIndex => 2;
  int get nuxIndex => cabIndex;
}

class DR112 extends Cabinet {
  final cabName = "DR112";
  static int get cabIndex => 3;
  int get nuxIndex => cabIndex;
}

class GB412 extends Cabinet {
  final cabName = "GB412";
  static int get cabIndex => 4;
  int get nuxIndex => cabIndex;
}

class JZ120IR extends Cabinet {
  final cabName = "JZ120";
  static int get cabIndex => 5;
  int get nuxIndex => cabIndex;
}

class TR212 extends Cabinet {
  final cabName = "TR212";
  int get nuxIndex => cabIndex;
  static int get cabIndex => 6;
}

class V412 extends Cabinet {
  final cabName = "V412";
  static int get cabIndex => 7;
  int get nuxIndex => cabIndex;
}

class AGLDB810 extends Cabinet {
  @override
  bool get isSeparator => true;

  @override
  String get category => "Bass IR";
  final cabName = "AGL DB810";
  static int get cabIndex => 8;
  int get nuxIndex => cabIndex;
}

class AMPSV810 extends Cabinet {
  final cabName = "AMP SV810";
  static int get cabIndex => 9;
  int get nuxIndex => cabIndex;
}

class MKB410 extends Cabinet {
  final cabName = "MKB 410";
  static int get cabIndex => 10;
  int get nuxIndex => cabIndex;
}

class TRC410 extends Cabinet {
  final cabName = "TRC 410";
  static int get cabIndex => 11;
  int get nuxIndex => cabIndex;
}

class GHBird extends Cabinet {
  @override
  bool get isSeparator => true;

  @override
  String get category => "Acoustic IR";
  final cabName = "G HBird EG Magnetic";
  static int get cabIndex => 12;
  int get nuxIndex => cabIndex;
}

class GJ15 extends Cabinet {
  final cabName = "G J15 EG Magnetic";
  static int get cabIndex => 13;
  int get nuxIndex => cabIndex;
}

class MD45 extends Cabinet {
  final cabName = "M D45 EG Magnetic";
  static int get cabIndex => 14;
  int get nuxIndex => cabIndex;
}

class GIBJ200 extends Cabinet {
  final cabName = "GIB J200 EG Magnetic";
  static int get cabIndex => 15;
  int get nuxIndex => cabIndex;
}

class GIBJ45 extends Cabinet {
  final cabName = "GIB J45 EG Magnetic";
  static int get cabIndex => 16;
  int get nuxIndex => cabIndex;
}

class TL314 extends Cabinet {
  final cabName = "TL 314 EG Magnetic";
  static int get cabIndex => 17;
  int get nuxIndex => cabIndex;
}

class MHD28 extends Cabinet {
  final cabName = "M HD28 EG Magnetic";
  static int get cabIndex => 18;
  int get nuxIndex => cabIndex;
}
