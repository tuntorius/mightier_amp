// (c) 2020-2021 Dian Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ui';

import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugAir.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/plug_air/Ampsv2.dart';

import '../NuxDevice.dart';
import '../effects/Processor.dart';
import '../effects/NoiseGate.dart';
import '../effects/plug_air/EFX.dart';
import '../effects/plug_air/EFXv2.dart';
import '../effects/plug_air/Amps.dart';
import '../effects/plug_air/Cabinet.dart';
import '../effects/plug_air/Modulation.dart';
import '../effects/plug_air/Delay.dart';
import '../effects/plug_air/Reverb.dart';
import 'Preset.dart';

class PlugAirPreset extends Preset {
  NuxDevice device;
  int channel;
  String channelName;
  Color get channelColor => Preset.channelColors[channel];
  final NoiseGate2Param noiseGate = NoiseGate2Param();

  List<EFX> get efxList =>
      version == PlugAirVersion.PlugAir21 ? efxListv2 : efxListv1;
  List<Amplifier> get amplifierList =>
      version == PlugAirVersion.PlugAir21 ? amplifierListv2 : amplifierListv1;
  final List<Cabinet> cabinetList = <Cabinet>[];
  List<Modulation> get modulationList =>
      version == PlugAirVersion.PlugAir21 ? modulationListv2 : modulationListv1;
  List<Delay> get delayList =>
      version == PlugAirVersion.PlugAir21 ? delayList2 : delayList1;
  List<Reverb> get reverbList =>
      version == PlugAirVersion.PlugAir21 ? reverbListv2 : reverbListv1;

  final List<EFX> efxListv1 = <EFX>[];
  final List<EFX> efxListv2 = <EFX>[];

  final List<Amplifier> amplifierListv1 = <Amplifier>[];
  final List<Amplifier> amplifierListv2 = <Amplifier>[];

  final List<Modulation> modulationListv1 = <Modulation>[];
  final List<Modulation> modulationListv2 = <Modulation>[];

  final List<Delay> delayList1 = <Delay>[];
  final List<Delay> delayList2 = <Delay>[];

  final List<Reverb> reverbListv1 = <Reverb>[];
  final List<Reverb> reverbListv2 = <Reverb>[];

  bool noiseGateEnabled = true;
  bool efxEnabled = true;
  bool modulationEnabled = true;
  bool delayEnabled = true;
  bool reverbEnabled = true;

  int selectedEfx = 0;
  int selectedAmp = 0;
  int selectedCabinet = 0;
  int selectedMod = 0;
  int selectedDelay = 0;
  int selectedReverb = 0;

  PlugAirVersion version = PlugAirVersion.PlugAir15;

  PlugAirPreset(
      {required this.device, required this.channel, required this.channelName})
      : super(channel: channel, channelName: channelName, device: device) {
    modulationListv1
        .addAll([Phaser(), Chorus(), STChorus(), Flanger(), Vibe(), Tremolo()]);
    modulationListv2
        .addAll([PH100(), Chorus(), STChorus(), SCF(), Vibe(), Tremolo()]);

    efxListv1.addAll([
      TouchWah(),
      UniVibe(),
      TremoloEFX(),
      PhaserEFX(),
      Boost(),
      TSDrive(),
      BassTS(),
      ThreeBandEQ(),
      Muff(),
      Crunch(),
      RedDist(),
      MorningDrive(),
      DistOne(),
    ]);

    efxListv2.addAll([
      TouchWah(),
      UniVibe(),
      TremoloEFX(),
      PH100EFX(),
      STSinger(),
      TSDrive(),
      Katana(),
      ThreeBandEQ(),
      Muff(),
      Crunch(),
      RedDirt(),
      MorningDrive(),
      DistOne(),
      RoseComp()
    ]);

    amplifierListv1.addAll([
      TwinVerb(),
      JZ120(),
      TweedDlx(),
      Plexi(),
      TopBoost(),
      Lead100(),
      Fireman(),
      DIEVH4(),
      Recto(),
      Optima(),
      Stageman(),
      MLD(),
      AGL()
    ]);

    amplifierListv2.addAll([
      JazzClean(),
      DeluxeRvb(),
      TwinRvbV2(),
      ClassA30(),
      Brit800(),
      Plexi1987x50(),
      FiremanHBE(),
      DualRect(),
      DIEVH4v2(),
      AGLv2(),
      Starlift(),
      MLDv2(),
      Stagemanv2(),
    ]);

    cabinetList.addAll([
      V1960(),
      A212(),
      BS410(),
      DR112(),
      GB412(),
      JZ120IR(),
      TR212(),
      V412(),
      AGLDB810(),
      AMPSV810(),
      MKB410(),
      TRC410(),
      GHBird(),
      GJ15(),
      MD45(),
      GIBJ200(),
      GIBJ45(),
      TL314(),
      MHD28()
    ]);

    delayList1.addAll([AnalogDelay(), TapeEcho(), DigitalDelay(), PingPong()]);
    delayList2
        .addAll([AnalogDelay(), DigitalDelayv2(), ModDelay(), PingPong()]);

    //reverb is available in all presets
    reverbListv1.addAll([
      RoomReverb(),
      HallReverb(),
      PlateReverb(),
      SpringReverb(),
      ShimmerReverb()
    ]);

    reverbListv2.addAll(
        [RoomReverbv2(), HallReverbv2(), PlateReverbv2(), SpringReverb()]);
  }

  /// checks if the effect slot can be switched on and off
  bool slotSwitchable(int index) {
    if (index == 2 || index == 3) return false;
    return true;
  }

  //returns whether the specific slot is on or off
  bool slotEnabled(int index) {
    switch (index) {
      case 0:
        return noiseGateEnabled;
      case 1:
        return efxEnabled;
      case 4:
        return modulationEnabled;
      case 5:
        return delayEnabled;
      case 6:
        return reverbEnabled;
      default:
        return true;
    }
  }

  //turns slot on or off
  @override
  void setSlotEnabled(int index, bool value, bool notifyBT) {
    switch (index) {
      case 0:
        noiseGateEnabled = value;
        break;
      case 1:
        efxEnabled = value;
        break;
      case 4:
        modulationEnabled = value;
        break;
      case 5:
        delayEnabled = value;
        break;
      case 6:
        reverbEnabled = value;
        break;
      default:
        return;
    }

    super.setSlotEnabled(index, value, notifyBT);
  }

  //returns list of effects for given slot
  List<Processor> getEffectsForSlot(int slot) {
    switch (slot) {
      case 0:
        return [noiseGate];
      case 1:
        return efxList;
      case 2:
        return amplifierList;
      case 3:
        return cabinetList;
      case 4:
        return modulationList;
      case 5:
        return delayList;
      case 6:
        return reverbList;
    }
    return <Processor>[];
  }

  //returns which of the effects is selected for a given slot
  int getSelectedEffectForSlot(int slot) {
    switch (slot) {
      case 0:
        return 0;
      case 1:
        return selectedEfx;
      case 2:
        return selectedAmp;
      case 3:
        return selectedCabinet;
      case 4:
        return selectedMod;
      case 5:
        return selectedDelay;
      case 6:
        return selectedReverb;
      default:
        return 0;
    }
  }

  //sets the effect for the given slot
  @override
  void setSelectedEffectForSlot(int slot, int index, bool notifyBT) {
    switch (slot) {
      case 1:
        selectedEfx = index;
        break;
      case 2:
        selectedAmp = index;
        break;
      case 3:
        selectedCabinet = index;
        break;
      case 4:
        selectedMod = index;
        break;
      case 5:
        selectedDelay = index;
        break;
      case 6:
        selectedReverb = index;
        break;
    }
    super.setSelectedEffectForSlot(slot, index, notifyBT);
  }

  Color effectColor(int index) {
    if (index != 2)
      return device.processorList[index].color;
    else
      return channelColor;
  }

  @override
  setFirmwareVersion(int ver) {
    version = PlugAirVersion.values[ver];
  }
}
