// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:qr_utils/qr_utils.dart';

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
  int get productVersion;
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

  int get deviceQRId;
  int get channelChangeCC;

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

  List<Preset> presets = <Preset>[];

  bool _nuxPresetsReceived = false;
  bool get nuxPresetsReceived => _nuxPresetsReceived;

  @protected
  int selectedChannelP = 0; //nux-based (0-6) channel index

  int get selectedChannel => selectedChannelP;
  late List<bool> _activeChannels;

  void setFirmwareVersion(int ver);

  void setFirmwareVersionByIndex(int ver);

  NuxDevice(this.deviceControl) {
    _activeChannels = List<bool>.filled(channelsCount, true);
  }

  int getAvailableVersions() {
    return 1;
  }

  String getProductNameVersion(int version) {
    return productNameShort;
  }

  set selectedChannelNormalized(int chan) {
    presetChangedNotifier.value = selectedChannelP;
    if (deviceControl.isConnected) sendAmpLevel();
  }

  void _setSelectedChannelNuxIndex(int chan, bool notify) {
    selectedChannelP = chan;

    //notify ui for change
    if (notify) {
      resetToNuxPreset();
      notifyListeners();
    }
  }

  bool getChannelActive(int channel) {
    return _activeChannels[channel];
  }

  void toggleChannelActive(int channel) {
    _activeChannels[channel] = !_activeChannels[channel];

    //check for at least one channel enabled
    bool hasEnabled = false;
    for (var act in _activeChannels) if (act == true) hasEnabled = true;
    if (!hasEnabled) {
      _activeChannels[channel] = true;
      return;
    }
    notifyListeners();
  }

  //UI Stuff
  int selectedSlot = 0;

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

    //reset nux data
    for (int i = 0; i < presets.length; i++) presets[i].resetNuxData();
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
    var amp = preset.getEffectsForSlot(amplifierSlotIndex)[
        preset.getSelectedEffectForSlot(amplifierSlotIndex)];
    for (int i = 0; i < amp.parameters.length; i++) {
      if (amp.parameters[i].masterVolume) {
        deviceControl.sendParameter(amp.parameters[i], false);
      }
    }
  }

  Preset getPreset(int index) {
    return presets[index];
  }

  //used for QR stuff, probably will be removed
  Preset getCustomPreset(int channel);

  String getAmpNameByIndex(int index) {
    return presets[0].amplifierList[index].name;
  }

  void renameCabinet(int cabIndex, String name) {
    if (cabinetSupport) {
      SharedPrefs().setCustomCabinetName(productStringId, cabIndex, name);
      notifyListeners();
    }
  }

  List<Preset> getPresetsList();

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
          NuxDeviceControl().clearUndoStack();
          var index = data[2];

          //impement channel skipping
          while (_activeChannels[index] == false) {
            index++;
            if (index == channelsCount) index = 0;
          }
          if (index == data[2]) //not skipped
            _setSelectedChannelNuxIndex(data[2], true);
          else {
            //skipped - update ui
            selectedChannelNormalized = index;
            deviceControl.presetChangedListener();
          }
          //immediately set the amp level
          sendAmpLevel();
        } else if (data[1] == MidiCCValues.bCC_drumOnOff_No) {
          _drumsEnabled = data[2] > 0 ? true : false;
          deviceControl.forceNotifyListeners();
          return;
        } else if (data[1] == MidiCCValues.bCC_drumType_No) {
          _selectedDrumStyle = data[2];
          deviceControl.forceNotifyListeners();
        } else {
          //scan through the effects to find which one is controlled
          for (int i = 0; i < effectsChainLength; i++) {
            var preset = presets[selectedChannel];
            var effects = preset.getEffectsForSlot(i);
            for (var effect in effects) {
              for (var param in effect.parameters) {
                if (param.midiCC == data[1]) {
                  //this is the one to change
                  if (param.valueType == ValueType.db)
                    param.value = deviceControl.sevenBitToDb(data[2]);
                  else
                    param.value = deviceControl.sevenBitToPercentage(data[2]);
                  notifyListeners();
                  return;
                }
              }
            }
          }
        }
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

  String? jsonToQR(dynamic _preset) {
    var preset = presetFromJson(_preset, null, qrOnly: true);
    if (preset != null) {
      var data = preset.createNuxDataFromPreset();
      return "${QrUtils.nuxQRPrefix}${base64Encode(data)}";
    }
    return null;
  }

  String channelToQR(int channel) {
    var data = presets[channel].createNuxDataFromPreset();
    return "${QrUtils.nuxQRPrefix}${base64Encode(data)}";
  }

  Preset? presetFromJson(dynamic _preset, double? overrideLevel,
      {bool qrOnly = false}) {
    var pVersion = _preset["version"] ?? 0;

    presetName = _preset["name"];
    presetCategory = _preset["category"];
    var nuxChannel = _preset["channel"];

    if (!qrOnly) {
      _setSelectedChannelNuxIndex(nuxChannel, false);
      deviceControl.changeDevicePreset(nuxChannel);
    }

    Preset p;

    if (!qrOnly)
      p = getPreset(selectedChannel);
    else
      p = getCustomPreset(nuxChannel);

    //setup all effects
    for (int i = 0; i < effectsChainLength; i++) {
      if (!_preset.containsKey(processorList[i].keyName)) continue;
      //get effect
      Map<String, dynamic> _effect = _preset[processorList[i].keyName];

      int fxType = _effect["fx_type"];
      bool enabled = _effect["enabled"];

      //check if preset conversion is needed
      if (pVersion != productVersion) {
        //temporarily switch the preset to the other version
        //to get equivalent from this one
        p.setFirmwareVersion(pVersion);
        //2 things - either switch the version or convert the preset
        int? newfxType =
            p.getEffectsForSlot(i)[fxType].getEquivalentEffect(productVersion);

        if (newfxType != null)
          fxType = newfxType;
        else {
          //if we don't know equivalent then disable it
          fxType = 0; //set to 0 to avoid null references
          enabled = false;
        }

        //revert the preset back
        p.setFirmwareVersion(productVersion);
      }

      p.setSelectedEffectForSlot(i, fxType, false);

      p.setSlotEnabled(i, enabled, false);

      Processor fx;
      fx = p.getEffectsForSlot(i)[p.getSelectedEffectForSlot(i)];

      for (int f = 0; f < fx.parameters.length; f++) {
        //this is only for cabs override level
        if (overrideLevel != null &&
            cabinetSupport &&
            i == cabinetSlotIndex &&
            fx.parameters[f].handle == "level")
          fx.parameters[f].value = overrideLevel;
        else {
          if (pVersion == productVersion)
            fx.parameters[f].value = _effect[fx.parameters[f].handle];
          else {
            //ask the effect for the proper handle
            var handle = fx.parameters[f].handle;
            if (_effect.containsKey(handle))
              fx.parameters[f].value = _effect[handle];
          }
        }
      }

      if (!qrOnly) deviceControl.sendFullEffectSettings(i, false);
    }
    //update widgets
    if (!qrOnly)
      notifyListeners();
    else
      return p;
  }

  Map<String, dynamic> presetToJson() {
    Map<String, dynamic> mainJson = {
      "channel": selectedChannel,
      "product_id": productStringId,
      "version": productVersion
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
