// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/device_data/processors_list.dart';
import '../../UI/pages/device_specific_settings/PlugProSettings.dart';
import 'NuxFXID.dart';
import 'NuxReorderableDevice.dart';
import 'communication/communication.dart';
import 'communication/plugProCommunication.dart';

import '../NuxDeviceControl.dart';
import 'NuxDevice.dart';
import 'device_data/drumstyles.dart';
import 'effects/Processor.dart';
import 'effects/plug_pro/EQ.dart';
import 'features/looper.dart';
import 'features/tuner.dart';
import 'presets/PlugProPreset.dart';
import 'value_formatters/ValueFormatter.dart';

enum PlugProChannel { Clean, Overdrive, Distortion, AGSim, Pop, Rock, Funk }

enum PlugProVersion { PlugPro1 }

enum DrumsToneControl { Bass, Middle, Treble }

class NuxPlugProConfiguration extends NuxDeviceConfiguration {
  static const bluetoothEQCount = 4;

  double drumsBass = 50;
  double drumsMiddle = 50;
  double drumsTreble = 50;

  int routingMode = 1;
  int recLevel = 50;
  int playbackLevel = 50;
  int usbDryWet = 50;

  //Bluetooth and mic
  EQTenBandBT bluetoothEQ = EQTenBandBT();
  int bluetoothGroup = 0;
  bool bluetoothEQMute = false;
  bool bluetoothInvertChannel = false;

  bool micMute = false;
  int micVolume = 50;
  bool micNoiseGate = false;
  int micNGSensitivity = 50;
  int micNGDecay = 50;

  LooperData looperData = LooperData();

  TunerData tunerData = TunerData();
}

class NuxMightyPlugPro extends NuxReorderableDevice<PlugProPreset>
    implements Tuner {
  //NUX's own app source has info about wah, but is it really available?
  static const enableWahExperimental = false;

  @override
  int get productVID => 48;
  late final PlugProCommunication _communication =
      PlugProCommunication(this, config);

  @override
  DeviceCommunication get communication => _communication;

  final NuxPlugProConfiguration _config = NuxPlugProConfiguration();

  @override
  NuxPlugProConfiguration get config => _config;

  PlugProVersion version = PlugProVersion.PlugPro1;

  String versionDate = "";

  @override
  String get productName => "NUX Mighty Plug Pro";
  @override
  String get productNameShort => "Mighty Plug Pro";
  @override
  String get productStringId => "mighty_plug_pro";
  @override
  String get presetClass => "mighty_plug_pro";
  @override
  String get productNameForQR => "Mighty Plug Pro/Space";
  @override
  int get productVersion => version.index;
  @override
  String get productIconLabel => "MP-3|-|SPACE";
  @override
  List<String> get productBLENames => ["MIGHTY PLUG PRO"];

  @override
  int get channelsCount => 7;
  @override
  int get effectsChainLength => enableWahExperimental ? 10 : 9;
  int get groupsCount => 1;

  @override
  NuxFXID get ampFXID => PlugProFXID.amp;

  @override
  NuxFXID get cabFXID => PlugProFXID.cab;

  @override
  bool get longChannelNames => false;
  @override
  bool get fakeMasterVolume => false;
  @override
  bool get activeChannelRetrieval => true;
  @override
  bool get cabinetSupport => true;
  @override
  bool get hackableIRs => false;

  @override
  bool get presetSaveSupport => true;
  @override
  bool get batterySupport => false;
  @override
  bool get nativeActiveChannelsSupport => true;
  @override
  int get channelChangeCC => -1;
  @override
  ValueFormatter? get decibelFormatter => ValueFormatters.decibelMPPro;

  @override
  int get deviceQRId => 15;
  @override
  int get deviceQRVersion => 1;

  double get drumsBass => config.drumsBass;
  double get drumsMiddle => config.drumsMiddle;
  double get drumsTreble => config.drumsTreble;

  @override
  bool get drumToneControls => true;

  @override
  double get drumsMaxTempo => 300;

  @override
  List<ProcessorInfo> get processorList => ProcessorsList.plugProList;

  final tunerController = StreamController<TunerData>.broadcast();

  int? _drumStylesCount;

  NuxMightyPlugPro(NuxDeviceControl devControl) : super(devControl) {
    for (int i = 0; i < PlugProChannel.values.length; i++) {
      presets.add(PlugProPreset(
          device: this, channel: i, channelName: (i + 1).toString()));
    }

    for (var preset in presets) {
      (preset as PlugProPreset).setFirmwareVersion(version.index);
      channelNames.add("Channel ${preset.channelName}");
    }
  }

  @override
  dynamic getDrumStyles() => DrumStyles.drumCategoriesPro;

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
    version = PlugProVersion.PlugPro1;

    //set all presets with that firmware
    for (var preset in presets) {
      (preset as PlugProPreset).setFirmwareVersion(version.index);
    }
  }

  @override
  void setFirmwareVersionByIndex(int ver) {
    if (ver > getAvailableVersions() - 1) ver = getAvailableVersions() - 1;
    version = PlugProVersion.values[ver];

    //set all presets with that firmware
    for (var preset in presets) {
      (preset as PlugProPreset).setFirmwareVersion(version.index);
    }
  }

  void setVersionDate(String vDate) {
    versionDate = vDate;
  }

  @override
  onDisconnect() {
    versionDate = "";
    super.onDisconnect();
  }

  @override
  PlugProPreset getCustomPreset(int channel) {
    var preset = PlugProPreset(device: this, channel: channel, channelName: "");
    preset.setFirmwareVersion(productVersion);
    return preset;
  }

  void setUsbMode(int mode) {
    config.routingMode = mode;
    communication.setUsbAudioMode(mode);
  }

  void setUsbRecordingVol(int vol) {
    config.recLevel = vol;
    communication.setUsbInputVolume(vol);
  }

  void setUsbPlaybackVol(int vol) {
    config.playbackLevel = vol;
    communication.setUsbOutputVolume(vol);
  }

  void setUsbDryWetVol(int vol) {
    config.usbDryWet = vol;
    _communication.setUsbDryWet(vol);
  }

  @override
  Widget getSettingsWidget() {
    return PlugProSettings(device: this, mightySpace: false);
  }

  @override
  bool checkQRValid(int deviceId, int ver) {
    return deviceId == deviceQRId && ver == 1;
  }

  void setDrumsTone(double value, DrumsToneControl control, bool send) {
    switch (control) {
      case DrumsToneControl.Bass:
        config.drumsBass = value;
        break;
      case DrumsToneControl.Middle:
        config.drumsMiddle = value;
        break;
      case DrumsToneControl.Treble:
        config.drumsTreble = value;
        break;
    }
    if (send) _communication.setDrumsTone(value, control);
  }

  @override
  bool get tunerAvailable {
    return versionDate.compareTo("20230101") > 0;
  }

  @override
  void tunerEnable(bool enable) {
    _communication.enableTuner(enable);
  }

  @override
  void tunerRequestSettings() {
    _communication.requestTunerSettings();
  }

  @override
  void tunerSetMode(TunerMode mode) {
    config.tunerData.mode = mode;
    _communication.tunerSetSettings();
    notifyTunerListeners();
  }

  @override
  void tunerSetReferencePitch(int refPitch) {
    config.tunerData.referencePitch = refPitch;
    _communication.tunerSetSettings();
    notifyTunerListeners();
  }

  @override
  void tunerMute(bool enable) {
    config.tunerData.muted = enable;
    _communication.tunerSetSettings();
    notifyTunerListeners();
  }

  @override
  Stream<TunerData> getTunerDataStream() {
    return tunerController.stream;
  }

  @override
  void notifyTunerListeners() {
    tunerController.add(config.tunerData);
  }
}
