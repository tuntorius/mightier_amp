import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

import '../../NuxDeviceControl.dart';
import '../NuxConstants.dart';
import '../NuxDevice.dart';
import '../NuxFXID.dart';
import '../communication/namProCommunication.dart';
import '../device_data/processors_list.dart';
import '../effects/Processor.dart';
import '../effects/mighty_nam/CutEQ.dart';
import '../effects/mighty_nam/ExtraFX.dart';
import '../effects/mighty_nam/NamAmp.dart';
import '../effects/plug_pro/EQ.dart';
import 'PlugProPreset.dart';

class NamProPreset extends PlugProPreset {
  final List<Processor> _namAmpList = [NamAmp()];

  late final List<Processor> _namEqList = [
    EQSixBand(),
    EQTenBand(),
    HighLowCut(),
  ];

  final List<Processor> _fxAList =
      ProcessorsList.buildExtraFxList(isFxB: false);
  final List<Processor> _fxBList = ProcessorsList.buildExtraFxList(isFxB: true);

  List<Processor> get efxList => getEffectsForFXID(PlugProFXID.efx);
  List<Processor> get modulationList => getEffectsForFXID(PlugProFXID.mod);

  bool fxAEnabled = false;
  bool fxBEnabled = false;
  int selectedFxA = 0;
  int selectedFxB = 1;

  NamProPreset({
    required NuxDevice device,
    required int channel,
    required String channelName,
  }) : super(device: device, channel: channel, channelName: channelName) {
    amplifierList.clear();
    amplifierList.add(NamAmp());

    _ensureCustomBlocks();
  }

  void _ensureCustomBlocks() {
    if (!processorAtSlot.contains(MightyNamFXID.fxA)) {
      processorAtSlot.insert(
          2.clamp(0, processorAtSlot.length), MightyNamFXID.fxA);
    }
    if (!processorAtSlot.contains(MightyNamFXID.fxB)) {
      int posB = processorAtSlot.indexOf(MightyNamFXID.fxA) + 1;
      processorAtSlot.insert(
          posB.clamp(0, processorAtSlot.length), MightyNamFXID.fxB);
    }
  }

  @override
  NuxFXID getFXIDFromSlot(int slot) {
    _ensureCustomBlocks();
    return super.getFXIDFromSlot(slot);
  }

  @override
  int? getSlotFromFXID(NuxFXID fxid) {
    _ensureCustomBlocks();
    return super.getSlotFromFXID(fxid);
  }

  @override
  bool slotEnabled(int index) {
    var proc = getFXIDFromSlot(index);
    if (proc == MightyNamFXID.fxA) return fxAEnabled;
    if (proc == MightyNamFXID.fxB) return fxBEnabled;
    return super.slotEnabled(index);
  }

  @override
  void setSlotEnabled(int index, bool value, bool notifyBT) {
    var proc = getFXIDFromSlot(index);
    if (proc == MightyNamFXID.fxA) {
      fxAEnabled = value;
      if (notifyBT && device.communication is NamProCommunication) {
        (device.communication as NamProCommunication)
            .sendNfPayload(generateNfPayload());
      }
      super.setSlotEnabled(index, value, false); // Prevent CC double-fire
      return;
    }
    if (proc == MightyNamFXID.fxB) {
      fxBEnabled = value;
      if (notifyBT && device.communication is NamProCommunication) {
        (device.communication as NamProCommunication)
            .sendNfPayload(generateNfPayload());
      }
      super.setSlotEnabled(index, value, false); // Prevent CC double-fire
      return;
    }
    super.setSlotEnabled(index, value, notifyBT);
  }

  @override
  int getSelectedEffectForSlot(int slot) {
    var proc = getFXIDFromSlot(slot);
    if (proc == MightyNamFXID.fxA) return selectedFxA;
    if (proc == MightyNamFXID.fxB) return selectedFxB;
    if (proc.value == PresetDataIndexPlugPro.Head_iAMP) return 0;
    return super.getSelectedEffectForSlot(slot);
  }

  @override
  void setSelectedEffectForSlot(int slot, int index, bool notifyBT) {
    var proc = getFXIDFromSlot(slot);
    if (proc == MightyNamFXID.fxA) {
      selectedFxA = index;
      if (notifyBT && device.communication is NamProCommunication) {
        (device.communication as NamProCommunication)
            .sendNfPayload(generateNfPayload());
      }
      return;
    }
    if (proc == MightyNamFXID.fxB) {
      selectedFxB = index;
      if (notifyBT && device.communication is NamProCommunication) {
        (device.communication as NamProCommunication)
            .sendNfPayload(generateNfPayload());
      }
      return;
    }
    super.setSelectedEffectForSlot(slot, index, notifyBT);
  }

  List<Processor> getEffectsForFXID(NuxFXID fxid) {
    if (fxid == MightyNamFXID.fxA) return _fxAList;
    if (fxid == MightyNamFXID.fxB) return _fxBList;

    switch (fxid.value) {
      case PresetDataIndexPlugPro.Head_iAMP:
        return _namAmpList;
      case PresetDataIndexPlugPro.Head_iEQ:
        return _namEqList;
      case PresetDataIndexPlugPro.Head_iEFX:
        var slot = getSlotFromFXID(fxid);
        if (slot != null) return super.getEffectsForSlot(slot);
        return [];
      case PresetDataIndexPlugPro.Head_iMOD:
        var slot = getSlotFromFXID(fxid);
        if (slot != null) return super.getEffectsForSlot(slot);
        return [];
      default:
        var slot = getSlotFromFXID(fxid);
        if (slot != null) {
          return super.getEffectsForSlot(slot);
        }
        return <Processor>[];
    }
  }

  @override
  List<Processor> getEffectsForSlot(int slot) {
    var fxid = getFXIDFromSlot(slot);
    return getEffectsForFXID(fxid);
  }

  @override
  int getEffectArrayIndexFromNuxIndex(NuxFXID fxid, int nuxIndex) {
    List<Processor> list = getEffectsForFXID(fxid);
    for (int i = 0; i < list.length; i++) {
      if (list[i].nuxIndex == nuxIndex) return i;
    }
    return 0;
  }

  List<int> generateNfPayload() {
    _ensureCustomBlocks();
    final List<int> config = List<int>.filled(32, 0);

    for (int slot = 0; slot < 2; slot++) {
      final int offset = slot * 16;
      config[offset + 0] = slot + 1;
      config[offset + 1] = 0;
      config[offset + 2] = slot + 2;
      config[offset + 3] = 12;
      config[offset + 4] = 100;
      config[offset + 5] = 30;
      config[offset + 6] = 50;
      config[offset + 7] = 0;
      config[offset + 8] = 50;
      config[offset + 9] = 50;
    }

    int posA = processorAtSlot.indexOf(MightyNamFXID.fxA);
    if (posA == -1) posA = 2;
    posA = posA.clamp(0, 10);
    config[0] = _fxAList[selectedFxA].nuxIndex.clamp(1, 7);
    config[1] = fxAEnabled ? 1 : 0;
    config[2] = posA;
    for (var p in _fxAList[selectedFxA].parameters) {
      if (p.devicePresetIndex >= 3 && p.devicePresetIndex < 10) {
        config[0 + p.devicePresetIndex] = p.midiValue; 
      }
    }

    int posB = processorAtSlot.indexOf(MightyNamFXID.fxB);
    if (posB == -1) posB = 3;
    posB = posB.clamp(0, 10);
    if (posB == posA) {
      posB = (posA == 10) ? posA - 1 : posA + 1;
    }
    config[16] = _fxBList[selectedFxB].nuxIndex.clamp(1, 7);
    config[17] = fxBEnabled ? 1 : 0;
    config[18] = posB;
    for (var p in _fxBList[selectedFxB].parameters) {
      if (p.devicePresetIndex >= 3 && p.devicePresetIndex < 10) {
        config[16 + p.devicePresetIndex] = p.midiValue; 
      }
    }

    for (int slot = 0; slot < 2; slot++) {
      int offset = slot * 16;
      config[offset + 0] = config[offset + 0].clamp(1, 7);
      config[offset + 1] = config[offset + 1].clamp(0, 1);
      config[offset + 2] = config[offset + 2].clamp(0, 10);
      config[offset + 3] = config[offset + 3].clamp(0, 24);
      for (int i = 4; i < 10; i++) {
        config[offset + i] = config[offset + i].clamp(0, 100);
      }
      for (int i = 10; i < 16; i++) {
        config[offset + i] = 0;
      }
    }

    return config;
  }

  @override
  void setParameterValue(Parameter param, double value, {bool notify = true}) {
    param.value = value;
    if (notify) {
      if (param.midiCC == -1) {
        if (device.communication is NamProCommunication) {
          (device.communication as NamProCommunication)
              .sendNfPayload(generateNfPayload());
        }
      } else {
        device.parameterChanged.add(param);
      }
    }
  }

  @override
  void swapProcessorSlots(int from, int to, notifyBT) {
    var fxFrom = processorAtSlot[from];

    for (int i = from; i < device.effectsChainLength - 1; i++) {
      processorAtSlot[i] = processorAtSlot[i + 1];
    }

    for (int i = device.effectsChainLength - 1; i > to; i--) {
      processorAtSlot[i] = processorAtSlot[i - 1];
    }

    processorAtSlot[to] = fxFrom;
    super.swapProcessorSlots(from, to, notifyBT);
  }

  @override
  void setupPresetFromNuxDataArray(List<int> nuxData) {
    if (nuxData.length < 10) return;

    var loadedPreset = hex.encode(nuxData);
    NuxDeviceControl.instance().diagData.lastNuxPreset = loadedPreset;
    NuxDeviceControl.instance().updateDiagnosticsData(nuxPreset: loadedPreset);

    for (int i = 0; i < PresetDataIndexPlugPro.effectTypesIndex.length; i++) {
      int nuxSlot = PresetDataIndexPlugPro.effectTypesIndex[i];
      NuxFXID fxid = NuxFXID.fromInt(nuxSlot);

      int effectParam = nuxData[nuxSlot];
      int rawEffectIndex = effectParam & 0x3f;
      bool effectOn = (effectParam & 0x40) == 0;

      int effectIndex = getEffectArrayIndexFromNuxIndex(fxid, rawEffectIndex);
      int? slot = getSlotFromFXID(fxid);

      if (slot != null) {
        setSelectedEffectForSlot(slot, effectIndex, false);
        setSlotEnabled(slot, effectOn, false);
      }

      var fxList = getEffectsForFXID(fxid);
      if (effectIndex >= 0 && effectIndex < fxList.length) {
        fxList[effectIndex].setupFromNuxPayload(nuxData);
      }
    }

    if (nuxData.length > PresetDataIndexPlugPro.MASTER) {
      setVolumeRaw(nuxData[PresetDataIndexPlugPro.MASTER]);
    }

    int posA = processorAtSlot.indexOf(MightyNamFXID.fxA);
    int posB = processorAtSlot.indexOf(MightyNamFXID.fxB);
    if (posA == -1) posA = 2;
    if (posB == -1) posB = 3;

    List<NuxFXID> stockOrder = [];
    int start = PresetDataIndexPlugPro.LINK1;
    if (nuxData.length > start) {
      for (int i = 0; i < 3; i++) {
        if (!PresetDataIndexPlugPro.effectTypesIndex.contains(nuxData[start])) {
          start++;
        }
      }
      for (int i = 0; i < 9; i++) {
        if (start + i < nuxData.length) {
          var fxid = NuxFXID.fromInt(nuxData[start + i]);
          if (device.getProcessorInfoByFXID(fxid) != null) {
            stockOrder.add(fxid);
          }
        }
      }
    }

    if (stockOrder.length < 9) {
      for (var defaultFxid in PresetDataIndexPlugPro.defaultEffects) {
        if (!stockOrder.contains(defaultFxid)) {
          stockOrder.add(defaultFxid);
        }
      }
    }

    processorAtSlot.clear();
    processorAtSlot.addAll(stockOrder);
    if (posA <= posB) {
      processorAtSlot.insert(
          posA.clamp(0, processorAtSlot.length), MightyNamFXID.fxA);
      processorAtSlot.insert(
          posB.clamp(0, processorAtSlot.length), MightyNamFXID.fxB);
    } else {
      processorAtSlot.insert(
          posB.clamp(0, processorAtSlot.length), MightyNamFXID.fxB);
      processorAtSlot.insert(
          posA.clamp(0, processorAtSlot.length), MightyNamFXID.fxA);
    }
  }

  void applyNfPayload(List<int> config32) {
    if (config32.length < 32) return;

    final int rawA = config32[0];
    final int newSelectedA = (rawA - 1).clamp(0, _fxAList.length - 1);
    selectedFxA = newSelectedA;
    fxAEnabled = config32[1] == 1;
    (_fxAList[selectedFxA] as NamExtraFX)
        .setupFromNfPayload(config32.sublist(0, 16));

    final int rawB = config32[16];
    final int newSelectedB = (rawB - 1).clamp(0, _fxBList.length - 1);
    selectedFxB = newSelectedB;
    fxBEnabled = config32[17] == 1;
    (_fxBList[selectedFxB] as NamExtraFX)
        .setupFromNfPayload(config32.sublist(16, 32));

    final int reportedPosA = config32[2];
    final int reportedPosB = config32[18];

    final int currentPosA = processorAtSlot.indexOf(MightyNamFXID.fxA);
    final int currentPosB = processorAtSlot.indexOf(MightyNamFXID.fxB);

    if (reportedPosA != currentPosA || reportedPosB != currentPosB) {
      processorAtSlot.remove(MightyNamFXID.fxA);
      processorAtSlot.remove(MightyNamFXID.fxB);

      if (reportedPosA <= reportedPosB) {
        processorAtSlot.insert(
            reportedPosA.clamp(0, processorAtSlot.length), MightyNamFXID.fxA);
        processorAtSlot.insert(
            reportedPosB.clamp(0, processorAtSlot.length), MightyNamFXID.fxB);
      } else {
        processorAtSlot.insert(
            reportedPosB.clamp(0, processorAtSlot.length), MightyNamFXID.fxB);
        processorAtSlot.insert(
            reportedPosA.clamp(0, processorAtSlot.length), MightyNamFXID.fxA);
      }
    }
  }

  @override
  List<int> createNuxDataFromPreset() {
    _ensureCustomBlocks();
    List<int> data = List.filled(qrDataLength, 0);
    List<int> qrData = [];
    qrData.add(device.deviceQRId);
    qrData.add(device.deviceQRVersion);

    data[PresetDataIndexPlugPro.MASTER] =
        device.decibelFormatter!.valueToMidi7Bit(volume);

    for (int i = 0; i < PresetDataIndexPlugPro.effectTypesIndex.length; i++) {
      var nuxSlot = PresetDataIndexPlugPro.effectTypesIndex[i];
      NuxFXID fxid = NuxFXID.fromInt(nuxSlot);
      var slot = getSlotFromFXID(fxid);

      if (slot != null) {
        var effects = getEffectsForFXID(fxid);
        var selected = getSelectedEffectForSlot(slot);

        if (selected >= 0 && selected < effects.length) {
          effects[selected].getNuxPayload(data, slotEnabled(slot));
        }
      }
    }

    int start = PresetDataIndexPlugPro.LINK1;
    int written = 0;
    for (int i = 0; i < processorAtSlot.length; i++) {
      if (processorAtSlot[i] != MightyNamFXID.fxA &&
          processorAtSlot[i] != MightyNamFXID.fxB) {
        if (written < 9) {
          data[start + written] = processorAtSlot[i].toInt();
          written++;
        }
      }
    }

    qrData.addAll(data);
    return qrData;
  }
}