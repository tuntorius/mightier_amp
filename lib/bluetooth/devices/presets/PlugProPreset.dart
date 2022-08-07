// (c) 2020-2021 Dian Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ui';

import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';

import '../NuxDevice.dart';
import '../effects/Processor.dart';
import '../effects/NoiseGate.dart';
import '../effects/plug_pro/Compressor.dart';
import '../effects/plug_pro/EFX.dart';
import '../effects/plug_pro/Amps.dart';
import '../effects/plug_pro/Cabinet.dart';
import '../effects/plug_pro/Modulation.dart';
import '../effects/plug_pro/Delay.dart';
import '../effects/plug_pro/Reverb.dart';
import '../effects/plug_pro/EQ.dart';
import 'Preset.dart';

class PlugProPreset extends Preset {
  NuxDevice device;
  int channel;
  String channelName;
  Color get channelColor => Preset.channelColors[channel];
  final NoiseGatePro noiseGate = NoiseGatePro();

  final List<Compressor> compressorList = <Compressor>[];
  final List<EFX> efxList = <EFX>[];
  final List<CabinetPro> cabinetList = <CabinetPro>[];
  final List<Modulation> modulationList = <Modulation>[];
  final List<Reverb> reverbList = <Reverb>[];
  final List<Amplifier> amplifierList = <Amplifier>[];
  final List<Delay> delayList = <Delay>[];
  final List<EQ> eqList = <EQ>[];

  List<int> processorAtSlot = [];

  bool noiseGateEnabled = true;
  bool compressorEnabled = true;
  bool efxEnabled = true;
  bool ampEnabled = true;
  bool irEnabled = true;
  bool modulationEnabled = true;
  bool eqEnabled = true;
  bool delayEnabled = true;
  bool reverbEnabled = true;

  int selectedComp = 0;
  int selectedEfx = 0;
  int selectedAmp = 0;
  int selectedCabinet = 0;
  int selectedMod = 0;
  int selectedEQ = 0;
  int selectedDelay = 0;
  int selectedReverb = 0;

  PlugProVersion version = PlugProVersion.PlugPro1;

  PlugProPreset(
      {required this.device, required this.channel, required this.channelName})
      : super(channel: channel, channelName: channelName, device: device) {
    compressorList.addAll([RoseComp(), KComp(), StudioComp()]);

    modulationList.addAll([
      ModCE1(),
      ModCE2(),
      STChorus(),
      Vibrato(),
      Detune(),
      Flanger(),
      Phase90(),
      Phase100(),
      SCF(),
      Vibe(),
      Tremolo(),
      Rotary(),
      SCH1(),
    ]);

    efxList.addAll([
      DistortionPlus(),
      RCBoost(),
      ACBoost(),
      DistOne(),
      TSDrive(),
      BluesDrive(),
      MorningDrive(),
      EatDist(),
      RedDirt(),
      Crunch(),
      MuffFuzz(),
      Katana(),
      STSinger(),
    ]);

    amplifierList.addAll([
      Unknown0(),
      JazzClean(),
      DeluxeRvb(),
      BassMate(),
      Tweedy(),
      Unknown5(),
      HiWire(),
      CaliCrunch(),
      Unknown8(),
      ClassA30(),
      Plexi100(),
      Plexi45(),
      Brit800(),
      Pl1987x50(),
      Slo100(),
      FiremanHBE(),
      DualRect(),
      DIEVH4(),
      Unknown18(),
      Unknown19(),
      MrZ38(),
      SuperRvb(),
      Unknown22(),
      Unknown23(),
      Unknown24(),
      Unknown25(),
      AGL(),
      MLD(),
      OptimaAir(),
      Stageman(),
      Unknown30()
    ]);

    eqList.addAll([EQSixBand(), EQTenBand()]);

    cabinetList.addAll([
      JZ120Pro(),
      DR112Pro(),
      TR212Pro(),
      HIWIRE412(),
      CALI112(),
      A112(),
      GB412Pro(),
      M1960AX(),
      M1960AV(),
      M1960TV(),
      SLO412(),
      FIREMAN412(),
      RECT412(),
      DIE412(),
      MATCH212(),
      UBER412(),
      BS410(),
      A212Pro(),
      M1960AHW(),
      M1936(),
      BUDDA112(),
      Z212(),
      SUPERVERB410(),
      VIBROKING310(),
      AGLDB810(),
      AMPSV212(),
      AMPSV410(),
      AMPSV810(),
      BASSGUY410(),
      EDEN410(),
      MKB410(),
      GHBIRDPro(),
      GJ15Pro(),
      MD45Pro(),
    ]);

    //TODO: add 20 user cabs

    delayList.addAll(
        [AnalogDelay(), DigitalDelay(), ModDelay(), TapeEcho(), PanDelay()]);

    //reverb is available in all presets
    reverbList.addAll([
      RoomReverb(),
      HallReverb(),
      PlateReverb(),
      SpringReverb(),
      ShimmerReverb()
    ]);

    for (int i = 0; i < device.processorList.length; i++)
      processorAtSlot.add(i);
  }

  /// checks if the effect slot can be switched on and off
  bool slotSwitchable(int index) {
    return true;
  }

  //returns whether the specific slot is on or off
  bool slotEnabled(int index) {
    var proc = getProcessorAtSlot(index);
    switch (proc) {
      case 0:
        return noiseGateEnabled;
      case 1:
        return compressorEnabled;
      case 2:
        return efxEnabled;
      case 3:
        return ampEnabled;
      case 4:
        return irEnabled;
      case 5:
        return modulationEnabled;
      case 6:
        return eqEnabled;
      case 7:
        return delayEnabled;
      case 8:
        return reverbEnabled;
      default:
        return true;
    }
  }

  //turns slot on or off
  @override
  void setSlotEnabled(int index, bool value, bool notifyBT) {
    var proc = getProcessorAtSlot(index);
    switch (proc) {
      case 0:
        noiseGateEnabled = value;
        break;
      case 1:
        compressorEnabled = value;
        break;
      case 2:
        efxEnabled = value;
        break;
      case 3:
        ampEnabled = value;
        break;
      case 4:
        irEnabled = value;
        break;
      case 5:
        modulationEnabled = value;
        break;
      case 6:
        eqEnabled = value;
        break;
      case 7:
        delayEnabled = value;
        break;
      case 8:
        reverbEnabled = value;
        break;
      default:
        return;
    }

    super.setSlotEnabled(index, value, notifyBT);
  }

  @override
  int getProcessorAtSlot(int slot) {
    return processorAtSlot[slot];
  }

  @override
  void swapProcessorSlots(int from, int to, notifyBT) {
    var fxFrom = processorAtSlot[from];

    //shift all after 'from' one position to the left
    for (int i = from; i < device.processorList.length - 1; i++)
      processorAtSlot[i] = processorAtSlot[i + 1];

    //shift all at and after 'to' one position to the right to make room
    for (int i = device.processorList.length - 1; i > to; i--)
      processorAtSlot[i] = processorAtSlot[i - 1];

    //place the moved one
    processorAtSlot[to] = fxFrom;

    super.swapProcessorSlots(from, to, notifyBT);
  }

  //returns list of effects for given slot
  List<Processor> getEffectsForSlot(int slot) {
    var proc = getProcessorAtSlot(slot);
    switch (proc) {
      case 0:
        return [noiseGate];
      case 1:
        return compressorList;
      case 2:
        return efxList;
      case 3:
        return amplifierList;
      case 4:
        return cabinetList;
      case 5:
        return modulationList;
      case 6:
        return eqList;
      case 7:
        return delayList;
      case 8:
        return reverbList;
    }
    return <Processor>[];
  }

  //returns which of the effects is selected for a given slot
  int getSelectedEffectForSlot(int slot) {
    var proc = getProcessorAtSlot(slot);
    switch (proc) {
      case 0:
        return 0;
      case 1:
        return selectedComp;
      case 2:
        return selectedEfx;
      case 3:
        return selectedAmp;
      case 4:
        return selectedCabinet;
      case 5:
        return selectedMod;
      case 6:
        return selectedEQ;
      case 7:
        return selectedDelay;
      case 8:
        return selectedReverb;
      default:
        return 0;
    }
  }

  //sets the effect for the given slot
  @override
  void setSelectedEffectForSlot(int slot, int index, bool notifyBT) {
    var proc = getProcessorAtSlot(slot);
    switch (proc) {
      case 1:
        selectedComp = index;
        break;
      case 2:
        selectedEfx = index;
        break;
      case 3:
        selectedAmp = index;
        break;
      case 4:
        selectedCabinet = index;
        break;
      case 5:
        selectedMod = index;
        break;
      case 6:
        selectedEQ = index;
        break;
      case 7:
        selectedDelay = index;
        break;
      case 8:
        selectedReverb = index;
        break;
    }
    super.setSelectedEffectForSlot(slot, index, notifyBT);
  }

  Color effectColor(int index) {
    index = getProcessorAtSlot(index);
    return device.processorList[index].color;
  }

  @override
  setFirmwareVersion(int ver) {
    version = PlugProVersion.values[ver];
  }
}
