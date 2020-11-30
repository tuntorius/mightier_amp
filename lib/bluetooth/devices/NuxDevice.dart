// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../NuxDeviceControl.dart';
import "NuxConstants.dart";
import 'effects/Processor.dart';
import 'presets/Preset.dart';

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

  Instrument _selectedInstrument = Instrument.Guitar;
  int _selectedChannel = 0; //nux-based (0-6) channel index

  Instrument get selectedInstrument => _selectedInstrument;
  String presetName;
  String presetCategory;

  //drum stuff
  bool _drumsEnabled = false;
  int _selectedDrumStyle = 0;
  int _drumsVolume = 50;
  double _drumsTempo = 120;

  bool get drumsEnabled => _drumsEnabled;
  int get selectedDrumStyle => _selectedDrumStyle;
  int get drumsVolume => _drumsVolume;
  double get drumsTempo => _drumsTempo;

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

              if (data[2] < 6)
                deviceControl.getPreset(data[2] + 1);
              else {
                deviceControl.changeDevicePreset(0);
                _setSelectedChannelNuxIndex(0, true);
                notifyListeners();
              }
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
