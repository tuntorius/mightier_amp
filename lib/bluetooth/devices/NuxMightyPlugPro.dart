// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../UI/pages/device_specific_settings/PlugProSettings.dart';
import 'communication/communication.dart';
import 'communication/plugProCommunication.dart';
import '../../UI/mightierIcons.dart';

import '../NuxDeviceControl.dart';
import 'NuxConstants.dart';
import 'NuxDevice.dart';
import 'effects/Processor.dart';
import 'effects/plug_pro/EQ.dart';
import 'presets/PlugProPreset.dart';
import 'presets/Preset.dart';

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
}

class NuxMightyPlugPro extends NuxDevice {
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

  @override
  String get productName => "NUX Mighty Plug Pro";
  @override
  String get productNameShort => "Mighty Plug Pro";
  @override
  String get productStringId => "mighty_plug_pro";
  @override
  int get productVersion => version.index;
  @override
  IconData get productIcon => MightierIcons.amp_plugair;
  @override
  List<String> get productBLENames => ["MIGHTY PLUG PRO"];

  @override
  int get channelsCount => 7;
  @override
  int get effectsChainLength => 9;
  int get groupsCount => 1;
  @override
  int get amplifierSlotIndex {
    var preset = getPreset(selectedChannel);
    for (int i = 0; i < processorList.length; i++) {
      if (preset.getProcessorAtSlot(i) == PresetDataIndexPlugPro.Head_iAMP) {
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
      if (preset.getProcessorAtSlot(i) == PresetDataIndexPlugPro.Head_iCAB) {
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
  int get channelChangeCC => MidiCCValues.bCC_CtrlType;

  @override
  int get deviceQRId => 15;
  @override
  int get deviceQRVersion => 1;

  double get drumsBass => config.drumsBass;
  double get drumsMiddle => config.drumsMiddle;
  double get drumsTreble => config.drumsTreble;

  @override
  List<ProcessorInfo> get processorList => _processorList;

  @override
  ProcessorInfo? processorListNuxIndex(int index) {
    for (var proc in _processorList) {
      if (proc.nuxOrderIndex == index) return proc;
    }
    return null;
  }

  final List<ProcessorInfo> _processorList = [
    /*ProcessorInfo(
        shortName: "WAH",
        longName: "wah",
        keyName: "wah",
        nuxOrderIndex: 0,
        color: Colors.green,
        icon: Icons.water),*/
    ProcessorInfo(
        shortName: "COMP",
        longName: "Comp",
        keyName: "comp",
        nuxOrderIndex: PresetDataIndexPlugPro.Head_iCMP,
        color: Colors.lime,
        icon: Icons.stacked_line_chart),
    ProcessorInfo(
        shortName: "EFX",
        longName: "EFX",
        keyName: "efx",
        nuxOrderIndex: PresetDataIndexPlugPro.Head_iEFX,
        color: Colors.orange,
        icon: MightierIcons.pedal),
    ProcessorInfo(
        shortName: "AMP",
        longName: "Amplifier",
        keyName: "amp",
        nuxOrderIndex: PresetDataIndexPlugPro.Head_iAMP,
        color: Colors.red,
        icon: MightierIcons.amp),
    ProcessorInfo(
        shortName: "EQ",
        longName: "EQ",
        keyName: "eq",
        nuxOrderIndex: PresetDataIndexPlugPro.Head_iEQ,
        color: Colors.grey[300]!,
        icon: MightierIcons.sliders),
    ProcessorInfo(
        shortName: "GATE",
        longName: "Noise Gate",
        keyName: "gate",
        nuxOrderIndex: PresetDataIndexPlugPro.Head_iNG,
        color: Colors.green,
        icon: MightierIcons.gate),
    ProcessorInfo(
        shortName: "MOD",
        longName: "Modulation",
        keyName: "mod",
        nuxOrderIndex: PresetDataIndexPlugPro.Head_iMOD,
        color: Colors.indigo[400]!,
        icon: Icons.waves),
    ProcessorInfo(
        shortName: "DLY",
        longName: "Delay",
        keyName: "delay",
        nuxOrderIndex: PresetDataIndexPlugPro.Head_iDLY,
        color: Colors.cyan,
        icon: Icons.blur_linear),
    ProcessorInfo(
        shortName: "RVB",
        longName: "Reverb",
        keyName: "reverb",
        nuxOrderIndex: PresetDataIndexPlugPro.Head_iRVB,
        color: Colors.deepPurple,
        icon: Icons.blur_on),
    ProcessorInfo(
        shortName: "IR",
        longName: "Cabinet",
        keyName: "cabinet",
        nuxOrderIndex: PresetDataIndexPlugPro.Head_iCAB,
        color: Colors.lightBlue,
        icon: MightierIcons.cabinet),
  ];

  List<String> channelNames = [];

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
    //get channel names
    for (var element in PlugProChannel.values) {
      channelNames.add(element.toString().split('.')[1]);
    }

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
    }
  }

  @override
  dynamic getDrumStyles() => drumCategories;

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
  bool checkQRVersionValid(int ver) {
    return ver == 1;
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
}
