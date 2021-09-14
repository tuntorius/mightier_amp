// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:convert';
import 'dart:ui';

import 'package:convert/convert.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:qr_utils/qr_utils.dart';
import '../NuxConstants.dart';
import '../NuxDevice.dart';
import '../effects/Processor.dart';

abstract class Preset {
  static const List<Color> channelColors = [
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 240, 160, 10),
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(220, 230, 230, 255),
    Color.fromARGB(255, 130, 225, 255),
    Color.fromARGB(255, 210, 140, 250),
    Color.fromARGB(255, 71, 167, 245),
    Color.fromARGB(230, 230, 230, 255),
  ];

  NuxDevice device;
  int channel;
  String channelName;
  Color get channelColor => channelColors[channel];
  List<Amplifier> get amplifierList;
  //nux data
  List<int> nuxData = <int>[];

  Preset(
      {required this.device, required this.channel, required this.channelName});

  //checks if the effect slot can be switched on and off
  bool slotSwitchable(int index);

  //returns whether the specific slot is on or off
  bool slotEnabled(int index);

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
  void setParameterValue(Parameter param, double value) {
    param.value = value;

    device.parameterChanged.add(param);
  }

  Color effectColor(int index);

  void resetNuxData() {
    nuxData.clear();
  }

  //receives data chunk from a device
  void addNuxPayloadPiece(List<int> data) {
    nuxData.addAll(data);
  }

  //this is for QR export
  List<int> createNuxDataFromPreset() {
    List<int> data = [];
    data.add(device.deviceQRId);
    data.add(device.productVersion);

    for (int i = 0; i < device.effectsChainLength; i++) {
      var payload =
          getEffectsForSlot(i)[getSelectedEffectForSlot(i)].getNuxPayload();
      //noise gate is specific
      if (i == 0) payload.removeAt(0);

      data.add(slotEnabled(i) ? 0 : 127);
      data.addAll(payload);
    }
    //these zeros are required
    data.addAll([0, 0, 0, 0, 0, 0]);
    return data;
  }

  void setupPresetFromNuxData() {
    setupPresetFromNuxDataArray(nuxData);
  }

  PresetQRError setupPresetFromQRData(String qrData) {
    if (qrData.contains(QrUtils.nuxQRPrefix)) {
      var b64Data = qrData.substring(QrUtils.nuxQRPrefix.length);
      var data = base64Decode(b64Data);
      if (data[0] == device.deviceQRId && data[1] == device.productVersion) {
        setupPresetFromNuxDataArray(data.sublist(2));
        return PresetQRError.Ok;
      }
      if (data[0] != device.deviceQRId) return PresetQRError.WrongDevice;
      return PresetQRError.WrongFWVersion;
    }
    return PresetQRError.UnsupportedFormat;
  }

  void setupPresetFromNuxDataArray(List<int> _nuxData) {
    if (_nuxData.length < 10) return;

    var loadedPreset = hex.encode(_nuxData);

    NuxDeviceControl().diagData.lastNuxPreset = loadedPreset;
    NuxDeviceControl().updateDiagnosticsData(nuxPreset: loadedPreset);

    for (int i = 0; i < device.effectsChainLength; i++) {
      //set proper effect
      int effectIndex = _nuxData[PresetDataIndexPlugAir.effectTypesIndex[i]];
      setSelectedEffectForSlot(i, effectIndex, false);

      //enable/disable effect
      setSlotEnabled(i,
          _nuxData[PresetDataIndexPlugAir.effectEnabledIndex[i]] != 0, false);

      getEffectsForSlot(i)[getSelectedEffectForSlot(i)]
          .setupFromNuxPayload(_nuxData);
    }
  }
}
