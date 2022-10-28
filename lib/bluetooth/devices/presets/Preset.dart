// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:convert';
import 'dart:ui';

import 'package:qr_utils/qr_utils.dart';
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

  int get qrDataLength;

  NuxDevice device;
  int channel;
  String channelName;
  Color get channelColor => channelColors[channel];
  List<Amplifier> get amplifierList;

  List<List<int>> nuxDataPieces = [];

  Preset(
      {required this.device, required this.channel, required this.channelName});

  //checks if the effect slot can be switched on and off
  bool slotSwitchable(int index);

  //returns whether the specific slot is on or off
  bool slotEnabled(int index);

  //used for reorderable fx chain
  int getProcessorAtSlot(int slot);

  void setupPresetFromNuxDataArray(List<int> _nuxData);

  void setProcessorAtSlot(int slot, int processorId) {}
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
  void setParameterValue(Parameter param, double value) {
    param.value = value;
    device.parameterChanged.add(param);
  }

  int getEffectArrayIndexFromNuxIndex(int nuxSlot, int nuxIndex) {
    return nuxIndex;
  }

  Color effectColor(int index);

  void resetNuxData() {
    nuxDataPieces = [];
  }

  //receives data chunk from a device
  void addNuxPayloadPiece(List<int> data, int part, int total) {
    if (nuxDataPieces.length != total) {
      nuxDataPieces = List.filled(total, []);
    }

    nuxDataPieces[part] = data;
  }

  bool payloadPiecesReady() {
    for (int i = 0; i < nuxDataPieces.length; i++)
      if (nuxDataPieces[i].length == 0) return false;
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
    return data;
  }

  void setupPresetFromNuxData() {
    List<int> nuxData = [];
    for (int i = 0; i < nuxDataPieces.length; i++)
      nuxData.addAll(nuxDataPieces[i]);
    setupPresetFromNuxDataArray(nuxData);
  }

  PresetQRError setupPresetFromQRData(String qrData) {
    if (qrData.contains(QrUtils.nuxQRPrefix)) {
      var b64Data = qrData.substring(QrUtils.nuxQRPrefix.length);
      var data = base64Decode(b64Data);
      if (data[0] == device.deviceQRId && device.checkQRVersionValid(data[1])) {
        setupPresetFromNuxDataArray(data.sublist(2));
        device.deviceControl.sendFullPresetSettings();
        return PresetQRError.Ok;
      }
      if (data[0] != device.deviceQRId) return PresetQRError.WrongDevice;
      return PresetQRError.WrongFWVersion;
    }
    return PresetQRError.UnsupportedFormat;
  }
}
