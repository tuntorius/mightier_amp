// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ui';

import '../NuxConstants.dart';
import '../NuxDevice.dart';
import '../effects/Processor.dart';
import '../effects/EFX.dart';
import '../effects/Amps.dart';
import '../effects/Cabinet.dart';
import '../effects/Modulation.dart';
import '../effects/Delay.dart';
import '../effects/Reverb.dart';

enum Instrument { Guitar, Bass }
enum Channel { Clean, Overdive, Distortion, AGSim, Pop, Rock, Funk }

class Preset {
  static const List<Color> channelColors = [
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 255, 180, 0),
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(230, 230, 230, 255),
    Color.fromARGB(255, 130, 225, 255),
    Color.fromARGB(255, 210, 140, 250),
    Color.fromARGB(255, 71, 167, 245),
  ];

  static int nuxChannel(int instrument, int channel) {
    if (instrument == Instrument.Bass.index) return channel + 4;
    return channel;
  }

  static int normalizedFromNuxChannel(int nuxChannel) {
    if (nuxChannel >= 4) return nuxChannel - 4;
    return nuxChannel;
  }

  static int instrumentFromNuxChannel(int nuxChannel) {
    if (nuxChannel >= 4) return 1;
    return 0;
  }

  NuxDevice device;
  Instrument instrument;
  Channel channel;
  String channelName;
  Color get channelColor => channelColors[channel.index];
  final NoiseGate noiseGate = NoiseGate();
  final List<EFX> efxList = List<EFX>();
  final List<Amplifier> amplifierList = List<Amplifier>();
  final List<Cabinet> cabinetList = List<Cabinet>();
  final List<Modulation> modulationList = List<Modulation>();
  final List<Delay> delayList = List<Delay>();
  final List<Reverb> reverbList = List<Reverb>();

  //nux data
  List<int> nuxData;

  bool noiseGateEnabled = true;
  bool efxEnabled = true;
  // bool ampEnabled = true;
  // bool cabEnabled = true;
  bool modulationEnabled = true;
  bool delayEnabled = true;
  bool reverbEnabled = true;

  int selectedEfx = 0;
  int selectedAmp = 0;
  int selectedCabinet = 0;
  int selectedMod = 0;
  int selectedDelay = 0;
  int selectedReverb = 0;

  Preset({this.device, this.instrument, this.channel, this.channelName}) {
    //clear nux data
    nuxData = List<int>();
    //modulation is available everywhere
    modulationList
        .addAll([Phaser(), Chorus(), STChorus(), Flanger(), Vibe(), Tremolo()]);

    efxList.addAll([
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
      DistOne()
    ]);

    amplifierList.addAll([
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

    delayList.addAll([AnalogDelay(), TapeEcho(), DigitalDelay(), PingPong()]);

    //reverb is available in all presets
    reverbList.addAll([
      RoomReverb(),
      HallReverb(),
      PlateReverb(),
      SpringReverb(),
      ShimmerReverb()
    ]);
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

    if (notifyBT) device.effectSwitched.add(index);
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
        return cabinetList; //cabinets are special
      case 4:
        return modulationList;
      case 5:
        return delayList;
      case 6:
        return reverbList;
    }
    return null;
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
    if (notifyBT) device.effectChanged.add(slot);
  }

  //change a parameter and announce it
  void setParameterValue(Parameter param, double value) {
    param.value = value;

    if (device != null) {
      device.parameterChanged.add(param);
    }
  }

  Color effectColor(int index) {
    if (index != 2)
      return Processor.processorList[index].color;
    else
      return channelColor;
  }

  void resetNuxData() {
    nuxData.clear();
  }

  //receives data chunk from a device
  void addNuxPayloadPiece(List<int> data) {
    nuxData.addAll(data.sublist(4, 16));
  }

  void setupPresetFromNuxData() {
    if (nuxData.length < 10) return;
    for (int i = 0; i < 7; i++) {
      //set proper effect
      int effectIndex = nuxData[PresetDataIndex.effectTypesIndex[i]];
      setSelectedEffectForSlot(i, effectIndex, false);

      //enable/disable effect
      setSlotEnabled(
          i, nuxData[PresetDataIndex.effectEnabledIndex[i]] != 0, false);

      getEffectsForSlot(i)[getSelectedEffectForSlot(i)]
          .setupFromNuxPayload(nuxData);
    }
  }
}
