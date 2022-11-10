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
  @override
  int get productVID => 48;

  late final PlugAirCommunication _communication =
      PlugAirCommunication(this, config);
  @override
  DeviceCommunication get communication => _communication;

  final NuxMightyPlugConfiguration _config = NuxMightyPlugConfiguration();
  @override
  NuxMightyPlugConfiguration get config => _config;

  PlugAirVersion version = PlugAirVersion.PlugAir21;

  @override
  String get productName => "NUX Mighty Plug/Air";
  @override
  String get productNameShort => "Mighty Plug/Air";
  @override
  String get productStringId => "mighty_plug_air";
  @override
  int get productVersion => version.index;
  @override
  IconData get productIcon => MightierIcons.amp_plugair;
  @override
  List<String> get productBLENames =>
      ["NUX MIGHTY PLUG MIDI", "NUX MIGHTY AIR MIDI"];

  //general settings

  int get usbMode => config.usbMode;
  int get inputVol => config.inputVol;
  int get outputVol => config.outputVol;
  int get btEq => config.btEq;

  @override
  int get channelsCount => 7;
  @override
  int get effectsChainLength => 7;
  int get groupsCount => 1;
  @override
  int get amplifierSlotIndex => 2;
  @override
  bool get fakeMasterVolume => true;
  @override
  bool get activeChannelRetrieval => true;
  @override
  bool get longChannelNames => false;
  @override
  bool get cabinetSupport => true;
  @override
  bool get hackableIRs => true;
  @override
  int get cabinetSlotIndex => 3;
  @override
  bool get presetSaveSupport => true;
  @override
  bool get reorderableFXChain => false;
  @override
  bool get batterySupport => true;
  @override
  bool get nativeActiveChannelsSupport => false;
  @override
  int get channelChangeCC => MidiCCValues.bCC_CtrlType;
  @override
  int get deviceQRId => 6;
  @override
  int get deviceQRVersion => version == PlugAirVersion.PlugAir21 ? 2 : 0;

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
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        nuxOrderIndex: 1,
        color: Colors.deepPurpleAccent[100]!,
        icon: MightierIcons.pedal),
    ProcessorInfo(
        shortName: "Amp",
        longName: "Amplifier",
        keyName: "amp",
        nuxOrderIndex: 2,
        color: Colors.green,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cabinet",
        keyName: "cabinet",
        nuxOrderIndex: 3,
        color: Colors.blue,
        icon: MightierIcons.cabinet),
    ProcessorInfo(
        shortName: "Mod",
        longName: "Modulation",
        keyName: "mod",
        nuxOrderIndex: 4,
        color: Colors.cyan[300]!,
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "Delay",
        longName: "Delay",
        keyName: "delay",
        nuxOrderIndex: 5,
        color: Colors.blueAccent,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "Reverb",
        longName: "Reverb",
        keyName: "reverb",
        nuxOrderIndex: 6,
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

    //get channel names
    for (var preset in presets) {
      (preset as PlugAirPreset).setFirmwareVersion(version.index);
      channelNames.add("Channel ${preset.channelName}");
    }
  }

  @override
  dynamic getDrumStyles() => drumStyles;

  @override
  List<Preset> getPresetsList() {
    return presets;
  }

  @override
  String channelName(int channel) {
    return channelNames[channel];
  }

  @override
  void setFirmwareVersion(int ver) {
    if (ver < 21) {
      version = PlugAirVersion.PlugAir15;
    } else {
      version = PlugAirVersion.PlugAir21;
    }

    //set all presets with that firmware
    for (var preset in presets) {
      (preset as PlugAirPreset).setFirmwareVersion(version.index);
    }
  }

  @override
  void setFirmwareVersionByIndex(int ver) {
    version = PlugAirVersion.values[ver];

    //set all presets with that firmware
    for (var preset in presets) {
      (preset as PlugAirPreset).setFirmwareVersion(version.index);
    }
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

  @override
  Widget getSettingsWidget() {
    return PlugAirSettings(device: this);
  }

  @override
  bool checkQRVersionValid(int ver) {
    if (version == PlugAirVersion.PlugAir15 && ver == 0) {
      return true;
    } else if (version == PlugAirVersion.PlugAir21 && ver > 0) {
      return true;
    }

    return false;
  }
}
