// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:core';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';

import '../../NuxConstants.dart';
import '../Processor.dart';
import '../plug_air/Cabinet.dart';

class V1960Pro extends Cabinet {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Electric IR";
  final cabName = "V1960";
  static int get cabIndex => 0;
  int get nuxIndex => cabIndex;
}

class A212Pro extends Cabinet {
  final cabName = "A212"; //Sunn A212???
  static int get cabIndex => 1;
  int get nuxIndex => cabIndex;
}

class BS410Pro extends Cabinet {
  final cabName = "BS410";
  static int get cabIndex => 2;
  int get nuxIndex => cabIndex;
}

class DR112Pro extends Cabinet {
  final cabName = "DR112";
  static int get cabIndex => 3;
  int get nuxIndex => cabIndex;
}

class GB412Pro extends Cabinet {
  final cabName = "GB412";
  static int get cabIndex => 4;
  int get nuxIndex => cabIndex;
}

class JZ120IRPro extends Cabinet {
  final cabName = "JZ120";
  static int get cabIndex => 5;
  int get nuxIndex => cabIndex;
}

class TR212Pro extends Cabinet {
  final cabName = "TR212";
  int get nuxIndex => cabIndex;
  static int get cabIndex => 6;
}

class V412Pro extends Cabinet {
  final cabName = "V412";
  static int get cabIndex => 7;
  int get nuxIndex => cabIndex;
}

class AGLDB810Pro extends Cabinet {
  @override
  bool get isSeparator => true;

  @override
  String get category => "Bass IR";
  final cabName = "AGL DB810";
  static int get cabIndex => 8;
  int get nuxIndex => cabIndex;
}

class AMPSV810Pro extends Cabinet {
  final cabName = "AMP SV810";
  static int get cabIndex => 9;
  int get nuxIndex => cabIndex;
}

class MKB410Pro extends Cabinet {
  final cabName = "MKB 410";
  static int get cabIndex => 10;
  int get nuxIndex => cabIndex;
}

class TRC410Pro extends Cabinet {
  final cabName = "TRC 410";
  static int get cabIndex => 11;
  int get nuxIndex => cabIndex;
}

class GHBirdPro extends Cabinet {
  @override
  bool get isSeparator => true;

  @override
  String get category => "Acoustic IR";
  final cabName = "G HBird EG Magnetic";
  static int get cabIndex => 12;
  int get nuxIndex => cabIndex;
}

class GJ15Pro extends Cabinet {
  final cabName = "G J15 EG Magnetic";
  static int get cabIndex => 13;
  int get nuxIndex => cabIndex;
}

class MD45Pro extends Cabinet {
  final cabName = "M D45 EG Magnetic";
  static int get cabIndex => 14;
  int get nuxIndex => cabIndex;
}

class GIBJ200Pro extends Cabinet {
  final cabName = "GIB J200 EG Magnetic";
  static int get cabIndex => 15;
  int get nuxIndex => cabIndex;
}

class GIBJ45Pro extends Cabinet {
  final cabName = "GIB J45 EG Magnetic";
  static int get cabIndex => 16;
  int get nuxIndex => cabIndex;
}

class TL314Pro extends Cabinet {
  final cabName = "TL 314 EG Magnetic";
  static int get cabIndex => 17;
  int get nuxIndex => cabIndex;
}

class MHD28Pro extends Cabinet {
  final cabName = "M HD28 EG Magnetic";
  static int get cabIndex => 18;
  int get nuxIndex => cabIndex;
}
