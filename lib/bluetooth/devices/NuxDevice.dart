// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/communication.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:qr_utils/qr_utils.dart';

import '../NuxDeviceControl.dart';
import '../bleMidiHandler.dart';
import "NuxConstants.dart";
import 'effects/Processor.dart';
import 'presets/Preset.dart';
import 'value_formatters/ValueFormatter.dart';

class NuxDeviceConfiguration {
  bool ecoMode = false;

  //drum settings
  bool drumsEnabled = false;
  int selectedDrumStyle = 0;
  double drumsVolume = 50;
  double drumsTempo = 120;

  late List<bool> activeChannels;
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
  String get productIconLabel;
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
  bool get batterySupport;
  bool get nativeActiveChannelsSupport;
  ValueFormatter? get decibelFormatter => null;

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

  void setFirmwareVersion(int ver);

  void setFirmwareVersionByIndex(int ver);

  NuxDevice(this.deviceControl) {
    config.activeChannels = List<bool>.filled(channelsCount, true);
  }

  int getAvailableVersions() {
    return 1;
  }

  String getProductNameVersion(int version) {
    return productNameShort;
  }

  ProcessorInfo? getProcessorInfoByKey(String key) {
    for (var proc in processorList) {
      if (proc.keyName == key) return proc;
    }
    return null;
  }

  int? getChainIndexByEffectKeyName(String key) {
    var pi = getProcessorInfoByKey(key);
    if (pi != null) {
      return pi.nuxOrderIndex;
    }
    return null;
  }

  ProcessorInfo? processorListNuxIndex(int index) {
    return processorList[index];
  }

  void setSelectedChannel(int chan,
      {required bool notifyBT,
      required bool sendFullPreset,
      required bool notifyUI}) {
    if (chan >= channelsCount) {
      debugPrint(
          "setSelectedChannel error: trying to set to invalid channel $chan");
      chan = 0;
    }

    selectedChannelP = chan;
    if (notifyBT) presetChangedNotifier.value = selectedChannelP;

    if (sendFullPreset) deviceControl.sendFullPresetSettings();
    if (notifyUI) notifyListeners();
    if (deviceControl.isConnected) sendAmpLevel();
  }

  bool getChannelActive(int channel) {
    return config.activeChannels[channel];
  }

  void toggleChannelActive(int channel) {
    config.activeChannels[channel] = !config.activeChannels[channel];

    //check for at least one channel enabled
    bool hasEnabled = false;
    for (var act in config.activeChannels) {
      if (act == true) hasEnabled = true;
    }
    if (!hasEnabled) {
      config.activeChannels[channel] = true;
      return;
    }

    if (nativeActiveChannelsSupport) {
      communication.sendActiveChannels(config.activeChannels);
    }
    notifyListeners();
  }

  //UI Stuff
  int selectedSlot = 0;

  String presetName = "";
  String presetCategory = "";
  String presetUUID = "";

  //general settings

  bool get ecoMode => config.ecoMode;

  //drum stuff
  double get drumsMinTempo => 40;
  double get drumsMaxTempo => 240;
  bool get drumsEnabled => config.drumsEnabled;
  int get selectedDrumStyle => config.selectedDrumStyle;
  double get drumsVolume => config.drumsVolume;
  double get drumsTempo => config.drumsTempo;

  void onConnect() {
    nuxPresetsReceived = false;

    clearPresetData();
    //reset nux data
    for (int i = 0; i < presets.length; i++) {
      presets[i].resetNuxData();
    }
    resetDrumSettings();
  }

  void clearPresetData() {
    presetName = "";
    presetCategory = "";
    presetUUID = "";
  }

  void onDisconnect() {
    communication.onDisconnect();
    deviceControl.onBatteryPercentage(0);
  }

  dynamic getDrumStyles();

  void resetDrumSettings() {
    config.drumsEnabled = false;
    config.selectedDrumStyle = 0;
    config.drumsVolume = 50;
    config.drumsTempo = 120;
  }

  void setDrumsEnabled(bool enabled) {
    config.drumsEnabled = enabled;
    communication.sendDrumsEnabled(config.drumsEnabled);
  }

  void setDrumsStyle(int style) {
    if (config.selectedDrumStyle == style) return;
    config.selectedDrumStyle = style;
    communication.sendDrumsStyle(style);
  }

  void setDrumsLevel(double level, bool send) {
    if (config.drumsVolume == level) return;
    config.drumsVolume = level;
    if (send) communication.sendDrumsLevel(level);
  }

  void setDrumsTempo(double tempo, bool send) {
    if (config.drumsTempo == tempo) return;
    config.drumsTempo = tempo;
    if (send) communication.sendDrumsTempo(tempo);
  }

  void setEcoMode(bool enabled) {
    config.ecoMode = enabled;
    communication.setEcoMode(enabled);
  }

  //used for master volume control
  void sendAmpLevel() {
    if (fakeMasterVolume) {
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
  }

  Preset getPreset(int index) {
    return presets[index];
  }

  //used for QR stuff, probably will be removed
  Preset getCustomPreset(int channel);

  String getAmpNameByNuxIndex(int index, int version) {
    return presets[0].getAmpNameByNuxIndex(index, version);
  }

  void renameCabinet(int cabIndex, String name) {
    if (cabinetSupport) {
      SharedPrefs().setCustomCabinetName(productStringId, cabIndex, name);
      notifyListeners();
    }
  }

  List<Preset> getPresetsList();

  void onPresetsReady() {
    if (!activeChannelRetrieval) {
      setSelectedChannel(0,
          notifyBT: true, notifyUI: true, sendFullPreset: true);
    }
    deviceControl.onPresetsReady();
    nuxPresetsReceived = true;
  }

  void _handleChannelChange(int index) {
    var newIndex = index;

    if (!nativeActiveChannelsSupport) {
      int attempts = 0;
      //channel skipping
      while (config.activeChannels[newIndex] == false) {
        newIndex++;
        attempts++;
        if (newIndex == channelsCount) newIndex = 0;
        if (attempts > 7) break;
      }
    }
    if (newIndex == index) {
      setSelectedChannel(index,
          notifyBT: false, notifyUI: true, sendFullPreset: true);
    } else {
      //skipped - update ui
      setSelectedChannel(newIndex,
          notifyBT: true, sendFullPreset: true, notifyUI: true);
    }

    //immediately set the amp level
    sendAmpLevel();
  }

  void _handleKnobReceiveData(List<int> data) {
    if (data.length < 3) return;

    //scan through the effects to find which one is controlled
    var preset = getPreset(selectedChannel);
    for (int i = 0; i < effectsChainLength; i++) {
      var selected = preset.getSelectedEffectForSlot(i);
      var effect = preset.getEffectsForSlot(i)[selected];
      var cmdCC = data[1];
      bool enable = ((data[2] & 0xc0) != 0) ^ effect.nuxEnableInverted;
      int effectIndex = data[2] & 0x3f;

      if (effect.midiCCEnableValue == effect.midiCCSelectionValue &&
          cmdCC == effect.midiCCEnableValue) {
        var procIndex = preset.getProcessorAtSlot(i);
        var nuxIndex =
            preset.getEffectArrayIndexFromNuxIndex(procIndex, effectIndex);
        preset.setSelectedEffectForSlot(i, nuxIndex, false);
        preset.setSlotEnabled(i, enable, false);
        notifyListeners();
        return;
      } else if (cmdCC == effect.midiCCEnableValue) {
        preset.setSlotEnabled(i, enable, false);
        notifyListeners();
        return;
      } else if (cmdCC == effect.midiCCSelectionValue) {
        var procIndex = preset.getProcessorAtSlot(i);
        var nuxIndex =
            preset.getEffectArrayIndexFromNuxIndex(procIndex, effectIndex);
        preset.setSelectedEffectForSlot(i, nuxIndex, false);
        notifyListeners();
        return;
      } else {
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
        if (data[1] < channelsCount) _handleChannelChange(data[1]);
        break;
      case MidiMessageValues.controlChange:
        if (data[1] == channelChangeCC) {
          _handleChannelChange(data[2]);
        } else if (data[1] == MidiCCValues.bCC_drumOnOff_No) {
          config.drumsEnabled = data[2] > 0 ? true : false;
          deviceControl.forceNotifyListeners();
          return;
        } else if (data[1] == MidiCCValues.bCC_drumType_No) {
          config.selectedDrumStyle = data[2];
          deviceControl.forceNotifyListeners();
        } else {
          _handleKnobReceiveData(data);
        }
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

  bool isPresetSupported(dynamic preset) {
    String productId = preset["product_id"];
    return productStringId == productId;
  }

  Widget getSettingsWidget() {
    return const SizedBox.shrink();
  }

  PresetQRError setupFromQRData(String qrData) {
    var result = presets[selectedChannel].setupPresetFromQRData(qrData);

    if (result == PresetQRError.Ok) {
      clearPresetData();
    }

    return result;
  }

  String? jsonToQR(Map<String, dynamic> jsonPreset) {
    var preset = presetFromJson(jsonPreset, null, qrOnly: true);
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

  bool checkQRValid(int deviceId, int ver);

  void parseEffect(
      Map<String, dynamic> effect,
      int slotIndex,
      Preset devicePreset,
      int presetVersion,
      bool unselected,
      double? overrideLevel) {
    int fxTypeNuxIndex = effect["fx_type"];
    bool enabled = unselected ? false : effect["enabled"];
    int nuxSlotIndex = devicePreset.getProcessorAtSlot(slotIndex);
    int fxIndex = devicePreset.getEffectArrayIndexFromNuxIndex(
        nuxSlotIndex, fxTypeNuxIndex);
    //check if preset conversion is needed
    if (presetVersion != productVersion) {
      //temporarily switch the preset to the other version
      //to get equivalent from this one
      devicePreset.setFirmwareVersion(presetVersion);
      //2 things - either switch the version or convert the preset
      int? newfxType = devicePreset
          .getEffectsForSlot(slotIndex)[fxIndex]
          .getEquivalentEffect(productVersion);

      if (newfxType != null) {
        fxTypeNuxIndex = newfxType;
        fxIndex = devicePreset.getEffectArrayIndexFromNuxIndex(
            nuxSlotIndex, fxTypeNuxIndex);
      } else {
        //if we don't know equivalent then disable it
        fxTypeNuxIndex = 0; //set to 0 to avoid null references
        fxIndex = 0;
        enabled = false;
      }

      //revert the preset back
      devicePreset.setFirmwareVersion(productVersion);
    }

    if (!unselected) {
      devicePreset.setSelectedEffectForSlot(slotIndex, fxIndex, false);

      devicePreset.setSlotEnabled(slotIndex, enabled, false);
    }

    Processor? fx;
    if (unselected) {
      var fxList = devicePreset.getEffectsForSlot(slotIndex);
      for (var searchFx in fxList) {
        if (searchFx.nuxIndex == fxTypeNuxIndex) fx = searchFx;
      }
    } else {
      fx = devicePreset.getEffectsForSlot(
          slotIndex)[devicePreset.getSelectedEffectForSlot(slotIndex)];
    }
    if (fx == null) return;

    for (int f = 0; f < fx.parameters.length; f++) {
      //this is only for cabs override level
      if (overrideLevel != null &&
          cabinetSupport &&
          slotIndex == cabinetSlotIndex &&
          fx.parameters[f].handle == "level") {
        fx.parameters[f].value = overrideLevel;
      } else {
        if (presetVersion == productVersion) {
          if (effect.containsKey(fx.parameters[f].handle)) {
            fx.parameters[f].value = effect[fx.parameters[f].handle];
          } else {
            debugPrint(
                "Warning: No key ${fx.parameters[f].handle} for effect $fxTypeNuxIndex in slot $fxTypeNuxIndex");
          }
        } else {
          //ask the effect for the proper handle
          var handle = fx.parameters[f].handle;
          if (effect.containsKey(handle)) {
            fx.parameters[f].value = effect[handle];
          }
        }
      }
    }
  }

  Preset? presetFromJson(Map<String, dynamic> preset, double? overrideLevel,
      {bool qrOnly = false}) {
    debugPrint(json.encode(preset));
    var pVersion = preset["version"] ?? 0;

    var nuxChannel = preset["channel"];

    if (!qrOnly) {
      BLEMidiHandler.instance().clearDataQueue();
      presetName = preset["name"];
      var category = PresetsStorage().findCategoryOfPreset(preset);
      presetCategory = category!["name"];
      presetUUID = preset["uuid"];
      setSelectedChannel(nuxChannel,
          notifyBT: true, notifyUI: true, sendFullPreset: false);
    }

    Preset p;

    if (!qrOnly) {
      p = getPreset(selectedChannel);
    } else {
      p = getCustomPreset(nuxChannel);
    }

    if (preset.containsKey("volume")) p.setVolume(preset["volume"], !qrOnly);

    //set the chain order first, if the device supports it
    if (reorderableFXChain) {
      int index = 0;
      for (String key in preset.keys) {
        var pInfo = getProcessorInfoByKey(key);
        if (pInfo != null) {
          p.setProcessorAtSlot(index, pInfo.nuxOrderIndex);
          index++;
        }
      }
    }

    //parse selected effects and apply them
    for (String key in preset.keys) {
      int? index = getChainIndexByEffectKeyName(key);
      if (index != null) {
        //get effect
        Map<String, dynamic> effect = preset[key];

        parseEffect(effect, index, p, pVersion, false, overrideLevel);
        if (!qrOnly) deviceControl.sendFullEffectSettings(index, false);
      }
    }

    //parse unselected effects
    if (!qrOnly && preset.containsKey(PresetsStorage.inactiveEffectsKey)) {
      var inactives = preset[PresetsStorage.inactiveEffectsKey];
      for (String effectKey in inactives.keys) {
        int? index = getChainIndexByEffectKeyName(effectKey);
        if (index != null) {
          //get effect
          for (var effect in inactives[effectKey]) {
            parseEffect(effect, index, p, pVersion, true, null);
          }
        }
      }
    }

    //send slot order last, because it's a message with a response
    //and due to a bug in android ble stack causing a race condition
    //it screws up the connection
    if (!qrOnly) communication.sendSlotOrder();

    //update widgets
    if (!qrOnly) {
      notifyListeners();
    } else {
      return p;
    }

    return null;
  }

  Map<String, dynamic> presetToJson() {
    Map<String, dynamic> mainJson = {
      "channel": selectedChannel,
      "product_id": productStringId,
      "version": productVersion
    };

    Preset p = getPreset(selectedChannel);

    if (!fakeMasterVolume) mainJson["volume"] = p.volume;
    //parse all effects
    for (int i = 0; i < effectsChainLength; i++) {
      Processor fx;

      fx = p.getEffectsForSlot(i)[p.getSelectedEffectForSlot(i)];

      var fxData = <String, dynamic>{};
      fxData["fx_type"] = fx.nuxIndex;
      fxData["enabled"] = p.slotEnabled(i);

      for (int f = 0; f < fx.parameters.length; f++) {
        fxData[fx.parameters[f].handle] = fx.parameters[f].value;
      }

      var proc = p.getProcessorAtSlot(i);
      var effect = processorListNuxIndex(proc);
      mainJson[effect!.keyName] = fxData;
    }

    // Save settings for not selected effects
    var inactiveFX = <String, dynamic>{};

    for (int i = 0; i < effectsChainLength; i++) {
      List fxSlotList = [];

      //skip cab block, because it makes the preset huge
      //while not being very useful
      if (i == cabinetSlotIndex) continue;

      List<Processor> effectsForslot = p.getEffectsForSlot(i);
      for (int j = 0; j < effectsForslot.length; j++) {
        if (j == p.getSelectedEffectForSlot(i)) continue;

        var fxData = <String, dynamic>{};
        fxData["fx_type"] = effectsForslot[j].nuxIndex;

        // Generic processing of not selected effects
        Processor fx;
        fx = effectsForslot[j];

        for (int f = 0; f < fx.parameters.length; f++) {
          fxData[fx.parameters[f].handle] = fx.parameters[f].value;
        }

        fxSlotList.add(fxData);
      }

      if (fxSlotList.isNotEmpty) {
        var proc = p.getProcessorAtSlot(i);
        var effect = processorListNuxIndex(proc);
        inactiveFX[effect!.keyName] = fxSlotList;
      }
    }

    mainJson[PresetsStorage.inactiveEffectsKey] = inactiveFX;
    return mainJson;
  }
}
