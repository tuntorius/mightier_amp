// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/communication.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:qr_utils/qr_utils.dart';

import '../NuxDeviceControl.dart';
import "NuxConstants.dart";
import 'effects/Processor.dart';
import 'presets/Preset.dart';

class NuxDeviceConfiguration {
  bool ecoMode = false;
}

abstract class NuxDevice extends ChangeNotifier {
  final NuxDeviceControl deviceControl;

  int get productVID {
    throw ("Not implemented exception");
  }

  int get vendorID {
    return 8721;
  }

  DeviceCommunication get communication;

  @protected
  NuxDeviceConfiguration get config;

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
  bool get activeChannelRetrieval;
  bool get fakeMasterVolume;
  bool get longChannelNames;
  bool get cabinetSupport;
  bool get hackableIRs;
  int get cabinetSlotIndex;
  bool get presetSaveSupport;
  bool get reorderableFXChain;
  bool get advancedSettingsSupport;
  bool get batterySupport;

  int get deviceQRId;
  int get deviceQRVersion;
  int get channelChangeCC;

  List<String> groupsName = <String>[];
  String channelName(int channel);

  //notifiers for bluetooth control
  final ValueNotifier<int> presetChangedNotifier = ValueNotifier<int>(0);

  //Notifies when an effect is switched on and off
  final StreamController<int> effectSwitched = StreamController<int>();

  //Notifies when an effect in a certain slot is changed
  final StreamController<int> effectChanged = StreamController<int>();

  //Notifies when an effect in a certain slot is changed
  final StreamController<int> slotSwapped = StreamController<int>();

  //Notifies when an effect parameter has changed
  final StreamController<Parameter> parameterChanged =
      StreamController<Parameter>();

  List<Preset> presets = <Preset>[];

  bool nuxPresetsReceived = false;

  @protected
  int selectedChannelP = 0; //nux-based channel index

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

  ProcessorInfo? GetProcessorInfoByKey(String key) {
    for (var proc in processorList) if (proc.keyName == key) return proc;
    return null;
  }

  ProcessorInfo? ProcessorListNuxIndex(int index) {
    return processorList[index];
  }

  set selectedChannelNormalized(int chan) {
    selectedChannelP = chan;
    presetChangedNotifier.value = selectedChannelP;
    if (deviceControl.isConnected) sendAmpLevel();
  }

  void setSelectedChannelNuxIndex(int chan, bool notify) {
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

  bool get ecoMode => config.ecoMode;

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
    nuxPresetsReceived = false;

    //reset nux data
    for (int i = 0; i < presets.length; i++) presets[i].resetNuxData();
    resetDrumSettings();
  }

  void onDisconnect() {
    communication.onDisconnect();
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
    communication.sendDrumsEnabled(_drumsEnabled);
  }

  void setDrumsStyle(int style) {
    _selectedDrumStyle = style;
    communication.sendDrumsStyle(style);
  }

  void setDrumsLevel(double level) {
    _drumsVolume = level;
    communication.sendDrumsLevel(level);
  }

  void setDrumsTempo(double tempo) {
    _drumsTempo = tempo;
    communication.sendDrumsTempo(tempo);
  }

  void setEcoMode(bool enabled) {
    config.ecoMode = enabled;
    communication.setEcoMode(enabled);
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

  void onPresetsReady() {
    if (!activeChannelRetrieval) {
      deviceControl.changeDevicePreset(0);
      setSelectedChannelNuxIndex(0, true);
    }
    nuxPresetsReceived = true;
  }

  void _handleChannelChange(int index) {
    NuxDeviceControl.instance().clearUndoStack();
    var _index = index;

    //channel skipping
    while (_activeChannels[_index] == false) {
      _index++;
      if (_index == channelsCount) _index = 0;
    }
    if (_index == index) //not skipped
      setSelectedChannelNuxIndex(index, true);
    else {
      //skipped - update ui
      selectedChannelNormalized = _index;
      deviceControl.presetChangedListener();
    }
    //immediately set the amp level
    sendAmpLevel();
  }

  void _handleKnobReceiveData(List<int> data) {
    //scan through the effects to find which one is controlled
    var _preset = getPreset(selectedChannel);
    for (int i = 0; i < effectsChainLength; i++) {
      var selected = _preset.getSelectedEffectForSlot(i);
      var effect = _preset.getEffectsForSlot(i)[selected];
      for (var param in effect.parameters) {
        if (param.midiCC == data[1]) {
          //this is the one to change
          param.midiValue = data[2];
          notifyListeners();
          return;
        }
      }
    }
  }

  void onDataReceived(List<int> data) {
    if (data.length < 2) return;

    switch (data[0] & 0xf0) {
      case MidiMessageValues.sysExStart:
        switch (data[1]) {
          case DeviceMessageID.devReqMIDIParaMsgID:
            switch (data[7]) {
              case DeviceMessageID.devSysCtrlMsgID:
                switch (data[8]) {
                  case SysCtrlState.syscmd_dsprun_battery:
                    //Is this MP-2 Only?
                    deviceControl.onBatteryPercentage(data[9]);
                    break;
                }
                break;
            }
            break;
        }
        break;
      case MidiMessageValues.programChange:
        _handleChannelChange(data[1]);
        break;
      case MidiMessageValues.controlChange:
        if (data[1] == channelChangeCC)
          _handleChannelChange(data[2]);
        else if (data[1] == MidiCCValues.bCC_drumOnOff_No) {
          _drumsEnabled = data[2] > 0 ? true : false;
          deviceControl.forceNotifyListeners();
          return;
        } else if (data[1] == MidiCCValues.bCC_drumType_No) {
          _selectedDrumStyle = data[2];
          deviceControl.forceNotifyListeners();
        } else
          _handleKnobReceiveData(data);
        break;
    }
  }

  void saveNuxPreset() {
    deviceControl.saveNuxPreset();
  }

  void resetNuxPresets() {
    nuxPresetsReceived = false;
    deviceControl.resetNuxPresets();
  }

  bool isPresetSupported(dynamic _preset) {
    String productId = _preset["product_id"];
    return productStringId == productId;
  }

  Widget getSettingsWidget() {
    return SizedBox.shrink();
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

  bool checkQRVersionValid(int ver);

  Preset? presetFromJson(dynamic _preset, double? overrideLevel,
      {bool qrOnly = false}) {
    var pVersion = _preset["version"] ?? 0;

    presetName = _preset["name"];
    presetCategory = _preset["category"];
    var nuxChannel = _preset["channel"];

    if (!qrOnly) {
      setSelectedChannelNuxIndex(nuxChannel, false);
      deviceControl.changeDevicePreset(nuxChannel);
    }

    Preset p;

    if (!qrOnly)
      p = getPreset(selectedChannel);
    else
      p = getCustomPreset(nuxChannel);

    int index = 0;

    if (reorderableFXChain) {
      for (String key in _preset.keys) {
        var pInfo = GetProcessorInfoByKey(key);
        if (pInfo != null) {
          p.setProcessorAtSlot(index, pInfo.nuxOrderIndex);
          index++;
        }
      }
      if (!qrOnly) communication.sendSlotOrder();
    }

    index = 0;

    for (String key in _preset.keys) {
      var pInfo = GetProcessorInfoByKey(key);
      if (pInfo != null) {
        //get effect
        Map<String, dynamic> _effect = _preset[key];

        int fxType = _effect["fx_type"];
        bool enabled = _effect["enabled"];

        //check if preset conversion is needed
        if (pVersion != productVersion) {
          //temporarily switch the preset to the other version
          //to get equivalent from this one
          p.setFirmwareVersion(pVersion);
          //2 things - either switch the version or convert the preset
          int? newfxType = p
              .getEffectsForSlot(index)[fxType]
              .getEquivalentEffect(productVersion);

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

        p.setSelectedEffectForSlot(index, fxType, false);

        p.setSlotEnabled(index, enabled, false);

        Processor fx;
        fx = p.getEffectsForSlot(index)[p.getSelectedEffectForSlot(index)];

        for (int f = 0; f < fx.parameters.length; f++) {
          //this is only for cabs override level
          if (overrideLevel != null &&
              cabinetSupport &&
              index == cabinetSlotIndex &&
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

        if (!qrOnly) deviceControl.sendFullEffectSettings(index, false);

        index++;
      }
    }

    /*
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
    */

    //update widgets
    if (!qrOnly)
      notifyListeners();
    else
      return p;

    return null;
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

      var proc = p.getProcessorAtSlot(i);
      var effect = ProcessorListNuxIndex(proc);
      mainJson[effect!.keyName] = dev;
    }
    return mainJson;
  }
}
