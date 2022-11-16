// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../UI/mightierIcons.dart';
import 'NuxConstants.dart';
import 'communication/communication.dart';
import 'communication/liteCommunication.dart';
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
  @override
  int get productVID => 48;

  late final LiteCommunication _communication = LiteCommunication(this, config);
  @override
  DeviceCommunication get communication => _communication;
  final NuxDeviceConfiguration _config = NuxDeviceConfiguration();
  @override
  NuxDeviceConfiguration get config => _config;

  @override
  String get productName => "NUX Mighty 20/40 BT";
  @override
  String get productNameShort => "Mighty 20/40 BT";
  @override
  String get productStringId => "mighty_20_40bt";
  @override
  int get productVersion => 0;
  @override
  String get productIconLabel => "20/40\nBT";
  @override
  List<String> get productBLENames =>
      ["NUX MIGHTY20BT MIDI", "NUX MIGHTY40BT MIDI"];

  @override
  int get channelsCount => 8;
  @override
  int get effectsChainLength => 5;
  int get groupsCount => 1;
  @override
  int get amplifierSlotIndex => 1;
  @override
  bool get fakeMasterVolume => true;
  @override
  bool get activeChannelRetrieval => false;
  @override
  bool get longChannelNames => true;
  @override
  bool get cabinetSupport => false;
  @override
  bool get hackableIRs => false;
  @override
  int get cabinetSlotIndex => 0;
  @override
  bool get presetSaveSupport => false;
  @override
  bool get reorderableFXChain => false;
  @override
  bool get batterySupport => false;
  @override
  bool get nativeActiveChannelsSupport => false;
  @override
  int get channelChangeCC => MidiCCValues.bCC_AmpMode;
  @override
  int get deviceQRId => 7;
  @override
  int get deviceQRVersion => 1;

  @override
  List<String> get groupsName => ["All"]; //, "Group 2"];
  @override
  List<ProcessorInfo> get processorList => _processorList;

  final List<ProcessorInfo> _processorList = [
    ProcessorInfo(
        shortName: "Gate",
        longName: "Noise Gate",
        keyName: "gate",
        nuxOrderIndex: 0,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        nuxOrderIndex: 1,
        color: Colors.green,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        nuxOrderIndex: 2,
        color: Colors.cyan[300]!,
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "Delay",
        longName: "Delay",
        keyName: "delay",
        nuxOrderIndex: 3,
        color: Colors.blueAccent,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "Reverb",
        longName: "Reverb",
        keyName: "reverb",
        nuxOrderIndex: 4,
        color: Colors.orange,
        icon: Icons.blur_on),
  ];

  List<Preset> presets1 = <Preset>[];
  List<Preset> presets2 = <Preset>[];

  final List<String> _channelNames = [];

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
    for (var element in M2040BTChannel.values) {
      _channelNames.add(element.toString().split('.')[1]);
    }

    //clean
    presets1.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Clean1.index,
        channelName: "Clean 1"));

    //OD
    presets1.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Overdrive1.index,
        channelName: "Drive 1"));

    //Metal
    presets1.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Metal1.index,
        channelName: "Metal 1"));

    //Lead
    presets1.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Lead1.index,
        channelName: "Lead 1"));

    presets2.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Clean2.index,
        channelName: "Clean 2"));

    //OD
    presets2.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Overdrive2.index,
        channelName: "Drive 2"));

    //Metal
    presets2.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Metal2.index,
        channelName: "Metal 2"));

    //Lead
    presets2.add(MXXBTPreset(
        device: this,
        channel: M2040BTChannel.Lead2.index,
        channelName: "Lead 2"));

    presets.addAll(presets1);
    presets.addAll(presets2);
  }

  @override
  dynamic getDrumStyles() => drumStyles;

  @override
  List<Preset> getPresetsList() {
    return presets;
  }

  @override
  String channelName(int channel) {
    return _channelNames[channel];
  }

  @override
  void setFirmwareVersion(int ver) {}

  @override
  void setFirmwareVersionByIndex(int ver) {}

  @override
  MXXBTPreset getCustomPreset(int channel) {
    var preset = MXXBTPreset(device: this, channel: channel, channelName: "");
    preset.setFirmwareVersion(productVersion);
    return preset;
  }

  @override
  bool checkQRValid(int deviceId, int ver) {
    return deviceId == deviceQRId;
  }
}
