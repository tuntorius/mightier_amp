// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ui';

import '../NuxDevice.dart';
import '../effects/Processor.dart';
import '../effects/NoiseGate.dart';
import '../effects/lite/Amps.dart';
import '../effects/lite/Modulation.dart';
import '../effects/lite/Ambience.dart';
import 'Preset.dart';

class MLitePreset extends Preset {
  NuxDevice device;
  int channel;
  String channelName;
  Color get channelColor => Preset.channelColors[channel];
  final NoiseGate2Param noiseGate = NoiseGate2Param();
  final List<LiteAmplifier> amplifierList = <LiteAmplifier>[];
  final List<Modulation> modulationList = <Modulation>[];
  final List<Ambience> ambiList = <Ambience>[];

  bool noiseGateEnabled = true;
  bool modulationEnabled = true;
  bool delayEnabled = true;
  bool reverbEnabled = true;

  int selectedAmp = 0;
  int selectedMod = 0;
  int selectedAmbience = 0;

  MLitePreset(
      {required this.device, required this.channel, required this.channelName})
      : super(channel: channel, channelName: channelName, device: device) {
    //modulation is available everywhere
    modulationList.addAll([Phaser(), Chorus(), Tremolo(), Vibe()]);

    amplifierList.addAll([AmpClean()]);

    ambiList.addAll([
      Delay1(),
      Delay2(),
      Delay3(),
      Delay4(),
      RoomReverb(),
      HallReverb(),
      PlateReverb(),
      SpringReverb()
    ]);
  }

  /// checks if the effect slot can be switched on and off
  bool slotSwitchable(int index) {
    if (index == 1) return false;
    return true;
  }

  //returns whether the specific slot is on or off
  bool slotEnabled(int index) {
    switch (index) {
      case 0:
        return noiseGateEnabled;
      case 2:
        return modulationEnabled;
      case 3:
        return delayEnabled;
      case 4:
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
      case 2:
        modulationEnabled = value;
        break;
      case 3:
        delayEnabled = value;
        break;
      case 4:
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
        return amplifierList;
      case 2:
        return modulationList;
      case 3:
        return ambiList;
    }
    return <Processor>[];
  }

  //returns which of the effects is selected for a given slot
  int getSelectedEffectForSlot(int slot) {
    switch (slot) {
      case 0:
        return 0;
      case 1:
        return selectedAmp;
      case 2:
        return selectedMod;
      case 3:
        return selectedAmbience;
      default:
        return 0;
    }
  }

  //sets the effect for the given slot
  @override
  void setSelectedEffectForSlot(int slot, int index, bool notifyBT) {
    switch (slot) {
      case 1:
        selectedAmp = index;
        break;
      case 2:
        selectedMod = index;
        break;
      case 3:
        selectedAmbience = index;
        break;
    }
    super.setSelectedEffectForSlot(slot, index, notifyBT);
  }

  Color effectColor(int index) {
    if (index != 1)
      return device.processorList[index].color;
    else
      return channelColor;
  }

  @override
  setFirmwareVersion(int ver) {}
}
