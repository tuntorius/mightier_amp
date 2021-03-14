// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/Mighty8BTPreset.dart';

import '../NuxDeviceControl.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';
import 'presets/Preset.dart';

enum M2040BTChannel { Clean, Overdrive, Metal, Lead }

class NuxMighty2040BT extends NuxDevice {
  int get productVID => 48;

  static const _group = 0;

  String get productName => "NUX Mighty 20/40 BT";
  String get productNameShort => "Mighty 20/40 BT";
  String get productStringId => "mighty_20_40bt";
  List<String> get productBLENames =>
      ["NUX MIGHTY20BT MIDI", "NUX MIGHTY40BT MIDI"];

  int get channelsCount => 3;
  int get effectsChainLength => 5;
  int get groupsCount => 2;
  List<String> get groupsName => ["1", "2"];
  List<ProcessorInfo> get processorList => _processorList;

  final List<ProcessorInfo> _processorList = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        color: Colors.green,
        icon: Icons.account_tree),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        color: null,
        icon: Icons.speaker_phone),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        color: Colors.cyan[300],
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

  List<String> _channelNames = [];

  final List<String> drumStyles = [
    "Metronome",
    "Rock",
    "60's",
    "Bossanova",
    "Pop 1",
    "Pop 2",
    "Pop 3",
    "Blues 1",
    "Blues 2",
    "Jazz",
    "Jam",
    "R&B",
    "Latin",
    "Dance House",
    "Dance House 1",
    "Blues 3/4",
    "Ballad 3/4"
  ];

  NuxMighty2040BT(NuxDeviceControl devControl) : super(devControl) {
    //get channel names
    M2040BTChannel.values.forEach((element) {
      _channelNames.add(element.toString().split('.')[1]);
    });

    //clean
    presets.add(M8BTPreset(
        device: this,
        channel: M2040BTChannel.Clean.index,
        channelName: "Clean"));

    //OD
    presets.add(M8BTPreset(
        device: this,
        channel: M2040BTChannel.Overdrive.index,
        channelName: "Drive"));

    //Metal
    presets.add(M8BTPreset(
        device: this,
        channel: M2040BTChannel.Metal.index,
        channelName: "Metal"));

    //Lead
    presets.add(M8BTPreset(
        device: this, channel: M2040BTChannel.Lead.index, channelName: "Lead"));
  }

  List<String> getDrumStyles() => drumStyles;

  List<Preset> getGroupPresets(int instr) {
    return presets;
  }

  void setGroupFromChannel(int chan) {
    selectedGroupP = _group;
  }

  void setChannelFromGroup(int instr) {}

  @override
  int get selectedChannelNormalized {
    return selectedChannel;
  }

  @override
  set selectedChannelNormalized(int chan) {
    selectedChannelP = chan;
    super.selectedChannelNormalized = selectedChannelP;
  }

  @override
  String channelName(int channel) {
    return _channelNames[channel];
  }
}
