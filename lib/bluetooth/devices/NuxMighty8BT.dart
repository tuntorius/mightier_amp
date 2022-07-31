// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../UI/mightierIcons.dart';
import 'NuxConstants.dart';
import 'communication/communication.dart';
import 'communication/liteCommunication.dart';
import 'presets/Mighty8BTPreset.dart';

import '../NuxDeviceControl.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';
import 'presets/Preset.dart';

enum M8BTChannel { Clean, Overdrive, Distortion }

class NuxMighty8BT extends NuxDevice {
  int get productVID => 48;
  late LiteCommunication _communication = new LiteCommunication(this);
  DeviceCommunication get communication => _communication;

  String get productName => "NUX Mighty 8 BT";
  String get productNameShort => "Mighty 8 BT";
  IconData get productIcon => MightierIcons.amp_8bt;
  String get productStringId => "mighty_8bt";
  int get productVersion => 0;
  List<String> get productBLENames => ["NUX MIGHTY8BT MIDI"];

  int get channelsCount => 3;
  int get effectsChainLength => 5;
  int get amplifierSlotIndex => 1;
  bool get fakeMasterVolume => true;
  bool get cabinetSupport => false;
  bool get hackableIRs => false;
  int get cabinetSlotIndex => 0;
  bool get presetSaveSupport => false;
  bool get reorderableFXChain => false;
  bool get advancedSettingsSupport => false;
  bool get batterySupport => false;
  int get channelChangeCC => MidiCCValues.bCC_AmpModeSetup;
  int get deviceQRId => 3;

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

  List<Preset> getPresetsList() {
    return presets;
  }

  @override
  String channelName(int channel) {
    return channelNames[channel];
  }

  @override
  void setFirmwareVersion(int ver) {}

  @override
  void setFirmwareVersionByIndex(int ver) {}

  @override
  M8BTPreset getCustomPreset(int channel) {
    var preset = M8BTPreset(device: this, channel: channel, channelName: "");
    preset.setFirmwareVersion(productVersion);
    return preset;
  }
}
