import 'package:mighty_plug_manager/bluetooth/devices/effects/plug_pro/Modulation.dart';

import '../../NuxConstants.dart';
import '../../value_formatters/ValueFormatter.dart';
import '../MidiControllerHandles.dart';
import '../Processor.dart';

class FlangerLiteMk2 extends FlangerPro {
  @override
  int get nuxIndex => 5;
}

class Phase90LiteMk2 extends Phase90 {
  @override
  int get nuxIndex => 6;
}

class Phase100LiteMk2 extends Phase100 {
  @override
  int get nuxIndex => 7;
}

class SCFLiteMk2 extends SCFPro {
  @override
  int get nuxIndex => 8;
}

class VibeLiteMk2 extends VibePro {
  @override
  int get nuxIndex => 9;

  @override
  List<Parameter> parameters = [
    Parameter(
        name: "Rate",
        handle: "speed",
        value: 50,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para1,
        midiCC: MidiCCValuesPro.MOD_Para1,
        midiControllerHandle: MidiControllerHandles.modRate),
    Parameter(
        name: "Depth",
        handle: "intensity",
        value: 80,
        formatter: ValueFormatters.percentageMPPro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para2,
        midiCC: MidiCCValuesPro.MOD_Para2,
        midiControllerHandle: MidiControllerHandles.modDepth),
    Parameter(
        name: "Mode",
        handle: "mode",
        value: 0,
        formatter: ValueFormatters.vibeModePro,
        devicePresetIndex: PresetDataIndexPlugPro.MOD_Para3,
        midiCC: MidiCCValuesPro.MOD_Para3),
  ];
}

class TremoloLiteMk2 extends TremoloPro {
  @override
  int get nuxIndex => 10;
}

class SCH1LiteMk2 extends SCH1Pro {
  @override
  int get nuxIndex => 11;
}
