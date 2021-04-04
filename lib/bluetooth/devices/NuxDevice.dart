// (c) 2020-2021 Dian Iliev (Tuntorius)
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

//General device parameters
  String get productName;
  String get productNameShort;
  IconData get productIcon;
  String get productStringId;
  List<String> get productBLENames;

  int get channelsCount;
  int get effectsChainLength;
  List<ProcessorInfo> get processorList;
  int get amplifierSlotIndex;
  bool get cabinetSupport;
  int get cabinetSlotIndex;
  bool get presetSaveSupport;
  bool get advancedSettingsSupport;
  bool get batterySupport;

  int get channelChangeCC;

  int get groupsCount;
  List<String> groupsName = <String>[];
  String channelName(int channel);

  //notifiers for bluetooth control
  final ValueNotifier<int> presetChangedNotifier = ValueNotifier<int>(0);

  //Notifies when an effect is switched on and off
  final StreamController<int> effectSwitched = StreamController<int>();

  //Notifies when an effect in a certain slot is changed
  final StreamController<int> effectChanged = StreamController<int>();

  //Notifies when an effect parameter has changed
  final StreamController<Parameter> parameterChanged =
      StreamController<Parameter>();

  NuxDevice(this.deviceControl);

  List<Preset> presets = <Preset>[];

  bool _nuxPresetsReceived = false;
  bool get nuxPresetsReceived => _nuxPresetsReceived;

  @protected
  int selectedGroupP = 0;

  @protected
  int selectedChannelP = 0; //nux-based (0-6) channel index

  int get selectedGroup => selectedGroupP;
  int get selectedChannel => selectedChannelP;

  //normalized functions are to get zero-based channel from each group index
  int get selectedChannelNormalized;

  void setChannelFromGroup(int instr);
  void setGroupFromChannel(int chan);

  set selectedGroup(int instr) {
    if (instr != selectedGroupP) {
      setChannelFromGroup(instr);

      presetChangedNotifier.value = selectedChannelP;

      selectedGroupP = instr;
    }
  }

  set selectedChannelNormalized(int chan) {
    presetChangedNotifier.value = selectedChannelP;
    sendAmpLevel();
  }

  void _setSelectedChannelNuxIndex(int chan, bool notify) {
    selectedChannelP = chan;

    setGroupFromChannel(chan);

    //notify ui for change
    if (notify) {
      resetToNuxPreset();
      notifyListeners();
    }
  }

  //UI Stuff
  int selectedEffect = 0;

  //TODO: these should not be here
  String presetName = "";
  String presetCategory = "";

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
  double _drumsVolume = 50;
  double _drumsTempo = 120;

  bool get drumsEnabled => _drumsEnabled;
  int get selectedDrumStyle => _selectedDrumStyle;
  double get drumsVolume => _drumsVolume;
  double get drumsTempo => _drumsTempo;

  void onConnect() {
    _nuxPresetsReceived = false;
    resetDrumSettings();
  }

  void onDisconnect() {
    deviceControl.onBatteryPercentage(0);
  }

  List<String> getDrumStyles();

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

  void setDrumsLevel(double level) {
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

  //used for master volume control
  void sendAmpLevel() {
    //amps are at slot 1
    var preset = getPreset(selectedChannel);
    var amp = preset.getEffectsForSlot(
        amplifierSlotIndex)[preset.getSelectedEffectForSlot(2)];
    for (int i = 0; i < amp.parameters.length; i++) {
      if (amp.parameters[i].masterVolume) {
        deviceControl.sendParameter(amp.parameters[i], false);
      }
    }
  }

  Preset getPreset(int index) {
    return presets[index];
  }

  String getAmpNameByIndex(int index) {
    return presets[0].amplifierList[index].name;
  }

  List<Preset> getGroupPresets(int instr);

  void resetToNuxPreset() {
    getPreset(selectedChannel).setupPresetFromNuxData();
  }

  void onDataReceived(List<int> data) {
    assert(data.length > 0);

    switch (data[0]) {
      case MidiMessageValues.sysExStart:
        switch (data[1]) {
          case DeviceMessageID.devGetPresetMsgID: //preset data piece

            var total = (data[3] & 0xf0) >> 4;
            var current = data[3] & 0x0f;

            var preset = getPreset(data[2]);
            if (current == 0) preset.resetNuxData();

            preset.addNuxPayloadPiece(data.sublist(4, 16));

            if (current == total - 1) {
              preset.setupPresetFromNuxData();

              if (!_nuxPresetsReceived) {
                if (data[2] < channelsCount - 1)
                  deviceControl.requestPreset(data[2] + 1);
                else {
                  deviceControl.changeDevicePreset(0);
                  _setSelectedChannelNuxIndex(0, true);
                  notifyListeners();
                  _nuxPresetsReceived = true;

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
                    deviceControl.onBatteryPercentage(data[9]);
                    break;
                  case SysCtrlState.syscmd_usbaudio:
                    _usbMode = data[9];
                    _inputVol = data[10];
                    _outputVol = data[11];
                    deviceControl.deviceConnectionReady();
                    notifyListeners();
                    break;
                }
                break;
            }
            break;
        }
        break;
      case MidiMessageValues.controlChange:
        if (data[1] == channelChangeCC) {
          _setSelectedChannelNuxIndex(data[2], true);
          //immediately set the amp level
          sendAmpLevel();
        }
        //TODO: add knob manipulations here
        break;
    }
  }

  void saveNuxPreset() {
    deviceControl.saveNuxPreset();
  }

  void resetNuxPresets() {
    _nuxPresetsReceived = false;
    deviceControl.resetNuxPresets();
  }

  bool isPresetSupported(dynamic _preset) {
    String productId = _preset["product_id"];
    return productStringId == productId;
  }

  presetFromJson(dynamic _preset, double? overrideLevel) {
    presetName = _preset["name"];
    presetCategory = _preset["category"];
    var nuxChannel = _preset["channel"];

    _setSelectedChannelNuxIndex(nuxChannel, false);
    deviceControl.changeDevicePreset(nuxChannel);

    Preset p = getPreset(selectedChannel);

    //setup all effects
    for (int i = 0; i < effectsChainLength; i++) {
      if (!_preset.containsKey(processorList[i].keyName)) continue;
      //get effect
      Map<String, dynamic> _effect = _preset[processorList[i].keyName];

      int fxType = _effect["fx_type"];
      p.setSelectedEffectForSlot(i, fxType, false);

      bool enabled = _effect["enabled"];
      p.setSlotEnabled(i, enabled, false);

      Processor fx;
      fx = p.getEffectsForSlot(i)[p.getSelectedEffectForSlot(i)];

      for (int f = 0; f < fx.parameters.length; f++) {
        if (overrideLevel != null &&
            cabinetSupport &&
            i == cabinetSlotIndex &&
            fx.parameters[f].handle == "level")
          fx.parameters[f].value = overrideLevel;
        else
          fx.parameters[f].value = _effect[fx.parameters[f].handle];
      }

      deviceControl.sendFullEffectSettings(i, false);
    }
    //update widgets
    notifyListeners();
  }

  Map<String, dynamic> presetToJson() {
    Map<String, dynamic> mainJson = {
      "channel": selectedChannel,
      "product_id": productStringId
    };

    Preset p = getPreset(selectedChannel);

    //parse all effects
    for (int i = 0; i < effectsChainLength; i++) {
      var dev = Map<String, dynamic>();
      dev["fx_type"] = p.getSelectedEffectForSlot(i);
      dev["enabled"] = p.slotEnabled(i);
      Processor fx;

      fx = p.getEffectsForSlot(i)[p.getSelectedEffectForSlot(i)];

      for (int f = 0; f < fx.parameters.length; f++) {
        dev[fx.parameters[f].handle] = fx.parameters[f].value;
      }

      mainJson[processorList[i].keyName] = dev;
    }
    return mainJson;
  }
}
