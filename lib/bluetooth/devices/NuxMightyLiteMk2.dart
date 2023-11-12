import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxFXID.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/communication.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/PlugProPreset.dart';

import '../../UI/mightierIcons.dart';
import 'NuxMightyPlugPro.dart';
import 'communication/liteMk2Communication.dart';
import 'device_data/drumstyles.dart';
import 'features/tuner.dart';
import 'presets/MightyMk2Preset.dart';
import 'value_formatters/ValueFormatter.dart';

enum LiteMK2Version { LiteMK2v1 }

class NuxMightyLiteMk2 extends NuxDevice implements Tuner {
  NuxMightyLiteMk2(super.devControl) {
    //get channel names
    for (int i = 0; i < channelsCount; i++) {
      presets.add(MightyMk2Preset(
          device: this, channel: i, channelName: (i + 1).toString()));
      channelNames.add((i + 1).toString());
    }
  }

  late final LiteMk2Communication _communication =
      LiteMk2Communication(this, config);

  final NuxPlugProConfiguration _config = NuxPlugProConfiguration();

  LiteMK2Version version = LiteMK2Version.LiteMK2v1;

  @override
  String get productName => "NUX Mighty Lite MK2";
  @override
  String get productNameShort => "Mighty Lite MK2";
  @override
  String get productStringId => "mighty_lite2";
  @override
  int get productVersion => version.index;
  @override
  String get productIconLabel => "LITE MK2|-|8BT MK2";
  @override
  List<String> get productBLENames => ["NUX NGA-3BT"];

  @override
  int get productVID => 0;

  @override
  bool get activeChannelRetrieval => true;

  @override
  bool get batterySupport => false;

  @override
  bool get cabinetSupport => true;

  @override
  int get channelChangeCC => -1;

  @override
  int get channelsCount => 7;

  @override
  ValueFormatter? get decibelFormatter => ValueFormatters.decibelMPPro;

  @override
  DeviceCommunication get communication => _communication;

  @override
  // TODO: implement config
  NuxDeviceConfiguration get config => _config;

  @override
  int get deviceQRId => 0x13;

  @override
  int get deviceQRVersion => 0x01;

  @override
  int get effectsChainLength => 7;

  @override
  bool get fakeMasterVolume => false;

  @override
  bool get hackableIRs => false;

  @override
  bool get longChannelNames => false;

  @override
  bool get nativeActiveChannelsSupport => true;

  @override
  bool get reorderableFXChain => false;

  @override
  int get amplifierSlotIndex => 2;

  @override
  int get cabinetSlotIndex => 3;

  @override
  String get presetClass => "mighty_amps_mk2";

  @override
  bool get presetSaveSupport => false;

  @override
  List<ProcessorInfo> get processorList => _processorList;

  int? _drumStylesCount;

  final List<ProcessorInfo> _processorList = [
    const ProcessorInfo(
        shortName: "GATE",
        longName: "Noise Gate",
        keyName: "gate",
        nuxFXID: LiteMK2FXID.gate,
        color: Colors.green,
        icon: MightierIcons.gate),
    const ProcessorInfo(
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        nuxFXID: LiteMK2FXID.efx,
        color: Colors.orange,
        icon: MightierIcons.pedal),
    const ProcessorInfo(
        shortName: "AMP",
        longName: "Amplifier",
        keyName: "amp",
        nuxFXID: LiteMK2FXID.amp,
        color: Colors.red,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cab",
        keyName: "cabinet",
        nuxFXID: LiteMK2FXID.cab,
        color: Colors.lightBlue[400]!,
        icon: MightierIcons.cabinet),
    const ProcessorInfo(
        shortName: "EQ",
        longName: "EQ",
        keyName: "eq",
        nuxFXID: PlugProFXID.eq,
        color: Color(0xFFE0E0E0), //grey[300]
        icon: MightierIcons.sliders),
    ProcessorInfo(
        shortName: "MOD",
        longName: "Modulation",
        keyName: "mod",
        nuxFXID: LiteMK2FXID.mod,
        color: Colors.deepPurple[400]!,
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "DLY",
        longName: "Delay",
        keyName: "delay",
        nuxFXID: LiteMK2FXID.delay,
        color: Colors.cyan[300]!,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "RVB",
        longName: "Reverb",
        keyName: "reverb",
        nuxFXID: LiteMK2FXID.reverb,
        color: Colors.purple[200]!,
        icon: Icons.blur_on),
  ];

  @override
  getDrumStyles() => DrumStyles.drumCategoriesPro;

  @override
  int getDrumStylesCount() {
    if (_drumStylesCount == null) {
      _drumStylesCount = 0;
      for (var cat in DrumStyles.drumCategoriesPro.values) {
        _drumStylesCount = _drumStylesCount! + cat.length;
      }
    }
    return _drumStylesCount!;
  }

  @override
  void setFirmwareVersion(int ver) {
    // TODO: implement setFirmwareVersion
  }

  @override
  void setFirmwareVersionByIndex(int ver) {
    // TODO: implement setFirmwareVersionByIndex
  }

  @override
  bool checkQRValid(int deviceId, int ver) {
    return deviceId == deviceQRId && ver == 1;
  }

  @override
  PlugProPreset getCustomPreset(int channel) {
    var preset = PlugProPreset(device: this, channel: channel, channelName: "");
    preset.setFirmwareVersion(productVersion);
    return preset;
  }

  @override
  // TODO: implement tunerAvailable
  bool get tunerAvailable => false;

  @override
  void tunerEnable(bool enable) {
    // TODO: implement tunerEnable
  }

  @override
  void tunerMute(bool enable) {
    // TODO: implement tunerMute
  }

  @override
  void tunerRequestSettings() {
    // TODO: implement tunerRequestSettings
  }

  @override
  Stream<TunerData> getTunerDataStream() {
    // TODO: implement getTunerDataStream
    throw UnimplementedError();
  }

  @override
  void notifyTunerListeners() {
    // TODO: implement notifyTunerListeners
  }

  @override
  void tunerSetMode(TunerMode mode) {
    // TODO: implement tunerSetMode
  }

  @override
  void tunerSetReferencePitch(int refPitch) {
    // TODO: implement tunerSetReferencePitch
  }
}
