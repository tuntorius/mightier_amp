// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:core';
import '../NuxConstants.dart';
import 'Processor.dart';

//cabinets are 3 categories - electric, acoustic and bass
class Cabinet extends Processor {
  int get deviceSwitchIndex => MidiCCValues.bCC_CabEnable;
  int get deviceSelectionIndex => MidiCCValues.bCC_CabMode;

  Parameter value = Parameter(
      devicePresetIndex: PresetDataIndex.cabgain,
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
  final name = "V1960";
  int get nuxIndex => 0;
}

class A212 extends Cabinet {
  final name = "A212"; //Sunn A212???
  int get nuxIndex => 1;
}

class BS410 extends Cabinet {
  final name = "BS410";
  int get nuxIndex => 2;
}

class DR112 extends Cabinet {
  final name = "DR112";
  int get nuxIndex => 3;
}

class GB412 extends Cabinet {
  final name = "GB412";
  int get nuxIndex => 4;
}

class JZ120IR extends Cabinet {
  final name = "JZ120";
  int get nuxIndex => 5;
}

class TR212 extends Cabinet {
  final name = "TR212";
  int get nuxIndex => 6;
}

class V412 extends Cabinet {
  final name = "V412";
  int get nuxIndex => 7;
}

class AGLDB810 extends Cabinet {
  @override
  bool get isSeparator => true;

  @override
  String get category => "Bass IR";
  final name = "AGL DB810";
  int get nuxIndex => 8;
}

class AMPSV810 extends Cabinet {
  final name = "AMP SV810";
  int get nuxIndex => 9;
}

class MKB410 extends Cabinet {
  final name = "MKB 410";
  int get nuxIndex => 10;
}

class TRC410 extends Cabinet {
  final name = "TRC 410";
  int get nuxIndex => 11;
}

class GHBird extends Cabinet {
  @override
  bool get isSeparator => true;

  @override
  String get category => "Acoustic IR";
  final name = "G HBird EG Magnetic";
  int get nuxIndex => 12;
}

class GJ15 extends Cabinet {
  final name = "G J15 EG Magnetic";
  int get nuxIndex => 13;
}

class MD45 extends Cabinet {
  final name = "M D45 EG Magnetic";
  int get nuxIndex => 14;
}

class GIBJ200 extends Cabinet {
  final name = "GIB J200 EG Magnetic";
  int get nuxIndex => 15;
}

class GIBJ45 extends Cabinet {
  final name = "GIB J45 EG Magnetic";
  int get nuxIndex => 16;
}

class TL314 extends Cabinet {
  final name = "TL 314 EG Magnetic";
  int get nuxIndex => 17;
}

class MHD28 extends Cabinet {
  final name = "M HD28 EG Magnetic";
  int get nuxIndex => 18;
}
