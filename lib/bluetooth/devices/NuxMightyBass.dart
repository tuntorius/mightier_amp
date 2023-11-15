// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/device_data/processors_list.dart';
import 'communication/bassCommunication.dart';
import 'communication/communication.dart';

import '../NuxDeviceControl.dart';
import 'NuxConstants.dart';
import 'NuxDevice.dart';
import 'device_data/drumstyles.dart';
import 'effects/Processor.dart';
import 'presets/BassPreset.dart';
import 'value_formatters/ValueFormatter.dart';

enum BassChannel { channel1, channel2, channel3 }

enum BassVersion { bass1 }

class NuxMightyBassConfiguration extends NuxDeviceConfiguration {
  int usbMode = 0;
  int inputVol = 50;
  int outputVol = 50;
}

class NuxMightyBass extends NuxDevice {
  //this is used in conversion of very old format of presets which
  // didn't contain device id. They were always for mighty plug/air
  static const defaultNuxId = "mighty_plug_air";
  @override
  int get productVID => 48;

  late final BassCommunication _communication = BassCommunication(this, config);
  @override
  DeviceCommunication get communication => _communication;

  final NuxMightyBassConfiguration _config = NuxMightyBassConfiguration();
  @override
  NuxMightyBassConfiguration get config => _config;

  BassVersion version = BassVersion.bass1;

  @override
  String get productName => "NUX Mighty Bass 50BT";
  @override
  String get productNameShort => "Mighty Bass";
  @override
  String get productStringId => "mighty_bass_50bt";
  @override
  String get presetClass => productStringId;
  @override
  int get productVersion => version.index;
  @override
  String get productIconLabel => "BASS|50BT";
  @override
  List<String> get productBLENames => ["MIGHTY BASS MIDI"];

  String get mightyAirBLEName => productBLENames[1];
  //general settings

  int get usbMode => config.usbMode;
  int get inputVol => config.inputVol;
  int get outputVol => config.outputVol;

  @override
  int get channelsCount => 3;
  @override
  int get effectsChainLength => 6;
  @override
  int get amplifierSlotIndex => 2;
  @override
  bool get fakeMasterVolume => true;
  @override
  bool get activeChannelRetrieval => false;
  @override
  bool get longChannelNames => false;
  @override
  bool get cabinetSupport => true;
  @override
  bool get hackableIRs => false;
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
  ValueFormatter? get decibelFormatter => ValueFormatters.decibelMP2;
  @override
  int get channelChangeCC => MidiCCValues.bCC_CtrlType;
  @override
  int get deviceQRId => 0x66;

  @override
  int get deviceQRVersion => 1;

  @override
  List<ProcessorInfo> get processorList => ProcessorsList.bassList;

  List<String> channelNames = [];

  NuxMightyBass(NuxDeviceControl devControl) : super(devControl) {
    //clean
    presets.add(BassPreset(
        device: this, channel: BassChannel.channel1.index, channelName: "1"));

    //OD
    presets.add(BassPreset(
        device: this, channel: BassChannel.channel2.index, channelName: "2"));

    //Dist
    presets.add(BassPreset(
        device: this, channel: BassChannel.channel3.index, channelName: "3"));

    //get channel names
    for (var preset in presets) {
      (preset as BassPreset).setFirmwareVersion(version.index);
      channelNames.add("Channel ${preset.channelName}");
    }
  }

  @override
  dynamic getDrumStyles() => DrumStyles.drumStylesPlug;

  @override
  void setFirmwareVersionByIndex(int ver) {
    version = BassVersion.values[ver];
  }

  @override
  int getAvailableVersions() {
    return 1;
  }

  @override
  BassPreset getCustomPreset(int channel) {
    var preset = BassPreset(device: this, channel: channel, channelName: "");
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

  @override
  Widget getSettingsWidget() {
    return const SizedBox.shrink();
  }

  @override
  bool checkQRValid(int deviceId, int ver) {
    return deviceId == deviceQRId;
  }

  @override
  void setFirmwareVersion(int ver) {}
}
