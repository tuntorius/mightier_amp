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

  final List<Processor> _fxAList = ProcessorsList.buildExtraFxList();
  final List<Processor> _fxBList = ProcessorsList.buildExtraFxList();

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

    // Insert FX A and FX B at positions 2 and 3 to match the reference topology:
    // [gate, comp, fxA, fxB, drive, nam, cab, eq, mod, delay, reverb]
    if (!processorAtSlot.contains(MightyNamFXID.fxA)) {
      processorAtSlot.insert(2, MightyNamFXID.fxA);
    }
    if (!processorAtSlot.contains(MightyNamFXID.fxB)) {
      processorAtSlot.insert(3, MightyNamFXID.fxB);
    }
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
      return;
    }
    if (proc == MightyNamFXID.fxB) {
      fxBEnabled = value;
      if (notifyBT && device.communication is NamProCommunication) {
        (device.communication as NamProCommunication)
            .sendNfPayload(generateNfPayload());
      }
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
        return efxList; // Preserves all 14 stock drive pedals
      case PresetDataIndexPlugPro.Head_iMOD:
        return modulationList; // Preserves all 14 stock modulations
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

  /// Compiles the 32-byte Faust configuration for FX A (0..15) and FX B (16..31).
  List<int> generateNfPayload() {
    final List<int> config = List<int>.filled(32, 0);

    // Default configuration template matching defaultFx()
    for (int slot = 0; slot < 2; slot++) {
      final int offset = slot * 16;
      config[offset + 0] = slot + 1; // 1 = Pitch, 2 = Auto Wah
      config[offset + 1] = 0;        // Disabled
      config[offset + 2] = slot + 2; // Position: FX A=2, FX B=3 (reference topology)
      config[offset + 3] = 12;       // Pitch 0 semitones
      config[offset + 4] = 100;      // Mix 100%
      config[offset + 5] = 30;       // Rate
      config[offset + 6] = 50;       // Depth
      config[offset + 7] = 0;        // Feedback
      config[offset + 8] = 50;       // Sensitivity
      config[offset + 9] = 50;       // Resonance
    }

    // Map FX A (Bytes 0-15)
    int posA = processorAtSlot.indexOf(MightyNamFXID.fxA);
    if (posA == -1) posA = 2;
    config[0] = _fxAList[selectedFxA].nuxIndex;
    config[1] = fxAEnabled ? 1 : 0;
    config[2] = posA;
    for (var p in _fxAList[selectedFxA].parameters) {
      config[0 + p.devicePresetIndex] = p.midiValue;
    }

    // Map FX B (Bytes 16-31)
    int posB = processorAtSlot.indexOf(MightyNamFXID.fxB);
    if (posB == -1) posB = 3;
    if (posB == posA) {
      posB = (posA == 3) ? 2 : posA + 1;
    }
    config[16] = _fxBList[selectedFxB].nuxIndex;
    config[17] = fxBEnabled ? 1 : 0;
    config[18] = posB;
    for (var p in _fxBList[selectedFxB].parameters) {
      config[16 + p.devicePresetIndex] = p.midiValue;
    }

    return config;
  }

  @override
  void setParameterValue(Parameter param, double value, {bool notify = true}) {
    param.value = value;
    if (notify) {
      if (param.midiCC == -1) {
        // Intercept Faust Extra FX parameter edits and transmit via NF SysEx
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

    // 1. Parse standard 9 NUX slots from the NUX payload
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

    // 2. Preserve relative positions of FX A and FX B
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
          stockOrder.add(NuxFXID.fromInt(nuxData[start + i]));
        }
      }
    }

    // 3. Reconstruct 11-block order with FX A & B inserted at their relative positions
    processorAtSlot.clear();
    processorAtSlot.addAll(stockOrder);
    if (posA <= posB) {
      processorAtSlot.insert(posA.clamp(0, processorAtSlot.length), MightyNamFXID.fxA);
      processorAtSlot.insert(posB.clamp(0, processorAtSlot.length), MightyNamFXID.fxB);
    } else {
      processorAtSlot.insert(posB.clamp(0, processorAtSlot.length), MightyNamFXID.fxB);
      processorAtSlot.insert(posA.clamp(0, processorAtSlot.length), MightyNamFXID.fxA);
    }
  }

  /// Applies a 32-byte NF config payload received from the hardware.
  ///
  /// Bytes 0-15 describe FX A; bytes 16-31 describe FX B.
  /// Layout per slot:
  ///   [0/16] nuxIndex (1-based effect type)
  ///   [1/17] enabled flag (1 = on)
  ///   [2/18] chain position
  ///   [3..15 / 19..31] per-effect parameter values
  void applyNfPayload(List<int> config32) {
    if (config32.length < 32) return;

    // --- FX A (bytes 0-15) ---
    final int rawA = config32[0];
    final int newSelectedA = (rawA - 1).clamp(0, _fxAList.length - 1);
    selectedFxA = newSelectedA;
    fxAEnabled = config32[1] == 1;
    (_fxAList[selectedFxA] as NamExtraFX)
        .setupFromNfPayload(config32.sublist(0, 16));

    // --- FX B (bytes 16-31) ---
    final int rawB = config32[16];
    final int newSelectedB = (rawB - 1).clamp(0, _fxBList.length - 1);
    selectedFxB = newSelectedB;
    fxBEnabled = config32[17] == 1;
    (_fxBList[selectedFxB] as NamExtraFX)
        .setupFromNfPayload(config32.sublist(16, 32));

    // --- Update slot positions from reported chain positions ---
    final int reportedPosA = config32[2];
    final int reportedPosB = config32[18];

    // Only reorder when the firmware reports positions that differ from what
    // we have, and both positions are valid (within the 11-slot chain).
    final int currentPosA = processorAtSlot.indexOf(MightyNamFXID.fxA);
    final int currentPosB = processorAtSlot.indexOf(MightyNamFXID.fxB);

    if (reportedPosA != currentPosA || reportedPosB != currentPosB) {
      // Remove FX A and FX B from wherever they are now.
      processorAtSlot.remove(MightyNamFXID.fxA);
      processorAtSlot.remove(MightyNamFXID.fxB);

      // Re-insert at the firmware-reported positions, clamped to list bounds.
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
    List<int> data = List.filled(qrDataLength, 0);
    List<int> qrData = [];
    qrData.add(device.deviceQRId);
    qrData.add(device.deviceQRVersion);

    data[PresetDataIndexPlugPro.MASTER] =
        device.decibelFormatter!.valueToMidi7Bit(volume);

    // Save stock NUX slots
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

    // Save stock 9-element order to prevent NUX firmware flash corruption
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