// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:convert';
import 'dart:ui';

import 'package:convert/convert.dart';
import 'package:qr_utils/qr_utils.dart';
import 'package:undo/undo.dart';
import '../../NuxDeviceControl.dart';
import '../NuxDevice.dart';
import '../NuxFXID.dart';
import '../effects/Processor.dart';
import 'preset_constants.dart';

abstract class Preset {
  int get qrDataLength;

  NuxDevice device;
  int channel;
  String channelName;
  Color get channelColor => channelColorsList[channel];
  List<Color> get channelColorsList => PresetConstants.channelColorsPlug;
  List<Amplifier> get amplifierList;
  List<Cabinet>? get cabinetList => null;

  final _changeStack = ChangeStack();

  ChangeStack get changes => _changeStack;

  List<List<int>> nuxDataPieces = [];

  Preset(
      {required this.device, required this.channel, required this.channelName});

  //checks if the effect slot can be switched on and off
  bool slotSwitchable(int index);

  //returns whether the specific slot is on or off
  bool slotEnabled(int index);

  //override in reorderable fx chain
  NuxFXID getFXIDFromSlot(int slot) {
    return NuxFXID.fromInt(slot);
  }

  int? getSlotFromFXID(NuxFXID fxid) {
    return fxid.toInt();
  }

  void setupPresetFromNuxDataArray(List<int> nuxData) {
    if (nuxData.length < 10) return;

    var loadedPreset = hex.encode(nuxData);

    NuxDeviceControl.instance().diagData.lastNuxPreset = loadedPreset;
    NuxDeviceControl.instance().updateDiagnosticsData(nuxPreset: loadedPreset);

    for (int i = 0; i < device.effectsChainLength; i++) {
      bool fxFound = false;

      var effects = getEffectsForSlot(i);

      if (effects.isEmpty) continue;
      //set proper effect
      if (effects[0].nuxEffectTypeIndex != null) {
        int effectData = nuxData[effects[0].nuxEffectTypeIndex!];

        int effectIndex = effectData;
        if (effects[0].nuxEffectTypeIndex == effects[0].nuxEnableIndex) {
          effectIndex &= ~effects[0].nuxEnableMask;
        }

        //find array index by nux index
        for (int j = 0; j < effects.length; j++) {
          if (effects[j].nuxIndex == effectIndex) {
            effectIndex = j;
            fxFound = true;
            break;
          }
        }
        setSelectedEffectForSlot(i, effectIndex, false);
      }

      //enable/disable effect
      if (fxFound && effects[0].nuxEnableIndex != null) {
        int enableData =
            nuxData[effects[0].nuxEnableIndex!] & effects[0].nuxEnableMask;

        bool enabled = (enableData != 0) ^ effects[0].nuxEnableInverted;

        setSlotEnabled(i, enabled, false);

        getEffectsForSlot(i)[getSelectedEffectForSlot(i)]
            .setupFromNuxPayload(nuxData);
      } else {
        setSlotEnabled(i, false, false);
      }
    }
  }

  void setFXIDAtSlot(int slot, NuxFXID fxid) {}
  void swapProcessorSlots(int from, int to, bool notifyBT) {
    if (notifyBT) device.slotSwapped.add(to);
  }

  //turns slot on or off
  void setSlotEnabled(int index, bool value, bool notifyBT) {
    if (notifyBT) device.effectSwitched.add(index);
  }

  //returns list of effects for given slot
  List<Processor> getEffectsForSlot(int slot);

  //returns which of the effects is selected for a given slot
  int getSelectedEffectForSlot(int slot);

  //sets the effect for the given slot
  void setSelectedEffectForSlot(int slot, int index, bool notifyBT) {
    if (notifyBT) device.effectChanged.add(slot);
  }

  void setFirmwareVersion(int version);

  //change a parameter and announce it
  void setParameterValue(Parameter param, double value, {bool notify = true}) {
    param.value = value;
    if (notify) {
      device.parameterChanged.add(param);
    }
  }

  //override in more complex FX chains
  int getEffectArrayIndexFromNuxIndex(NuxFXID fxid, int nuxIndex) {
    return nuxIndex;
  }

  Color effectColor(int index);

  void resetNuxData() {
    nuxDataPieces = [];
  }

  //receives data chunk from a device
  void addNuxPayloadPiece(List<int> data, int part, int total) {
    if (total == 0) return;
    if (nuxDataPieces.length != total) {
      nuxDataPieces = List.filled(total, []);
    }

    nuxDataPieces[part] = data;
  }

  bool payloadPiecesReady() {
    for (int i = 0; i < nuxDataPieces.length; i++) {
      if (nuxDataPieces[i].isEmpty) return false;
    }
    return true;
  }

  //this is for QR export
  List<int> createNuxDataFromPreset() {
    List<int> data = List.filled(qrDataLength, 0);
    List<int> qrData = [];
    qrData.add(device.deviceQRId);
    qrData.add(device.deviceQRVersion);

    for (int i = 0; i < device.effectsChainLength; i++) {
      getEffectsForSlot(i)[getSelectedEffectForSlot(i)]
          .getNuxPayload(data, slotEnabled(i));
    }

    qrData.addAll(data);
    return qrData;
  }

  void setupPresetFromNuxData() {
    List<int> nuxData = [];
    for (int i = 0; i < nuxDataPieces.length; i++) {
      nuxData.addAll(nuxDataPieces[i]);
    }
    setupPresetFromNuxDataArray(nuxData);
  }

  PresetQRError setupPresetFromQRData(String qrData) {
    if (qrData.contains(QrUtils.nuxQRPrefix)) {
      var b64Data = qrData.substring(QrUtils.nuxQRPrefix.length);
      var data = base64Decode(b64Data);
      if (device.checkQRValid(data[0], data[1])) {
        setupPresetFromNuxDataArray(data.sublist(2));
        device.deviceControl.sendFullPresetSettings();
        return PresetQRError.Ok;
      }
      if (data[0] != device.deviceQRId) return PresetQRError.WrongDevice;
      return PresetQRError.WrongFWVersion;
    }
    return PresetQRError.UnsupportedFormat;
  }

  String getAmpNameByNuxIndex(int index, int version) {
    var ampIndex = getFXIDFromSlot(device.amplifierSlotIndex);
    index = getEffectArrayIndexFromNuxIndex(ampIndex, index);
    return amplifierList[index].name;
  }

  double get volume => 0;

  set volume(double vol) => {};

  void setVolume(double vol, bool btTransmit) {}

  void sendVolume() {}
}
