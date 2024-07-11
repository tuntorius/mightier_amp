// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/device_data/processors_list.dart';
import '../../UI/pages/device_specific_settings/PlugProSettings.dart';
import 'NuxConstants.dart';
import 'NuxFXID.dart';
import 'NuxReorderableDevice.dart';
import 'communication/communication.dart';
import 'communication/plugProCommunication.dart';

import '../NuxDeviceControl.dart';
import 'NuxDevice.dart';
import 'device_data/drumstyles.dart';
import 'effects/Processor.dart';
import 'effects/plug_pro/EQ.dart';
import 'features/drumsTone.dart';
import 'features/looper.dart';
import 'features/proUsbSettings.dart';
import 'features/tuner.dart';
import 'presets/PlugProPreset.dart';
import 'value_formatters/ValueFormatter.dart';

enum PlugProChannel { Clean, Overdrive, Distortion, AGSim, Pop, Rock, Funk }

enum PlugProVersion { PlugPro1 }

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
    implements Tuner, ProUsbSettings, DrumsTone {
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
  bool version2024July = true;

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
  int get effectsChainLength => 9;
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

  @override
  double get drumsBass => config.drumsBass;
  @override
  double get drumsMiddle => config.drumsMiddle;
  @override
  double get drumsTreble => config.drumsTreble;

  @override
  double get drumsMaxTempo => 300;

  @override
  List<ProcessorInfo> get processorList => ProcessorsList.plugProList;

  final _tunerController = StreamController<TunerData>.broadcast();

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
  Map<String, Map<dynamic, dynamic>> getDrumStyles() => version2024July
      ? DrumStyles.drumCategoriesProV2
      : DrumStyles.drumCategoriesPro;

  @override
  int getDrumStylesCount() {
    if (_drumStylesCount == null) {
      _drumStylesCount = 0;
      for (var cat in getDrumStyles().values) {
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
    version2024July = versionDate.compareTo("20240101") > 0;
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

  @override
  void setUsbMode(int mode) {
    config.routingMode = mode;
    communication.setUsbAudioMode(mode);
  }

  @override
  void setUsbRecordingVol(int vol) {
    config.recLevel = vol;
    communication.setUsbInputVolume(vol);
  }

  @override
  void setUsbPlaybackVol(int vol) {
    config.playbackLevel = vol;
    communication.setUsbOutputVolume(vol);
  }

  @override
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

  @override
  void setDrumsTone(double value, DrumsToneControl control, bool send) {
    switch (control) {
      case DrumsToneControl.bass:
        config.drumsBass = value;
        break;
      case DrumsToneControl.middle:
        config.drumsMiddle = value;
        break;
      case DrumsToneControl.treble:
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
    return _tunerController.stream;
  }

  @override
  void notifyTunerListeners() {
    _tunerController.add(config.tunerData);
  }

  @override
  int get tunerNoteCC => MidiCCValuesPro.TUNER_Note;

  @override
  int get tunerPitchCC => MidiCCValuesPro.TUNER_Cent;

  @override
  int get tunerStateCC => MidiCCValuesPro.TUNER_State;

  @override
  int get tunerStringCC => MidiCCValuesPro.TUNER_Number;
}
