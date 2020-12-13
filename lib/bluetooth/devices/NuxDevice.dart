// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../NuxDeviceControl.dart';
import "NuxConstants.dart";
import 'effects/Processor.dart';
import 'presets/Preset.dart';

enum DeviceConnectionState { connectedStart, presetsLoaded, configReceived }

abstract class NuxDevice extends ChangeNotifier {
  final NuxDeviceControl deviceControl;
  int get productVID {
    throw ("Not implemented exception");
  }

  int get vendorID {
    return 8721;
  }

  //notifiers for bluetooth control
  final ValueNotifier<int> presetChangedNotifier = ValueNotifier<int>(0);
  final StreamController<Parameter> parameterChanged =
      StreamController<Parameter>();
  final StreamController<int> effectSwitched = StreamController<int>();
  final StreamController<int> effectChanged = StreamController<int>();
  final StreamController<int> batteryPercentage = StreamController<int>();
  final StreamController<DeviceConnectionState> connectStatus =
      StreamController();

  NuxDevice(this.deviceControl);

  List<Preset> get guitarPresets;
  List<Preset> get bassPresets;

  static List<String> drumStyles = [
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

  bool _nuxPresetsReceived = false;
  bool get nuxPresetsReceived => _nuxPresetsReceived;

  Instrument _selectedInstrument = Instrument.Guitar;
  int _selectedChannel = 0; //nux-based (0-6) channel index

  Instrument get selectedInstrument => _selectedInstrument;
  String presetName;
  String presetCategory;

  //general settings
  bool _ecoMode = false;

  int _usbMode = 0;
  int _inputVol = 0;
  int _outputVol = 0;
  int _btEq = 0;

  bool get ecoMode => _ecoMode;
  int get usbMode => _usbMode;
  int get inputVol => _inputVol;
  int get outputVol => _outputVol;
  int get btEq => _btEq;

  //drum stuff
  bool _drumsEnabled = false;
  int _selectedDrumStyle = 0;
  int _drumsVolume = 50;
  double _drumsTempo = 120;

  bool get drumsEnabled => _drumsEnabled;
  int get selectedDrumStyle => _selectedDrumStyle;
  int get drumsVolume => _drumsVolume;
  double get drumsTempo => _drumsTempo;

  void onConnect() {
    _nuxPresetsReceived = false;
    resetDrumSettings();
    connectStatus.add(DeviceConnectionState.connectedStart);
  }

  void onDisconnect() {
    batteryPercentage.add(0);
  }

  void resetDrumSettings() {
    _drumsEnabled = false;
    _selectedDrumStyle = 0;
    _drumsVolume = 50;
    _drumsTempo = 120;
  }

  void setDrumsEnabled(bool _enabled) {
    _drumsEnabled = _enabled;
    deviceControl.sendDrumsEnabled(_drumsEnabled);
  }

  void setDrumsStyle(int style) {
    _selectedDrumStyle = style;
    deviceControl.sendDrumsStyle(style);
  }

  void setDrumsLevel(int level) {
    _drumsVolume = level;
    deviceControl.sendDrumsLevel(level);
  }

  void setDrumsTempo(double tempo) {
    _drumsTempo = tempo;
    deviceControl.sendDrumsTempo(tempo);
  }

  void setEcoMode(bool enabled) {
    _ecoMode = enabled;
    deviceControl.setEcoMode(enabled);
  }

  void setUsbMode(int mode) {
    _usbMode = mode;
    deviceControl.setUsbAudioMode(mode);
  }

  void setUsbInputVol(int vol) {
    _inputVol = vol;
    deviceControl.setUsbInputVolume(vol);
  }

  void setUsbOutputVol(int vol) {
    _outputVol = vol;
    deviceControl.setUsbOutputVolume(vol);
  }

  void setBtEq(int eq) {
    _btEq = eq;
    deviceControl.setBtEq(eq);
  }

  set selectedInstrument(Instrument instr) {
    if (instr != _selectedInstrument) {
      if (instr == Instrument.Guitar)
        _selectedChannel = 0;
      else {
        _selectedChannel = 4;
      }

      presetChangedNotifier.value = _selectedChannel;
    }

    _selectedInstrument = instr;
  }

  //normalized functions are to abstract the channel from the instrument index
  int get selectedChannelNormalized {
    if (_selectedInstrument == Instrument.Guitar) return _selectedChannel;
    return _selectedChannel - 4;
  }

  set selectedChannelNormalized(chan) {
    if (_selectedInstrument == Instrument.Guitar) {
      _selectedChannel = chan;
    } else
      _selectedChannel = chan + 4;

    presetChangedNotifier.value = _selectedChannel;
  }

  int get selectedChannelNuxIndex => _selectedChannel;

  void _setSelectedChannelNuxIndex(chan, bool notify) {
    _selectedChannel = chan;
    if (chan < 4)
      _selectedInstrument = Instrument.Guitar;
    else
      _selectedInstrument = Instrument.Bass;
    //notify ui for change
    if (notify) {
      resetToNuxPreset();
      notifyListeners();
    }
  }

  int selectedEffect = 0;

  Preset getPresetByNuxIndex(int index) {
    if (index < 4)
      //guitar presets
      return guitarPresets[index];
    else
      return bassPresets[index - 4];
  }

  List<Preset> getInstrumentPresets(Instrument instr) {
    switch (instr) {
      case Instrument.Guitar:
        return guitarPresets;
      case Instrument.Bass:
        return bassPresets;
    }
    return null;
  }

  void resetToNuxPreset() {
    getPresetByNuxIndex(selectedChannelNuxIndex).setupPresetFromNuxData();
  }

  void onDataReceived(List<int> data) {
    assert(data != null && data.length > 0);

    switch (data[0]) {
      case MidiMessageValues.sysExStart:
        switch (data[1]) {
          case DeviceMessageID.devGetPresetMsgID: //preset data piece

            var total = (data[3] & 0xf0) >> 4;
            var current = data[3] & 0x0f;

            var preset = getPresetByNuxIndex(data[2]);
            if (current == 0) preset.resetNuxData();

            preset.addNuxPayloadPiece(data);

            if (current == total - 1) {
              preset.setupPresetFromNuxData();

              if (!_nuxPresetsReceived) {
                if (data[2] < 6)
                  deviceControl.getPreset(data[2] + 1);
                else {
                  deviceControl.changeDevicePreset(0);
                  _setSelectedChannelNuxIndex(0, true);
                  notifyListeners();
                  _nuxPresetsReceived = true;

                  connectStatus.add(DeviceConnectionState.presetsLoaded);
                  deviceControl.onPresetsReady();
                }
              }
            }
            break;
          case DeviceMessageID.devGetManuMsgID:
            //this has lots of unknown values - maybe bpm settings
            //eco mode is 12
            if (data[data.length - 1] == MidiMessageValues.sysExEnd) {
              _btEq = data[10];
              _ecoMode = data[12] != 0;
              notifyListeners();
            }
            break;
          case 0:
            switch (data[7]) {
              case DeviceMessageID.devSysCtrlMsgID:
                switch (data[8]) {
                  case SysCtrlState.syscmd_dsprun_battery:
                    batteryPercentage.add(data[9]);
                    break;
                  case SysCtrlState.syscmd_usbaudio:
                    _usbMode = data[9];
                    _inputVol = data[10];
                    _outputVol = data[11];
                    connectStatus.add(DeviceConnectionState.configReceived);
                    notifyListeners();
                    break;
                }
                break;
            }
            break;
        }
        break;
      case MidiMessageValues.controlChange:
        switch (data[1]) {
          case MidiCCValues.bCC_CtrlType: //preset changed
            _setSelectedChannelNuxIndex(data[2], true);
        }
        break;
    }
  }

  void saveNuxPreset() {
    deviceControl.saveNuxPreset();
  }

  void resetNuxPresets() {
    deviceControl.resetNuxPresets();
  }

  presetFromJson(dynamic _preset) {
    presetName = _preset["name"];
    presetCategory = _preset["category"];

    //set instrument channel
    selectedInstrument = Instrument.values[_preset["instrument"]];
    var nuxChannel =
        Preset.nuxChannel(selectedInstrument.index, _preset["channel"]);

    _setSelectedChannelNuxIndex(nuxChannel, false);
    deviceControl.changeDevicePreset(nuxChannel);

    Preset p = getPresetByNuxIndex(selectedChannelNuxIndex);

    //setup all effects
    for (int i = 0; i < 7; i++) {
      if (!_preset.containsKey(Processor.processorList[i].keyName)) continue;
      //get effect
      Map<String, dynamic> _effect =
          _preset[Processor.processorList[i].keyName];

      int fxType = _effect["fx_type"];
      p.setSelectedEffectForSlot(i, fxType, false);

      bool enabled = _effect["enabled"];
      p.setSlotEnabled(i, enabled, false);

      Processor fx;
      if (i != 3)
        fx = p.getEffectsForSlot(i)[p.getSelectedEffectForSlot(i)];
      else
        fx = p.getEffectsForSlot(i)[0];

      for (int f = 0; f < fx.parameters.length; f++)
        fx.parameters[f].value = _effect[fx.parameters[f].handle];

      deviceControl.sendFullEffectSettings(i);
    }
    //update widgets
    notifyListeners();
  }

  Map<String, dynamic> presetToJson() {
    Map<String, dynamic> mainJson = {
      "instrument": selectedInstrument.index,
      "channel": selectedChannelNormalized
    };

    Preset p = getPresetByNuxIndex(selectedChannelNuxIndex);

    //parse all effects
    for (int i = 0; i < 7; i++) {
      var dev = Map<String, dynamic>();
      dev["fx_type"] = p.getSelectedEffectForSlot(i);
      dev["enabled"] = p.slotEnabled(i);
      Processor fx;

      fx = p.getEffectsForSlot(i)[p.getSelectedEffectForSlot(i)];

      for (int f = 0; f < fx.parameters.length; f++) {
        dev[fx.parameters[f].handle] = fx.parameters[f].value;
      }

      mainJson[Processor.processorList[i].keyName] = dev;
    }
    return mainJson;
  }
}

class NuxMightyPlug extends NuxDevice {
  int get productVID => 48;

  List<Preset> presets = List<Preset>();
  List<Preset> guitarPresets = List<Preset>();
  List<Preset> bassPresets = List<Preset>();

  NuxMightyPlug(NuxDeviceControl devControl) : super(devControl) {
    //clean
    guitarPresets.add(Preset(
        device: this,
        instrument: Instrument.Guitar,
        channel: Channel.Clean,
        channelName: "Clean"));

    //OD
    guitarPresets.add(Preset(
        device: this,
        instrument: Instrument.Guitar,
        channel: Channel.Overdive,
        channelName: "Drive"));

    //Dist
    guitarPresets.add(Preset(
        device: this,
        instrument: Instrument.Guitar,
        channel: Channel.Distortion,
        channelName: "Dist"));

    //AGSim
    guitarPresets.add(Preset(
        device: this,
        instrument: Instrument.Guitar,
        channel: Channel.AGSim,
        channelName: "AGSim"));

    //Pop Bass
    bassPresets.add(Preset(
        device: this,
        instrument: Instrument.Bass,
        channel: Channel.Pop,
        channelName: "Pop"));

    //Rock Bass
    bassPresets.add(Preset(
        device: this,
        instrument: Instrument.Bass,
        channel: Channel.Rock,
        channelName: "Rock"));

    //Funk Bass
    bassPresets.add(Preset(
        device: this,
        instrument: Instrument.Bass,
        channel: Channel.Funk,
        channelName: "Funk"));

    presets.addAll(guitarPresets);
    presets.addAll(bassPresets);
  }
}
