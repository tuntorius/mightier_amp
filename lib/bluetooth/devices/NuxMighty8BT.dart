import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/Mighty8BTPreset.dart';

import '../NuxDeviceControl.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';
import 'presets/Preset.dart';

enum M8BTChannel { Clean, Overdrive, Distortion }

class NuxMighty8BT extends NuxDevice {
  int get productVID => 48;

  static const _group = 0;

  String get productName => "NUX Mighty 8 BT";
  String get productStringId => "mighty_8bt";

  int get channelsCount => 3;
  int get effectsChainLength => 5;
  int get groupsCount => 1;
  List<String> get groupsName => ["Default"];
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

  List<String> channelNames = [];

  final List<String> drumStyles = [
    "Metronome",
    "Pop",
    "Metal",
    "Blues",
    "Country",
    "Rock",
    "Ballad Rock",
    "Funk",
    "R&B",
    "Latin"
  ];

  NuxMighty8BT(NuxDeviceControl devControl) : super(devControl) {
    //get channel names
    M8BTChannel.values.forEach((element) {
      channelNames.add(element.toString().split('.')[1]);
    });

    //clean
    presets.add(M8BTPreset(
        device: this, channel: M8BTChannel.Clean.index, channelName: "Clean"));

    //OD
    presets.add(M8BTPreset(
        device: this,
        channel: M8BTChannel.Overdrive.index,
        channelName: "Drive"));

    //Dist
    presets.add(M8BTPreset(
        device: this,
        channel: M8BTChannel.Distortion.index,
        channelName: "Dist"));
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
    return channelNames[channel];
  }
}
