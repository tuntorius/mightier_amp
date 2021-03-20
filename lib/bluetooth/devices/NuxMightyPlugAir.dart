// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../UI/mightierIcons.dart';

import '../NuxDeviceControl.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';
import 'presets/PlugAirPreset.dart';
import 'presets/Preset.dart';

enum PlugAirChannel { Clean, Overdrive, Distortion, AGSim, Pop, Rock, Funk }

class NuxMightyPlug extends NuxDevice {
  static const defaultNuxId = "mighty_plug_air";
  int get productVID => 48;

  static const _guitarGroup = 0;
  static const _bassGroup = 1;

  String get productName => "NUX Mighty Plug/Air";
  String get productNameShort => "Mighty Plug/Air";
  String get productStringId => "mighty_plug_air";
  IconData get productIcon => MightierIcons.amp_plugair;
  List<String> get productBLENames =>
      ["NUX MIGHTY PLUG MIDI", "NUX MIGHTY AIR MIDI"];

  int get channelsCount => 7;
  int get effectsChainLength => 7;
  int get groupsCount => 2;
  int get amplifierSlotIndex => 2;
  bool get cabinetSupport => true;
  int get cabinetSlotIndex => 3;
  bool get presetSaveSupport => true;

  List<String> get groupsName => ["Guitar", "Bass"];
  List<ProcessorInfo> get processorList => _processorList;

  final List<ProcessorInfo> _processorList = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        color: Colors.deepPurpleAccent,
        icon: MightierIcons.pedal),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        color: Colors.green,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cabinet",
        keyName: "cabinet",
        color: Colors.blue,
        icon: MightierIcons.cabinet),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        color: Colors.cyan[300]!,
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "Delay",
        longName: "Delay",
        keyName: "delay",
        color: Colors.blueAccent,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "Reverb",
        longName: "Reverb",
        keyName: "reverb",
        color: Colors.orange,
        icon: Icons.blur_on),
  ];

  List<Preset> guitarPresets = <Preset>[];
  List<Preset> bassPresets = <Preset>[];

  List<String> channelNames = [];

  final List<String> drumStyles = [
    "Metronome",
    "Pop",
    "Metal",
    "Blues",
    "Swing",
    "Rock",
    "Ballad Rock",
    "Funk",
    "R&B",
    "Latin",
    "Dance"
  ];

  NuxMightyPlug(NuxDeviceControl devControl) : super(devControl) {
    //get channel names
    PlugAirChannel.values.forEach((element) {
      channelNames.add(element.toString().split('.')[1]);
    });

    //clean
    guitarPresets.add(PlugAirPreset(
        device: this,
        channel: PlugAirChannel.Clean.index,
        channelName: "Clean"));

    //OD
    guitarPresets.add(PlugAirPreset(
        device: this,
        channel: PlugAirChannel.Overdrive.index,
        channelName: "Drive"));

    //Dist
    guitarPresets.add(PlugAirPreset(
        device: this,
        channel: PlugAirChannel.Distortion.index,
        channelName: "Dist"));

    //AGSim
    guitarPresets.add(PlugAirPreset(
        device: this,
        channel: PlugAirChannel.AGSim.index,
        channelName: "AGSim"));

    //Pop Bass
    bassPresets.add(PlugAirPreset(
        device: this, channel: PlugAirChannel.Pop.index, channelName: "Pop"));

    //Rock Bass
    bassPresets.add(PlugAirPreset(
        device: this, channel: PlugAirChannel.Rock.index, channelName: "Rock"));

    //Funk Bass
    bassPresets.add(PlugAirPreset(
        device: this, channel: PlugAirChannel.Funk.index, channelName: "Funk"));

    presets.addAll(guitarPresets);
    presets.addAll(bassPresets);
  }

  List<String> getDrumStyles() => drumStyles;

  List<Preset> getGroupPresets(int instr) {
    switch (instr) {
      case _guitarGroup:
        return guitarPresets;
      case _bassGroup:
        return bassPresets;
    }
    return <Preset>[];
  }

  void setGroupFromChannel(int chan) {
    if (chan < 4)
      selectedGroupP = _guitarGroup;
    else
      selectedGroupP = _bassGroup;
  }

  void setChannelFromGroup(int instr) {
    if (instr == _guitarGroup)
      selectedChannelP = 0;
    else {
      selectedChannelP = 4;
    }
  }

  @override
  int get selectedChannelNormalized {
    if (selectedGroup == _guitarGroup) return selectedChannel;
    return selectedChannel - 4;
  }

  @override
  set selectedChannelNormalized(int chan) {
    if (selectedGroupP == _guitarGroup) {
      selectedChannelP = chan;
    } else
      selectedChannelP = chan + 4;

    super.selectedChannelNormalized = selectedChannelP;
  }

  @override
  String channelName(int channel) {
    return channelNames[channel];
  }
}
