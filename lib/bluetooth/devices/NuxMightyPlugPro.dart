// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/material.dart';
import '../../UI/pages/device_specific_settings/PlugProSettings.dart';
import 'NuxFXID.dart';
import 'communication/communication.dart';
import 'communication/plugProCommunication.dart';
import '../../UI/mightierIcons.dart';

import '../NuxDeviceControl.dart';
import 'NuxConstants.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';
import 'effects/plug_pro/EQ.dart';
import 'features/looper.dart';
import 'features/tuner.dart';
import 'presets/PlugProPreset.dart';
import 'presets/Preset.dart';
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

class NuxMightyPlugPro extends NuxDevice implements Tuner, Looper {
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
  String get productName => "NUX Mighty Plug Pro/Mighty Space";
  @override
  String get productNameShort => "Mighty Plug Pro/Space";
  @override
  String get productStringId => "mighty_plug_pro";
  @override
  int get productVersion => version.index;
  @override
  String get productIconLabel => "MP-3|-|SPACE";
  @override
  List<String> get productBLENames => ["MIGHTY PLUG PRO", "MIGHTY SPACE"];

  @override
  int get channelsCount => 7;
  @override
  int get effectsChainLength => enableWahExperimental ? 10 : 9;
  int get groupsCount => 1;
  @override
  int get amplifierSlotIndex {
    var preset = getPreset(selectedChannel);
    for (int i = 0; i < processorList.length; i++) {
      if (preset.getFXIDFromSlot(i) == PlugProFXID.amp) {
        return i;
      }
    }

    return PresetDataIndexPlugPro.Head_iAMP;
  }

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
  int get cabinetSlotIndex {
    var preset = getPreset(selectedChannel);
    for (int i = 0; i < processorList.length; i++) {
      if (preset.getFXIDFromSlot(i) == PlugProFXID.cab) {
        return i;
      }
    }

    return PresetDataIndexPlugPro.Head_iCAB;
  }

  @override
  bool get presetSaveSupport => true;
  @override
  bool get reorderableFXChain => true;
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
  double get drumsMaxTempo => 300;

  @override
  int get loopState => config.looperData.loopState;
  @override
  int get loopUndoState => config.looperData.loopUndoState;
  @override
  int get loopRecordMode => config.looperData.loopRecordMode;
  @override
  double get loopLevel => config.looperData.loopLevel;

  @override
  List<ProcessorInfo> get processorList => _processorList;

  final tunerController = StreamController<TunerData>.broadcast();
  final looperController = StreamController<LooperData>.broadcast();

  @override
  ProcessorInfo? getProcessorInfoByFXID(NuxFXID fxid) {
    for (var proc in _processorList) {
      if (proc.nuxFXID == fxid) return proc;
    }
    return null;
  }

  @override
  int? getSlotByEffectKeyName(String key) {
    var pi = getProcessorInfoByKey(key);
    if (pi != null) {
      PlugProPreset p = getPreset(selectedChannel) as PlugProPreset;
      var index = p.getSlotFromFXID(pi.nuxFXID);
      if (index != null) return index;
    }
    return null;
  }

  final List<ProcessorInfo> _processorList = [
    if (enableWahExperimental)
      ProcessorInfo(
          shortName: "WAH",
          longName: "Wah",
          keyName: "wah",
          nuxFXID: PlugProFXID.wah,
          color: Colors.green,
          icon: Icons.water),
    ProcessorInfo(
        shortName: "COMP",
        longName: "Comp",
        keyName: "comp",
        nuxFXID: PlugProFXID.comp,
        color: Colors.lime,
        icon: MightierIcons.compressor),
    ProcessorInfo(
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        nuxFXID: PlugProFXID.efx,
        color: Colors.orange,
        icon: MightierIcons.pedal),
    ProcessorInfo(
        shortName: "AMP",
        longName: "Amplifier",
        keyName: "amp",
        nuxFXID: PlugProFXID.amp,
        color: Colors.red,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "EQ",
        longName: "EQ",
        keyName: "eq",
        nuxFXID: PlugProFXID.eq,
        color: Colors.grey[300]!,
        icon: MightierIcons.sliders),
    ProcessorInfo(
        shortName: "GATE",
        longName: "Noise Gate",
        keyName: "gate",
        nuxFXID: PlugProFXID.gate,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "MOD",
        longName: "Modulation",
        keyName: "mod",
        nuxFXID: PlugProFXID.mod,
        color: Colors.deepPurple[400]!,
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "DLY",
        longName: "Delay",
        keyName: "delay",
        nuxFXID: PlugProFXID.delay,
        color: Colors.cyan[300]!,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "RVB",
        longName: "Reverb",
        keyName: "reverb",
        nuxFXID: PlugProFXID.reverb,
        color: Colors.purple[200]!,
        icon: Icons.blur_on),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cab",
        keyName: "cabinet",
        nuxFXID: PlugProFXID.cab,
        color: Colors.lightBlue[400]!,
        icon: MightierIcons.cabinet),
  ];

  List<String> channelNames = [];

  int? _drumStylesCount;
  static const Map<String, int> rockStyles = {
    'Standard': 0,
    'Swing Rock': 1,
    'Power Beat': 2,
    'Smooth': 3,
    'Mega Drive': 4,
    'Hard Rock': 5,
    'Boogie': 6
  };

  static const Map<String, int> countryStyles = {
    'Walk Line': 7,
    'Blue Grass': 8,
    'Country': 9,
    'Waltz': 10,
    'Train': 11,
    'Country Rock': 12,
    'Slowly': 13
  };

  static const Map<String, int> bluesStyles = {
    'Slow Blues': 14,
    'Chicago': 15,
    'R&B': 16,
    'Blues Rock': 17,
    'Road Train': 18,
    'Shuffle': 19,
  };

  static const Map<String, int> metalStyles = {
    '2X Bass': 20,
    'Close Beat': 21,
    'Heavy Bass': 22,
    'Fast': 23,
    'Holy Case': 24,
    'Open Hat': 25,
    'Epic': 26,
  };

  static const Map<String, int> funkStyles = {
    'Bounce': 27,
    'East Coast': 28,
    'New Mann': 29,
    'R&B Funk': 30,
    '80s Funk': 31,
    'Soul': 32,
    'Uncle Jam': 33,
  };

  static const Map<String, int> jazzStyles = {
    'Blues Jazz': 34,
    'Classic 1': 35,
    'Classic 2': 36,
    'Easy Jazz': 37,
    'Fast': 38,
    'Walking': 39,
    'Smooth': 40,
  };

  static const Map<String, int> balladStyles = {
    'Bluesy': 41,
    'Grooves': 42,
    'Ballad Rock': 43,
    'Slow Rock': 44,
    'Tutorial': 45,
    'R&B Ballad': 46,
    'Gospel': 47,
  };

  static const Map<String, int> popStyles = {
    'Beach Side': 48,
    'Big City': 49,
    'Funky Pop': 50,
    'Modern': 51,
    'School Pop': 52,
    'Motown': 53,
    'Resistor': 54,
  };

  static const Map<String, int> reggaeStyles = {
    'Sheriff': 55,
    'Santeria': 56,
    'Reggae 3': 57,
    'Reggae 4': 58,
    'Reggae 5': 59,
    'Reggae 6': 60,
    'Reggae 7': 61,
  };

  static const Map<String, int> electronicStyles = {
    'Electronic 1': 62,
    'Electronic 2': 63,
    'Electronic 3': 64,
    'Elec-EDM': 65,
    'Elec-Tech': 66,
  };

  final Map<String, Map> drumCategories = {
    "Rock": rockStyles,
    "Country": countryStyles,
    "Blues": bluesStyles,
    "Metal": metalStyles,
    "Funk": funkStyles,
    "Jazz": jazzStyles,
    "Ballad": balladStyles,
    "Pop": popStyles,
    "Reggae": reggaeStyles,
    "Electronic": electronicStyles
  };

  NuxMightyPlugPro(NuxDeviceControl devControl) : super(devControl) {
    //clean
    presets.add(PlugProPreset(
        device: this, channel: PlugProChannel.Clean.index, channelName: "1"));

    //OD
    presets.add(PlugProPreset(
        device: this,
        channel: PlugProChannel.Overdrive.index,
        channelName: "2"));

    //Dist
    presets.add(PlugProPreset(
        device: this,
        channel: PlugProChannel.Distortion.index,
        channelName: "3"));

    //AGSim
    presets.add(PlugProPreset(
        device: this, channel: PlugProChannel.AGSim.index, channelName: "4"));

    //Pop Bass
    presets.add(PlugProPreset(
        device: this, channel: PlugProChannel.Pop.index, channelName: "5"));

    //Rock Bass
    presets.add(PlugProPreset(
        device: this, channel: PlugProChannel.Rock.index, channelName: "6"));

    //Funk Bass
    presets.add(PlugProPreset(
        device: this, channel: PlugProChannel.Funk.index, channelName: "7"));

    for (var preset in presets) {
      (preset as PlugProPreset).setFirmwareVersion(version.index);
      channelNames.add("Channel ${preset.channelName}");
    }
  }

  @override
  dynamic getDrumStyles() => drumCategories;

  @override
  int getDrumStylesCount() {
    if (_drumStylesCount == null) {
      _drumStylesCount = 0;
      for (var cat in drumCategories.values) {
        _drumStylesCount = _drumStylesCount! + cat.length;
      }
    }
    return _drumStylesCount!;
  }

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
    return PlugProSettings(device: this);
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

  void notifyTunerListeners() {
    tunerController.add(_config.tunerData);
  }

  @override
  Stream<LooperData> getLooperDataStream() {
    return looperController.stream;
  }

  void notifyLooperListeners() {
    looperController.add(_config.looperData);
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
    _communication.looperVolume(vol);
  }

  @override
  void looperNrAr(bool auto) {
    _config.looperData.loopRecordMode = auto ? 1 : 0;
    _communication.looperNrAr(auto);
  }

  @override
  void requestLooperSettings() {
    _communication.requestLooperSettings();
  }
}
