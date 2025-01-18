import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/device_specific_settings/PlugProSettings.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/communication.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';

import '../../UI/pages/device_specific_settings/LiteMk2Settings.dart';
import 'NuxConstants.dart';
import 'communication/liteMk2Communication.dart';
import 'device_data/drumstyles.dart';
import 'device_data/processors_list.dart';
import 'effects/plug_pro/EQ.dart';
import 'features/drumsTone.dart';
import 'features/looper.dart';
import 'features/proUsbSettings.dart';
import 'features/tuner.dart';
import 'presets/MightyMk2Preset.dart';
import 'value_formatters/ValueFormatter.dart';

enum LiteMK2Version { LiteMK2v1 }

class NuxMighty8BT2Configuration extends NuxDeviceConfiguration {
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

class NuxMighty8BTMk2 extends NuxDevice
    implements Tuner, ProUsbSettings, DrumsTone, Looper {
  NuxMighty8BTMk2(super.devControl) {
    //get channel names
    for (int i = 0; i < channelsCount; i++) {
      presets.add(MightyMk2Preset(
          device: this, channel: i, channelName: (i + 1).toString()));
      channelNames.add((i + 1).toString());
    }
  }

  late final LiteMk2Communication _communication =
      LiteMk2Communication(this, config);

  final NuxMighty8BT2Configuration _config = NuxMighty8BT2Configuration();

  LiteMK2Version version = LiteMK2Version.LiteMK2v1;

  @override
  String get productName => "NUX Mighty 8BT MKII";
  @override
  String get productNameShort => "Mighty 8BT MKII";
  @override
  String get productStringId => "mighty_lite2";
  @override
  int get productVersion => version.index;
  @override
  String get productIconLabel => "LITE II|-|8BT II";
  @override
  List<String> get productBLENames => ["NUX NGA-8BT", "MIGHTY 8BT MKII"];

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
  NuxMighty8BT2Configuration get config => _config;

  @override
  int get deviceQRId => 0x14;

  int get deviceQRIdAlt => 0x13; //Mighty lite QR

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
  bool get presetSaveSupport => true;

  @override
  double get drumsBass => _config.drumsBass;
  @override
  double get drumsMiddle => _config.drumsMiddle;
  @override
  double get drumsTreble => _config.drumsTreble;

  @override
  double get drumsMaxTempo => 300;

  @override
  int get loopState => config.looperData.loopState;
  @override
  int get loopUndoState => config.looperData.loopUndoState;
  @override
  int get loopRecordMode => config.looperData.loopRecordMode;
  @override
  double get loopLevel => config.looperData.loopLevel;

  final looperController = StreamController<LooperData>.broadcast();

  @override
  List<ProcessorInfo> get processorList => ProcessorsList.liteMk2List;
  final _tunerController = StreamController<TunerData>.broadcast();

  int? _drumStylesCount;

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
  Widget getSettingsWidget() {
    return PlugProSettings(device: this, mightySpace: false);
  }

  @override
  bool checkQRValid(int deviceId, int ver) {
    if (deviceId != deviceQRId && deviceId != deviceQRIdAlt) return false;
    return ver == 1;
  }

  @override
  MightyMk2Preset getCustomPreset(int channel) {
    var preset =
        MightyMk2Preset(device: this, channel: channel, channelName: "");
    preset.setFirmwareVersion(productVersion);
    return preset;
  }

  @override
  void setDrumsTone(double value, DrumsToneControl control, bool send) {
    switch (control) {
      case DrumsToneControl.bass:
        _config.drumsBass = value;
        break;
      case DrumsToneControl.middle:
        _config.drumsMiddle = value;
        break;
      case DrumsToneControl.treble:
        _config.drumsTreble = value;
        break;
    }
    if (send) _communication.setDrumsTone(value, control);
  }

  @override
  bool get tunerAvailable {
    return deviceControl.isConnected;
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
    _config.tunerData.mode = mode;
    _communication.tunerSetSettings();
    notifyTunerListeners();
  }

  @override
  void tunerSetReferencePitch(int refPitch) {
    _config.tunerData.referencePitch = refPitch;
    _communication.tunerSetSettings();
    notifyTunerListeners();
  }

  @override
  void tunerMute(bool enable) {
    _config.tunerData.muted = enable;
    _communication.tunerSetSettings();
    notifyTunerListeners();
  }

  @override
  Stream<TunerData> getTunerDataStream() {
    return _tunerController.stream;
  }

  @override
  void notifyTunerListeners() {
    _tunerController.add(_config.tunerData);
  }

  @override
  int get tunerNoteCC => MidiCCValuesPro.TunerLiteMK2_Note;

  @override
  int get tunerPitchCC => MidiCCValuesPro.TunerLiteMK2_Cent;

  @override
  int get tunerStateCC => MidiCCValuesPro.TunerLiteMK2_State;

  @override
  int get tunerStringCC => MidiCCValuesPro.TunerLiteMK2_Number;

  @override
  void setUsbMode(int mode) {
    _config.routingMode = mode;
    communication.setUsbAudioMode(mode);
  }

  @override
  void setUsbRecordingVol(int vol) {
    _config.recLevel = vol;
    communication.setUsbInputVolume(vol);
  }

  @override
  void setUsbPlaybackVol(int vol) {
    _config.playbackLevel = vol;
    communication.setUsbOutputVolume(vol);
  }

  @override
  void setUsbDryWetVol(int vol) {
    _config.usbDryWet = vol;
    _communication.setUsbDryWet(vol);
  }

  @override
  Stream<LooperData> getLooperDataStream() {
    return looperController.stream;
  }

  void notifyLooperListeners() {
    looperController.add(config.looperData);
  }

  @override
  void looperClear() {
    _communication.looperClear();
  }

  @override
  void looperRecordPlay() {
    _communication.looperRecord();
  }

  @override
  void looperStop() {
    _communication.looperStop();
  }

  @override
  void looperUndoRedo() {
    _communication.looperUndoRedo();
  }

  @override
  void looperLevel(int vol) {
    config.looperData.loopLevel = vol.toDouble();
    _communication.looperVolume(vol);
  }

  @override
  void looperNrAr(bool auto) {
    config.looperData.loopRecordMode = auto ? 1 : 0;
    _communication.looperNrAr(auto);
  }

  @override
  void requestLooperSettings() {
    _communication.requestLooperSettings();
  }
}
