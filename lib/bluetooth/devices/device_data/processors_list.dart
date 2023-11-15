import 'package:flutter/material.dart';

import '../../../UI/mightierIcons.dart';
import '../NuxFXID.dart';
import '../effects/Processor.dart';

class ProcessorsList {
  static const List<ProcessorInfo> plugAirList = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        nuxFXID: PlugAirFXID.gate,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        nuxFXID: PlugAirFXID.efx,
        color: Color(0xFFB388FF), //deepPurpleAccent[100]
        icon: MightierIcons.pedal),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        nuxFXID: PlugAirFXID.amp,
        color: Colors.green,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cabinet",
        keyName: "cabinet",
        nuxFXID: PlugAirFXID.cab,
        color: Colors.blue,
        icon: MightierIcons.cabinet),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        nuxFXID: PlugAirFXID.mod,
        color: Color(0xFF4DD0E1), //cyan[300]
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "Delay",
        longName: "Delay",
        keyName: "delay",
        nuxFXID: PlugAirFXID.delay,
        color: Colors.blueAccent,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "Reverb",
        longName: "Reverb",
        keyName: "reverb",
        nuxFXID: PlugAirFXID.reverb,
        color: Colors.orange,
        icon: Icons.blur_on),
  ];

  static const List<ProcessorInfo> plugProList = [
    ProcessorInfo(
        shortName: "COMP",
        longName: "Comp",
        keyName: "comp",
        nuxFXID: PlugProFXID.comp,
        color: Colors.lime,
        icon: MightierIcons.compressor),
    ProcessorInfo(
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        nuxFXID: PlugProFXID.efx,
        color: Colors.orange,
        icon: MightierIcons.pedal),
    ProcessorInfo(
        shortName: "AMP",
        longName: "Amplifier",
        keyName: "amp",
        nuxFXID: PlugProFXID.amp,
        color: Colors.red,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "EQ",
        longName: "EQ",
        keyName: "eq",
        nuxFXID: PlugProFXID.eq,
        color: Color(0xFFE0E0E0), //grey[300]
        icon: MightierIcons.sliders),
    ProcessorInfo(
        shortName: "GATE",
        longName: "Noise Gate",
        keyName: "gate",
        nuxFXID: PlugProFXID.gate,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "MOD",
        longName: "Modulation",
        keyName: "mod",
        nuxFXID: PlugProFXID.mod,
        color: Color(0xFF7E57C2), //deepPurple[400]
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "DLY",
        longName: "Delay",
        keyName: "delay",
        nuxFXID: PlugProFXID.delay,
        color: Color(0xFF4DD0E1), //cyan[300]
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "RVB",
        longName: "Reverb",
        keyName: "reverb",
        nuxFXID: PlugProFXID.reverb,
        color: Color(0xFFCE93D8), //purple[200]
        icon: Icons.blur_on),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cab",
        keyName: "cabinet",
        nuxFXID: PlugProFXID.cab,
        color: Color(0xFF29B6F6), //lightBlue[400]
        icon: MightierIcons.cabinet),
  ];

  static const List<ProcessorInfo> liteMk2List = [
    ProcessorInfo(
        shortName: "GATE",
        longName: "Noise Gate",
        keyName: "gate",
        nuxFXID: LiteMK2FXID.gate,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        nuxFXID: LiteMK2FXID.efx,
        color: Colors.orange,
        icon: MightierIcons.pedal),
    ProcessorInfo(
        shortName: "AMP",
        longName: "Amplifier",
        keyName: "amp",
        nuxFXID: LiteMK2FXID.amp,
        color: Colors.red,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cab",
        keyName: "cabinet",
        nuxFXID: LiteMK2FXID.cab,
        color: Color(0xFF29B6F6), //lightBlue[400]
        icon: MightierIcons.cabinet),
    ProcessorInfo(
        shortName: "MOD",
        longName: "Modulation",
        keyName: "mod",
        nuxFXID: LiteMK2FXID.mod,
        color: Color(0xFF7E57C2), //Colors.deepPurple[400]!,
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "DLY",
        longName: "Delay",
        keyName: "delay",
        nuxFXID: LiteMK2FXID.delay,
        color: Color(0xFF4DD0E1), //Colors.cyan[300]!,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "RVB",
        longName: "Reverb",
        keyName: "reverb",
        nuxFXID: LiteMK2FXID.reverb,
        color: Color(0xFFCE93D8), //Colors.purple[200]!,
        icon: Icons.blur_on),
  ];

  static const List<ProcessorInfo> liteList = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        nuxFXID: LiteFXID.gate,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        nuxFXID: LiteFXID.amp,
        color: Colors.green,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        nuxFXID: LiteFXID.mod,
        color: Color(0xFF4DD0E1), //cyan[300]
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "Ambience",
        longName: "Ambience",
        keyName: "ambience",
        nuxFXID: LiteFXID.ambience,
        color: Colors.orange,
        icon: Icons.blur_on),
  ];

  static const List<ProcessorInfo> bt2040List = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        nuxFXID: PlugBTFXID.gate,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        nuxFXID: PlugBTFXID.amp,
        color: Colors.green,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        nuxFXID: PlugBTFXID.mod,
        color: Color(0xFF4DD0E1), //cyan[300]
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "Delay",
        longName: "Delay",
        keyName: "delay",
        nuxFXID: PlugBTFXID.delay,
        color: Colors.blueAccent,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "Reverb",
        longName: "Reverb",
        keyName: "reverb",
        nuxFXID: PlugBTFXID.reverb,
        color: Colors.orange,
        icon: Icons.blur_on),
  ];

  static const List<ProcessorInfo> mighty8BTList = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        nuxFXID: PlugBTFXID.gate,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        nuxFXID: PlugBTFXID.amp,
        color: Colors.green,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        nuxFXID: PlugBTFXID.mod,
        color: Color(0xFF4DD0E1), //cyan[300]
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "Delay",
        longName: "Delay",
        keyName: "delay",
        nuxFXID: PlugBTFXID.delay,
        color: Colors.blueAccent,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "Reverb",
        longName: "Reverb",
        keyName: "reverb",
        nuxFXID: PlugBTFXID.reverb,
        color: Colors.orange,
        icon: Icons.blur_on),
  ];

  static const List<ProcessorInfo> bassList = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        nuxFXID: PlugAirFXID.gate,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        nuxFXID: PlugAirFXID.efx,
        color: Color(0xFFB388FF), //deepPurpleAccent[100]
        icon: MightierIcons.pedal),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        nuxFXID: PlugAirFXID.amp,
        color: Colors.green,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cabinet",
        keyName: "cabinet",
        nuxFXID: PlugAirFXID.cab,
        color: Colors.blue,
        icon: MightierIcons.cabinet),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        nuxFXID: PlugAirFXID.mod,
        color: Color(0xFF4DD0E1), //cyan[300]
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "Reverb",
        longName: "Reverb",
        keyName: "reverb",
        nuxFXID: PlugAirFXID.reverb,
        color: Colors.orange,
        icon: Icons.blur_on),
  ];
}
