// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/communication.dart';
import 'package:mighty_plug_manager/platform/presetsStorage.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:qr_utils/qr_utils.dart';
import '../../modules/cloud/presetEncoder.dart';
import '../NuxDeviceControl.dart';
import '../bleMidiHandler.dart';
import "NuxConstants.dart";
import 'NuxFXID.dart';
import 'communication/namProCommunication.dart';
import 'effects/Processor.dart';
import 'presets/NamProPreset.dart';
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

  int get productVID;
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
  String get presetClass;
  String get productNameForQR => productNameShort;
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
  bool get jamTrackChannelChange => false;

  int get deviceQRId;
  int get deviceQRVersion;
  int get channelChangeCC;

  List<String> channelNames = [];
  List<String> groupsName = <String>[];

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

  String getProductNameForQR(int version) {
    return productNameForQR;
  }

  ProcessorInfo? getProcessorInfoByKey(String key) {
    for (var proc in processorList) {
      if (proc.keyName == key) return proc;
    }
    return null;
  }

  int? getSlotByEffectKeyName(String key) {
    var pi = getProcessorInfoByKey(key);
    if (pi != null) {
      return pi.nuxFXID.toInt();
    }
    return null;
  }

  ProcessorInfo? getProcessorInfoByFXID(NuxFXID fxid) {
    for (var proc in processorList) {
      if (proc.nuxFXID == fxid) return proc;
    }
    return null;
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
    if (selectedChannelP != chan) {
      selectedChannelP = chan;
      deviceControl.clearPresetData();
      if (notifyBT) deviceControl.changeDeviceChannel(selectedChannelP);
    }
    if (sendFullPreset) deviceControl.sendFullPresetSettings();
    if (deviceControl.isConnected) sendAmpLevel();
    if (notifyUI) {
      deviceControl.forceNotifyListeners();
    }
  }

  bool getChannelActive(int channel) {
    return config.activeChannels[channel];
  }

  void toggleChannelActive(int channel) {
    config.activeChannels[channel] = !config.activeChannels[channel];
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
    for (int i = 0; i < presets.length; i++) {
      presets[i].resetNuxData();
    }
    resetDrumSettings();
  }

  void onDisconnect() {
    communication.onDisconnect();
    deviceControl.onBatteryPercentage(0);
  }

  dynamic getDrumStyles();

  int getDrumStylesCount() {
    return (getDrumStyles() as List).length;
  }

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
    tempo = math.min(math.max(tempo, drumsMinTempo), drumsMaxTempo);
    config.drumsTempo = tempo;
    if (send) communication.sendDrumsTempo(tempo);
  }

  void setEcoMode(bool enabled) {
    config.ecoMode = enabled;
    communication.setEcoMode(enabled);
  }

  void sendAmpLevel() {
    if (fakeMasterVolume) {
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

  List<Preset> getPresetsList() {
    return presets;
  }

  String channelName(int channel) {
    return channelNames[channel];
  }

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
      while (config.activeChannels[newIndex] == false) {
        newIndex++;
        attempts++;
        if (newIndex == channelsCount) newIndex = 0;
        if (attempts > 7) break;
      }
    }
    if (newIndex == index) {
      setSelectedChannel(index,
          notifyBT: false, notifyUI: true, sendFullPreset: false);
    } else {
      setSelectedChannel(newIndex,
          notifyBT: true, sendFullPreset: false, notifyUI: true);
    }
    getPreset(selectedChannel).setupPresetFromNuxData();
    sendAmpLevel();
  }

  void _handleKnobReceiveData(List<int> data) {
    if (data.length < 3) return;
    var preset = getPreset(selectedChannel);
    for (int i = 0; i < effectsChainLength; i++) {
      var selected = preset.getSelectedEffectForSlot(i);
      var effect = preset.getEffectsForSlot(i)[selected];
      var cmdCC = data[1];
      bool enable = ((data[2] & 0xc0) != 0) ^ effect.nuxEnableInverted;
      int effectIndex = data[2] & 0x3f;

      if (effect.midiCCEnableValue == effect.midiCCSelectionValue &&
          cmdCC == effect.midiCCEnableValue) {
        var procIndex = preset.getFXIDFromSlot(i);
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
        var procIndex = preset.getFXIDFromSlot(i);
        var nuxIndex =
            preset.getEffectArrayIndexFromNuxIndex(procIndex, effectIndex);
        preset.setSelectedEffectForSlot(i, nuxIndex, false);
        notifyListeners();
        return;
      } else {
        for (var param in effect.parameters) {
          if (param.midiCC == data[1]) {
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
    return presetClass == productId;
  }

  Widget getSettingsWidget() {
    return const SizedBox.shrink();
  }

  PresetQRError setupFromQRData(String qrData) {
    var result = presets[selectedChannel].setupPresetFromQRData(qrData);
    if (result == PresetQRError.Ok) {
      deviceControl.clearPresetData();
    }
    return result;
  }

  Preset? setupDetachedPresetFromQRData(String qrData) {
    var p = getCustomPreset(selectedChannel);
    var result = p.setupPresetFromQRData(qrData);
    if (result == PresetQRError.Ok) return p;
    return null;
  }

  String? jsonToQR(Map<String, dynamic> jsonPreset) {
    var preset = presetFromJson(jsonPreset, null, qrOnly: true);
    if (preset != null) {
      var data = preset.createNuxDataFromPreset();
      return "${QrUtils.nuxQRPrefix}${base64Encode(data)}";
    }
    return null;
  }

  List<int>? jsonToCompressedData(Map<String, dynamic> jsonPreset) {
    var preset = presetFromJson(jsonPreset, null, qrOnly: true);
    if (preset != null) {
      var data = preset.createNuxDataFromPreset();
      var encoded = PresetEncoder.encode(data);
      return encoded;
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
    NuxFXID nuxSlotIndex = devicePreset.getFXIDFromSlot(slotIndex);
    int fxIndex = devicePreset.getEffectArrayIndexFromNuxIndex(
        nuxSlotIndex, fxTypeNuxIndex);

    if (presetVersion != productVersion) {
      devicePreset.setFirmwareVersion(presetVersion);
      int? newfxType = devicePreset
          .getEffectsForSlot(slotIndex)[fxIndex]
          .getEquivalentEffect(productVersion);
      if (newfxType != null) {
        fxTypeNuxIndex = newfxType;
        fxIndex = devicePreset.getEffectArrayIndexFromNuxIndex(
            nuxSlotIndex, fxTypeNuxIndex);
      } else {
        fxTypeNuxIndex = 0;
        fxIndex = 0;
        enabled = false;
      }
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
          var handle = fx.parameters[f].handle;
          if (effect.containsKey(handle)) {
            fx.parameters[f].value = effect[handle];
          }
        }
      }
    }
  }

  Preset? presetFromJson(Map<String, dynamic> preset, double? overrideLevel,
      {bool qrOnly = false, bool dontChangeChannel = false}) {
    var pVersion = preset["version"] ?? 0;
    var nuxChannel = preset["channel"] ?? selectedChannel;
    if (!qrOnly) {
      BLEMidiHandler.instance().clearDataQueue();

      // SAME-CHANNEL BYPASS: Do not fire hardware Program Change if staying on the active channel
      bool isSameChannel = (nuxChannel == selectedChannel);
      if (!dontChangeChannel || jamTrackChannelChange) {
        setSelectedChannel(nuxChannel,
            notifyBT: !isSameChannel, notifyUI: true, sendFullPreset: false);
      }
      deviceControl.presetName = preset["name"] ?? "";
      var category = PresetsStorage().findCategoryOfPreset(preset);
      deviceControl.presetCategory = category?["name"] ?? "";
      deviceControl.presetUUID = preset["uuid"] ?? "";
    }

    Preset p;
    if (!qrOnly) {
      p = getPreset(selectedChannel);
    } else {
      p = getCustomPreset(nuxChannel);
    }

    // Volume Delta Check
    if (preset.containsKey("volume")) {
      double newVol = (preset["volume"] as num).toDouble();
      if ((p.volume - newVol).abs() > 0.001) {
        p.setVolume(newVol, !qrOnly);
      }
    }

    // CHAIN ORDER CHECK: Compare existing slots to prevent redundant kSYX_MODULELINK halts
    bool orderChanged = false;
    if (reorderableFXChain) {
      List<NuxFXID> previousOrder = [];
      for (int i = 0; i < p.device.effectsChainLength; i++) {
        previousOrder.add(p.getFXIDFromSlot(i));
      }

      List<String> keyOrder = [];
      for (String key in preset.keys) {
        var pInfo = getProcessorInfoByKey(key);
        if (pInfo != null) {
          keyOrder.add(key);
        }
      }

      if (presetClass == "mighty_nam_pro") {
        if (!keyOrder.contains("fxa")) {
          int insertIndex = keyOrder.length >= 2 ? 2 : keyOrder.length;
          keyOrder.insert(insertIndex, "fxa");
        }
        if (!keyOrder.contains("fxb")) {
          int insertIndex = keyOrder.length >= 3 ? 3 : keyOrder.length;
          keyOrder.insert(insertIndex, "fxb");
        }
      }

      for (var pInfo in p.device.processorList) {
        if (!keyOrder.contains(pInfo.keyName)) {
          keyOrder.add(pInfo.keyName);
        }
      }

      for (int index = 0;
          index < keyOrder.length && index < p.device.effectsChainLength;
          index++) {
        var pInfo = getProcessorInfoByKey(keyOrder[index]);
        if (pInfo != null) {
          p.setFXIDAtSlot(index, pInfo.nuxFXID);
        }
      }

      for (int i = 0; i < p.device.effectsChainLength; i++) {
        if (i >= previousOrder.length ||
            previousOrder[i] != p.getFXIDFromSlot(i)) {
          orderChanged = true;
          break;
        }
      }
    }

    // Snapshot Custom SysEx state prior to in-memory mutations
    List<int>? prevNfPayload;
    if (p is NamProPreset) {
      prevNfPayload = p.generateNfPayload();
    }

    // Parse effects and only transmit delta parameters over BLE
    for (String key in preset.keys) {
      int? index = getSlotByEffectKeyName(key);
      if (index != null) {
        Map<String, dynamic> effect = preset[key];

        int prevSelectedEffect = p.getSelectedEffectForSlot(index);
        bool prevEnabled = p.slotEnabled(index);
        var effectsList = p.getEffectsForSlot(index);
        Processor? prevEffect = (prevSelectedEffect >= 0 &&
                prevSelectedEffect < effectsList.length)
            ? effectsList[prevSelectedEffect]
            : null;

        Map<String, int> prevParamMidiValues = {};
        if (prevEffect != null) {
          for (var param in prevEffect.parameters) {
            prevParamMidiValues[param.handle] = param.midiValue;
          }
        }

        parseEffect(effect, index, p, pVersion, false, overrideLevel);

        if (!qrOnly) {
          int newSelectedEffect = p.getSelectedEffectForSlot(index);
          bool newEnabled = p.slotEnabled(index);
          var newEffectsList = p.getEffectsForSlot(index);
          Processor newEffect = newEffectsList[newSelectedEffect];
          bool effectTypeChanged = (prevSelectedEffect != newSelectedEffect);
          bool enabledChanged = (prevEnabled != newEnabled);
          bool distinctCCodes =
              newEffect.midiCCSelectionValue != newEffect.midiCCEnableValue;

          if (newEffect.midiCCSelectionValue >= 0) {
            if (effectTypeChanged) {
              if (distinctCCodes) {
                if (deviceControl.device.presets[0]
                        .getEffectsForSlot(index)
                        .length >
                    1) {
                  communication.sendSlotEffect(index, newEffect.nuxIndex);
                }
              } else {
                communication.sendSlotEnabledState(index);
              }

              for (var param in newEffect.parameters) {
                if (param.midiCC >= 0) {
                  deviceControl.sendParameter(param, false);
                }
              }

              if (p.slotSwitchable(index) && distinctCCodes) {
                communication.sendSlotEnabledState(index);
              }
            } else {
              if (enabledChanged) {
                communication.sendSlotEnabledState(index);
              }
              for (var param in newEffect.parameters) {
                if (param.midiCC >= 0) {
                  int? oldMidi = prevParamMidiValues[param.handle];
                  if (oldMidi == null || oldMidi != param.midiValue) {
                    deviceControl.sendParameter(param, false);
                  }
                }
              }
            }
          }
        }
      }
    }

    // Transmit consolidated custom SysEx ONLY if payload delta was detected
    if (!qrOnly && p is NamProPreset && communication is NamProCommunication) {
      List<int> newNfPayload = p.generateNfPayload();
      bool nfPayloadChanged = false;
      if (prevNfPayload == null ||
          prevNfPayload.length != newNfPayload.length) {
        nfPayloadChanged = true;
      } else {
        for (int i = 0; i < newNfPayload.length; i++) {
          if (prevNfPayload[i] != newNfPayload[i]) {
            nfPayloadChanged = true;
            break;
          }
        }
      }
      if (nfPayloadChanged) {
        (communication as NamProCommunication).sendNfPayload(newNfPayload);
      }
    }

    // Inactive effects parse
    if (!qrOnly && preset.containsKey(PresetsStorage.inactiveEffectsKey)) {
      var inactives = preset[PresetsStorage.inactiveEffectsKey];
      for (String effectKey in inactives.keys) {
        int? index = getSlotByEffectKeyName(effectKey);
        if (index != null) {
          for (var effect in inactives[effectKey]) {
            parseEffect(effect, index, p, pVersion, true, null);
          }
        }
      }
    }

    // Only transmit topology command if physical block order has changed
    if (!qrOnly && orderChanged) {
      communication.sendSlotOrder();
    }

    if (!qrOnly) {
      deviceControl.forceNotifyListeners();
    } else {
      return p;
    }
    return null;
  }

  Map<String, dynamic> presetToJson({Preset? customPreset}) {
    Map<String, dynamic> mainJson = {
      "channel": selectedChannel,
      "product_id": presetClass,
      "version": productVersion
    };

    Preset p = customPreset ?? getPreset(selectedChannel);

    if (!fakeMasterVolume) mainJson["volume"] = p.volume;

    for (int i = 0; i < effectsChainLength; i++) {
      Processor fx;
      fx = p.getEffectsForSlot(i)[p.getSelectedEffectForSlot(i)];
      var fxData = <String, dynamic>{};
      fxData["fx_type"] = fx.nuxIndex;
      fxData["enabled"] = p.slotEnabled(i);
      for (int f = 0; f < fx.parameters.length; f++) {
        fxData[fx.parameters[f].handle] = fx.parameters[f].value;
      }

      var proc = p.getFXIDFromSlot(i);
      var effect = getProcessorInfoByFXID(proc);
      mainJson[effect!.keyName] = fxData;
    }

    var inactiveFX = <String, dynamic>{};
    for (int i = 0; i < effectsChainLength; i++) {
      List fxSlotList = [];
      if (i == cabinetSlotIndex) continue;
      List<Processor> effectsForslot = p.getEffectsForSlot(i);
      for (int j = 0; j < effectsForslot.length; j++) {
        if (j == p.getSelectedEffectForSlot(i)) continue;
        var fxData = <String, dynamic>{};
        fxData["fx_type"] = effectsForslot[j].nuxIndex;
        Processor fx;
        fx = effectsForslot[j];
        for (int f = 0; f < fx.parameters.length; f++) {
          fxData[fx.parameters[f].handle] = fx.parameters[f].value;
        }
        fxSlotList.add(fxData);
      }
      if (fxSlotList.isNotEmpty) {
        var proc = p.getFXIDFromSlot(i);
        var effect = getProcessorInfoByFXID(proc);
        inactiveFX[effect!.keyName] = fxSlotList;
      }
    }
    mainJson[PresetsStorage.inactiveEffectsKey] = inactiveFX;
    return mainJson;
  }
}