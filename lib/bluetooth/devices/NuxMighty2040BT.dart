// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../UI/mightierIcons.dart';
import 'presets/MightyXXBTPreset.dart';

import '../NuxDeviceControl.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';
import 'presets/Preset.dart';

enum M2040BTChannel {
  Clean1,
  Overdrive1,
  Metal1,
  Lead1,
  Clean2,
  Overdrive2,
  Metal2,
  Lead2
}

class NuxMighty2040BT extends NuxDevice {
  int get productVID => 48;

  static const _group1 = 0;
  static const _group2 = 1;

  String get productName => "NUX Mighty 20/40 BT";
  String get productNameShort => "Mighty 20/40 BT";
  String get productStringId => "mighty_20_40bt";
  IconData get productIcon => MightierIcons.amp_20bt;
  List<String> get productBLENames =>
      ["NUX MIGHTY20BT MIDI", "NUX MIGHTY40BT MIDI"];

  int get channelsCount => 3;
  int get effectsChainLength => 5;
  int get groupsCount => 2;
  int get amplifierSlotIndex => 1;
  bool get cabinetSupport => false;
  int get cabinetSlotIndex => 0;
  bool get presetSaveSupport => false;

  List<String> get groupsName => ["1", "2"];
  List<ProcessorInfo> get processorList => _processorList;

  final List<ProcessorInfo> _processorList = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        color: Colors.green,
        icon: MightierIcons.amp),
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

  List<Preset> presets1 = <Preset>[];
  List<Preset> presets2 = <Preset>[];

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
    presets1.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Clean1.index,
        channelName: "Clean"));

    //OD
    presets1.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Overdrive1.index,
        channelName: "Drive"));

    //Metal
    presets1.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Metal1.index,
        channelName: "Metal"));

    //Lead
    presets1.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Lead1.index,
        channelName: "Lead"));

    presets2.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Clean2.index,
        channelName: "Clean"));

    //OD
    presets2.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Overdrive2.index,
        channelName: "Drive"));

    //Metal
    presets2.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Metal2.index,
        channelName: "Metal"));

    //Lead
    presets2.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Lead2.index,
        channelName: "Lead"));

    presets.addAll(presets1);
    presets.addAll(presets2);
  }

  List<String> getDrumStyles() => drumStyles;

  List<Preset> getGroupPresets(int instr) {
    switch (instr) {
      case _group1:
        return presets1;
      case _group2:
        return presets2;
    }
    return <Preset>[];
  }

  void setGroupFromChannel(int chan) {
    if (chan < 4)
      selectedGroupP = _group1;
    else
      selectedGroupP = _group2;
  }

  void setChannelFromGroup(int instr) {
    if (instr == _group1)
      selectedChannelP = 0;
    else {
      selectedChannelP = 4;
    }
  }

  @override
  int get selectedChannelNormalized {
    if (selectedGroup == _group1) return selectedChannel;
    return selectedChannel - 4;
  }

  @override
  set selectedChannelNormalized(int chan) {
    if (selectedGroupP == _group1) {
      selectedChannelP = chan;
    } else
      selectedChannelP = chan + 4;

    super.selectedChannelNormalized = selectedChannelP;
  }

  @override
  String channelName(int channel) {
    return _channelNames[channel];
  }
}
