// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../UI/mightierIcons.dart';
import 'NuxConstants.dart';
import 'communication/communication.dart';
import 'communication/liteCommunication.dart';
import 'presets/MightyLitePreset.dart';

import '../NuxDeviceControl.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';
import 'presets/Preset.dart';

enum MLiteChannel { Clean, Overdrive, Distortion }

class NuxMightyLite extends NuxDevice {
  int get productVID => 48;

  late LiteCommunication _communication = LiteCommunication(this, config);
  DeviceCommunication get communication => _communication;
  NuxDeviceConfiguration _config = NuxDeviceConfiguration();
  NuxDeviceConfiguration get config => _config;

  String get productName => "NUX Mighty Lite BT";
  String get productNameShort => "Mighty Lite";
  String get productStringId => "mighty_lite";
  int get productVersion => 0;
  IconData get productIcon => MightierIcons.amp_lite;

  List<String> get productBLENames =>
      ["NUX MIGHTY LITE MIDI", "AirBorne GO", "GUO AN MIDI"];

  int get channelsCount => 3;
  int get effectsChainLength => 4;
  int get groupsCount => 1;
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
  int get deviceQRId => 9;
  int get deviceQRVersion => 1;

  List<String> get groupsName => ["Default"];
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
        shortName: "Ambience",
        longName: "Ambience",
        keyName: "ambience",
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

  NuxMightyLite(NuxDeviceControl devControl) : super(devControl) {
    //get channel names
    MLiteChannel.values.forEach((element) {
      channelNames.add(element.toString().split('.')[1]);
    });

    //clean
    presets.add(MLitePreset(
        device: this, channel: MLiteChannel.Clean.index, channelName: "Clean"));

    //OD
    presets.add(MLitePreset(
        device: this,
        channel: MLiteChannel.Overdrive.index,
        channelName: "Drive"));

    //Dist
    presets.add(MLitePreset(
        device: this,
        channel: MLiteChannel.Distortion.index,
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
  MLitePreset getCustomPreset(int channel) {
    var preset = MLitePreset(device: this, channel: channel, channelName: "");
    preset.setFirmwareVersion(productVersion);
    return preset;
  }

  bool checkQRVersionValid(int ver) {
    return true;
  }
}
