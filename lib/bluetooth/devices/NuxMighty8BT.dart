// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:mighty_plug_manager/bluetooth/devices/device_data/processors_list.dart';
import 'NuxConstants.dart';
import 'communication/communication.dart';
import 'communication/liteCommunication.dart';
import 'device_data/drumstyles.dart';
import 'presets/Mighty8BTPreset.dart';

import '../NuxDeviceControl.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';

enum M8BTChannel { Clean, Overdrive, Distortion }

class NuxMighty8BT extends NuxDevice {
  @override
  int get productVID => 48;

  late final LiteCommunication _communication = LiteCommunication(this, config);
  @override
  DeviceCommunication get communication => _communication;
  final NuxDeviceConfiguration _config = NuxDeviceConfiguration();
  @override
  NuxDeviceConfiguration get config => _config;

  @override
  String get productName => "NUX Mighty 8 BT";
  @override
  String get productNameShort => "Mighty 8 BT";
  @override
  String get productIconLabel => "8 BT";

  @override
  String get productStringId => "mighty_8bt";
  @override
  String get presetClass => productStringId;
  @override
  int get productVersion => 0;
  @override
  List<String> get productBLENames => ["NUX MIGHTY8BT"];

  @override
  int get channelsCount => 3;
  @override
  int get effectsChainLength => 5;
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
  bool get presetSaveSupport => true;
  @override
  bool get reorderableFXChain => false;
  @override
  bool get batterySupport => false;
  @override
  bool get nativeActiveChannelsSupport => false;
  @override
  int get channelChangeCC => MidiCCValues.bCC_AmpModeSetup;
  @override
  int get deviceQRId => 12;
  @override
  int get deviceQRVersion => 1;
  @override
  bool get jamTrackChannelChange => true;

  @override
  List<ProcessorInfo> get processorList => ProcessorsList.mighty8BTList;

  List<String> channelNames = [];

  NuxMighty8BT(NuxDeviceControl devControl) : super(devControl) {
    //get channel names
    for (var element in M8BTChannel.values) {
      channelNames.add(element.toString().split('.')[1]);
    }

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

  @override
  dynamic getDrumStyles() => DrumStyles.drumStyles8BT;

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

  @override
  bool checkQRValid(int deviceId, int ver) {
    return deviceId == deviceQRId;
  }
}
