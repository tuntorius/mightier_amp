// This code is licensed under MIT license (see LICENSE.md for details)

import 'NuxConstants.dart';
import 'NuxDevice.dart';
import 'communication/communication.dart';
import 'communication/gp5Communication.dart';
import 'device_data/processors_list.dart';
import 'presets/Gp5Preset.dart';

import '../NuxDeviceControl.dart';
import 'effects/Processor.dart';

class NuxValetonGP5 extends NuxDevice {
  @override
  int get productVID => EProductNo.VALETONGP5_PID;

  late final Gp5Communication _communication = Gp5Communication(this, config);
  @override
  DeviceCommunication get communication => _communication;

  final NuxDeviceConfiguration _config = NuxDeviceConfiguration();
  @override
  NuxDeviceConfiguration get config => _config;

  @override
  String get productName => "Valeton GP5";
  @override
  String get productNameShort => "GP5";
  @override
  String get productStringId => "valeton_gp5";
  @override
  String get presetClass => productStringId;
  @override
  int get productVersion => 0;
  @override
  String get productIconLabel => "GP5";

  @override
  List<String> get productBLENames => ["Valeton GP5", "GP5", "GP-5"];

  @override
  int get channelsCount => 100;
  @override
  int get effectsChainLength => 10;
  int get groupsCount => 1;
  @override
  int get amplifierSlotIndex => 4; //chain order: NR PRE DST NAM AMP C....
  @override
  bool get fakeMasterVolume => true;
  @override
  bool get activeChannelRetrieval => true;
  @override
  bool get longChannelNames => true;
  @override
  bool get cabinetSupport => true;
  @override
  bool get hackableIRs => false;
  @override
  int get cabinetSlotIndex => 5; //chain order: NR PRE DST NAM AMP CAB
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
  int get deviceQRId => 0x10;
  @override
  int get deviceQRVersion => 1;

  @override
  List<String> get groupsName => ["Default"];
  @override
  List<ProcessorInfo> get processorList => ProcessorsList.gp5List;

  //the GP5 chain slot order differs from the FXID order (NAM sits between
  //DST and AMP), so effect names in JSON presets must map via the chain order.
  @override
  int? getSlotByEffectKeyName(String key) {
    var pi = getProcessorInfoByKey(key);
    if (pi == null) return null;
    return getPreset(selectedChannel).getSlotFromFXID(pi.nuxFXID);
  }

  NuxValetonGP5(NuxDeviceControl devControl) : super(devControl) {
    for (int i = 0; i < channelsCount; i++) {
      channelNames.add("P${(i + 1).toString().padLeft(2, '0')}");
      presets.add(Gp5Preset(device: this, channel: i, channelName: ""));
    }
  }

  @override
  dynamic getDrumStyles() => <String>[];

  @override
  void setFirmwareVersion(int ver) {}

  @override
  void setFirmwareVersionByIndex(int ver) {}

  @override
  Gp5Preset getCustomPreset(int channel) {
    var preset = Gp5Preset(device: this, channel: channel, channelName: "");
    preset.setFirmwareVersion(productVersion);
    return preset;
  }

  @override
  bool checkQRValid(int deviceId, int ver) {
    return deviceId == deviceQRId;
  }
}