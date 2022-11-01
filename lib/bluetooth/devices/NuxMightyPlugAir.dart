// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/device_specific_settings/PlugAirSettings.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/communication.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/plugAirCommunication.dart';
import '../../UI/mightierIcons.dart';

import '../NuxDeviceControl.dart';
import 'NuxConstants.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';
import 'presets/PlugAirPreset.dart';
import 'presets/Preset.dart';

enum PlugAirChannel { Clean, Overdrive, Distortion, AGSim, Pop, Rock, Funk }

enum PlugAirVersion { PlugAir15, PlugAir21 }

class NuxMightyPlugConfiguration extends NuxDeviceConfiguration {
  int usbMode = 0;
  int inputVol = 0;
  int outputVol = 0;
  int btEq = 0;
}

class NuxMightyPlug extends NuxDevice {
  //this is used in conversion of very old format of presets which
  // didn't contain device id. They were always for mighty plug/air
  static const defaultNuxId = "mighty_plug_air";
  int get productVID => 48;

  late PlugAirCommunication _communication = PlugAirCommunication(this, config);
  DeviceCommunication get communication => _communication;

  NuxMightyPlugConfiguration _config = NuxMightyPlugConfiguration();
  NuxMightyPlugConfiguration get config => _config;

  PlugAirVersion version = PlugAirVersion.PlugAir21;

  String get productName => "NUX Mighty Plug/Air";
  String get productNameShort => "Mighty Plug/Air";
  String get productStringId => "mighty_plug_air";
  int get productVersion => version.index;
  IconData get productIcon => MightierIcons.amp_plugair;
  List<String> get productBLENames =>
      ["NUX MIGHTY PLUG MIDI", "NUX MIGHTY AIR MIDI"];

  //general settings

  int get usbMode => config.usbMode;
  int get inputVol => config.inputVol;
  int get outputVol => config.outputVol;
  int get btEq => config.btEq;

  int get channelsCount => 7;
  int get effectsChainLength => 7;
  int get groupsCount => 1;
  int get amplifierSlotIndex => 2;
  bool get fakeMasterVolume => true;
  bool get activeChannelRetrieval => true;
  bool get longChannelNames => false;
  bool get cabinetSupport => true;
  bool get hackableIRs => true;
  int get cabinetSlotIndex => 3;
  bool get presetSaveSupport => true;
  bool get reorderableFXChain => false;
  bool get batterySupport => true;
  bool get nativeActiveChannelsSupport => false;
  int get channelChangeCC => MidiCCValues.bCC_CtrlType;
  int get deviceQRId => 6;
  int get deviceQRVersion => version == PlugAirVersion.PlugAir21 ? 2 : 0;

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
        color: Colors.deepPurpleAccent[100]!,
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
        device: this, channel: PlugAirChannel.Clean.index, channelName: "1"));

    //OD
    guitarPresets.add(PlugAirPreset(
        device: this,
        channel: PlugAirChannel.Overdrive.index,
        channelName: "2"));

    //Dist
    guitarPresets.add(PlugAirPreset(
        device: this,
        channel: PlugAirChannel.Distortion.index,
        channelName: "3"));

    //AGSim
    guitarPresets.add(PlugAirPreset(
        device: this, channel: PlugAirChannel.AGSim.index, channelName: "4"));

    //Pop Bass
    bassPresets.add(PlugAirPreset(
        device: this, channel: PlugAirChannel.Pop.index, channelName: "5"));

    //Rock Bass
    bassPresets.add(PlugAirPreset(
        device: this, channel: PlugAirChannel.Rock.index, channelName: "6"));

    //Funk Bass
    bassPresets.add(PlugAirPreset(
        device: this, channel: PlugAirChannel.Funk.index, channelName: "7"));

    presets.addAll(guitarPresets);
    presets.addAll(bassPresets);

    for (var preset in presets)
      (preset as PlugAirPreset).setFirmwareVersion(version.index);
  }

  dynamic getDrumStyles() => drumStyles;

  List<Preset> getPresetsList() {
    return presets;
  }

  @override
  String channelName(int channel) {
    return channelNames[channel];
  }

  @override
  void setFirmwareVersion(int ver) {
    if (ver < 21)
      version = PlugAirVersion.PlugAir15;
    else {
      version = PlugAirVersion.PlugAir21;
    }

    //set all presets with that firmware
    for (var preset in presets)
      (preset as PlugAirPreset).setFirmwareVersion(version.index);
  }

  @override
  void setFirmwareVersionByIndex(int ver) {
    version = PlugAirVersion.values[ver];

    //set all presets with that firmware
    for (var preset in presets)
      (preset as PlugAirPreset).setFirmwareVersion(version.index);
  }

  @override
  int getAvailableVersions() {
    return 2;
  }

  @override
  String getProductNameVersion(int version) {
    switch (PlugAirVersion.values[version]) {
      case PlugAirVersion.PlugAir15:
        return "$productNameShort v1.x";
      case PlugAirVersion.PlugAir21:
        return "$productNameShort v2.x";
    }
  }

  @override
  PlugAirPreset getCustomPreset(int channel) {
    var preset = PlugAirPreset(device: this, channel: channel, channelName: "");
    preset.setFirmwareVersion(productVersion);
    return preset;
  }

  //device specific settings
  void setUsbMode(int mode) {
    config.usbMode = mode;
    communication.setUsbAudioMode(mode);
  }

  void setUsbInputVol(int vol) {
    config.inputVol = vol;
    communication.setUsbInputVolume(vol);
  }

  void setUsbOutputVol(int vol) {
    config.outputVol = vol;
    communication.setUsbOutputVolume(vol);
  }

  void setBtEq(int eq) {
    config.btEq = eq;
    communication.setBTEq(eq);
  }

  Widget getSettingsWidget() {
    return PlugAirSettings(device: this);
  }

  bool checkQRVersionValid(int ver) {
    if (version == PlugAirVersion.PlugAir15 && ver == 0)
      return true;
    else if (version == PlugAirVersion.PlugAir21 && ver > 0) return true;

    return false;
  }
}
