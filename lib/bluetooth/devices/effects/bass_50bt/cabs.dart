import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

abstract class CabinetBass50BT extends Cabinet {
  @override
  int? get nuxEffectTypeIndex => PresetDataIndexBass50BT.cabtype;
  @override
  int? get nuxEnableIndex => null;
  @override
  int get nuxEnableMask => 0x7f;
  @override
  bool get nuxEnableInverted => false;
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
  String get name => cabName;

  @override
  List<Parameter> parameters = [
    Parameter(
        devicePresetIndex: PresetDataIndexBass50BT.cablevel,
        name: "Level",
        handle: "level",
        value: 0,
        formatter: ValueFormatters.decibelMP2,
        midiCC: MidiCCValues.bCC_Routing,
        midiControllerHandle: MidiControllerHandles.cabLevel),
    Parameter(
        devicePresetIndex: PresetDataIndexBass50BT.irlowcut,
        name: "Low Cut",
        handle: "lowcut",
        value: 20,
        formatter: ValueFormatters.lowFreqFormatter,
        midiCC: MidiCCValues.bCC_DelayMode,
        midiControllerHandle: MidiControllerHandles.cabLoCut),
    Parameter(
        devicePresetIndex: PresetDataIndexBass50BT.irhighcut,
        name: "High Cut",
        handle: "hicut",
        value: 100,
        formatter: ValueFormatters.highFreqFormatter,
        midiCC: MidiCCValues.bCC_DelayTime,
        midiControllerHandle: MidiControllerHandles.cabHiCut)
  ];
}

class DB81050BT extends CabinetBass50BT {
  @override
  bool get isSeparator => true;
  @override
  String get category => "Bass IR";
  @override
  final cabName = "AGL DB810";
  static int get cabIndex => 0;
  @override
  int get nuxIndex => cabIndex;
}

class SV21250BT extends CabinetBass50BT {
  @override
  final cabName = "AMP SV212";
  static int get cabIndex => 1;
  @override
  int get nuxIndex => cabIndex;
}

class SV41050BT extends CabinetBass50BT {
  @override
  final cabName = "AMP SV410+Tweeter";
  static int get cabIndex => 2;
  @override
  int get nuxIndex => cabIndex;
}

class SV81050BT extends CabinetBass50BT {
  @override
  final cabName = "AMP SV810";
  static int get cabIndex => 3;
  @override
  int get nuxIndex => cabIndex;
}

class BassguyCab50BT extends CabinetBass50BT {
  @override
  final cabName = "Bassguy 410";
  static int get cabIndex => 4;
  @override
  int get nuxIndex => cabIndex;
}

class Eden50BT extends CabinetBass50BT {
  @override
  final cabName = "Eden 410";
  static int get cabIndex => 5;
  @override
  int get nuxIndex => cabIndex;
}

class MKB50BT extends CabinetBass50BT {
  @override
  final cabName = "MKB 410";
  static int get cabIndex => 6;
  @override
  int get nuxIndex => cabIndex;
}

class TRC50BT extends CabinetBass50BT {
  @override
  final cabName = "TRC 410";
  static int get cabIndex => 7;
  @override
  int get nuxIndex => cabIndex;
}

class UserCab50BT extends CabinetBass50BT {
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
