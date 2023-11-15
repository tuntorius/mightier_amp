// (c) 2020-2021 Dian Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ui';

import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyBass.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugAir.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/bass_50bt/efx.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/preset_constants.dart';

import '../NuxDevice.dart';
import '../effects/Processor.dart';
import '../effects/NoiseGate.dart';
import '../effects/bass_50bt/modulation.dart';
import '../effects/plug_air/EFX.dart';
import '../effects/plug_air/Amps.dart';
import '../effects/plug_air/Cabinet.dart';
import '../effects/plug_air/Modulation.dart';
import '../effects/plug_air/Reverb.dart';
import 'Preset.dart';

class BassPreset extends Preset {
  @override
  NuxDevice device;
  @override
  int channel;
  @override
  String channelName;

  @override
  List<Color> get channelColorsList {
    return PresetConstants.channelColorsPlug;
  }

  @override
  int get qrDataLength => 33;

  final NoiseGate2Param noiseGate = NoiseGate2Param();

  List<EFX> get efxList => _efxList;
  @override
  List<Amplifier> get amplifierList => _amplifierList;

  @override
  final List<CabinetMP2> cabinetList = <CabinetMP2>[];

  List<Modulation> get modulationList => _modulationList;
  List<Reverb> get reverbList => _reverbList;

  final List<EFX> _efxList = <EFX>[];
  final List<Amplifier> _amplifierList = <Amplifier>[];
  final List<Modulation> _modulationList = <Modulation>[];
  final List<Reverb> _reverbList = <Reverb>[];

  bool noiseGateEnabled = true;
  bool efxEnabled = true;
  bool modulationEnabled = true;
  bool reverbEnabled = true;

  int selectedEfx = 0;
  int selectedAmp = 0;
  int selectedCabinet = 0;
  int selectedMod = 0;
  int selectedReverb = 0;

  BassVersion version = BassVersion.bass1;

  BassPreset(
      {required this.device, required this.channel, required this.channelName})
      : super(channel: channel, channelName: channelName, device: device) {
    //only ph100Bass ready
    _modulationList.addAll([STChorus(), Flanger(), PH100BassMod()]);

    //ready up to phase100
    _efxList
        .addAll([KCompBass(), TouchWahBass(), UniVibeBass(), Phase100Bass()]);

    _amplifierList.addAll([
      MLD(),
      AGL(),
    ]);

    cabinetList.addAll([
      AGLDB810(),
      V1960(),
      A212(),
      BS410(),
      DR112(),
      GB412(),
      JZ120IR(),
      TR212(),
      V412(),
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

    _reverbList.addAll(
        [RoomReverbv2(), HallReverb(), PlateReverbv2(), SpringReverb()]);
  }

  /// checks if the effect slot can be switched on and off
  @override
  bool slotSwitchable(int index) {
    if (index == 2 || index == 3) return false;
    return true;
  }

  //returns whether the specific slot is on or off
  @override
  bool slotEnabled(int index) {
    switch (index) {
      case 0:
        return noiseGateEnabled;
      case 1:
        return efxEnabled;
      case 4:
        return modulationEnabled;
      case 5:
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
        reverbEnabled = value;
        break;
      default:
        return;
    }

    super.setSlotEnabled(index, value, notifyBT);
  }

  //returns list of effects for given slot
  @override
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
        return reverbList;
    }
    return <Processor>[];
  }

  //returns which of the effects is selected for a given slot
  @override
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
        selectedReverb = index;
        break;
    }
    super.setSelectedEffectForSlot(slot, index, notifyBT);
  }

  @override
  Color effectColor(int index) {
    return device.processorList[index].color;
  }

  @override
  setFirmwareVersion(int ver) {}

  @override
  String getAmpNameByNuxIndex(int index, int version) {
    return _amplifierList[index].name;
  }
}
