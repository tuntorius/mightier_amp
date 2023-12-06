// (c) 2020-2021 Dian Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/liteMk2Communication.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/liteMk2/delay.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/liteMk2/efx.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/liteMk2/reverb.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/preset_constants.dart';

import '../NuxConstants.dart';
import '../NuxDevice.dart';
import '../NuxFXID.dart';
import '../NuxMightyLiteMk2.dart';
import '../communication/plugProCommunication.dart';
import '../effects/Processor.dart';
import '../effects/NoiseGate.dart';
import '../effects/liteMk2/modulation.dart';
import '../effects/plug_pro/EFX.dart';
import '../effects/plug_pro/Amps.dart';
import '../effects/plug_pro/Cabinet.dart';
import '../effects/plug_pro/Modulation.dart';
import '../effects/plug_pro/Delay.dart';
import '../effects/plug_pro/Reverb.dart';
import 'Preset.dart';

class MightyMk2Preset extends Preset {
  @override
  NuxDevice device;
  @override
  int channel;
  @override
  String channelName;

  @override
  List<Color> get channelColorsList => PresetConstants.channelColorsPro;

  @override
  int get qrDataLength => 113;

  double _volume = 0;

  @override
  double get volume => _volume;

  @override
  set volume(double vol) {
    setVolume(vol, true);
  }

  final NoiseGatePro noiseGate = NoiseGatePro();

  @override
  List<Amplifier> get amplifierList => _amplifierList;
  final List<EFXPro> _efxList = <EFXPro>[];
  final List<Amplifier> _amplifierList = <Amplifier>[];
  final List<CabinetPro> _cabinetList = <CabinetPro>[];
  final List<Modulation> _modulationList = <Modulation>[];
  final List<DelayPro> _delayList = <DelayPro>[];
  final List<Reverb> _reverbList = <Reverb>[];

  @override
  List<Cabinet> get cabinetList => _cabinetList;
  bool noiseGateEnabled = true;
  bool efxEnabled = true;
  bool ampEnabled = true;
  bool cabEnabled = true;
  bool modulationEnabled = true;
  bool delayEnabled = true;
  bool reverbEnabled = true;

  int selectedEfx = 0;
  int selectedAmp = 0;
  int selectedCabinet = 0;
  int selectedMod = 0;
  int selectedDelay = 0;
  int selectedReverb = 0;

  LiteMK2Version version = LiteMK2Version.LiteMK2v1;

  MightyMk2Preset(
      {required this.device, required this.channel, required this.channelName})
      : super(channel: channel, channelName: channelName, device: device) {
    _modulationList.addAll([
      ModCE1(),
      ModCE2(),
      STChorusPro(),
      Vibrato(),
      FlangerLiteMk2(),
      Phase90LiteMk2(),
      Phase100LiteMk2(),
      SCFLiteMk2(),
      VibeLiteMk2(),
      TremoloLiteMk2(),
      SCH1LiteMk2(),
    ]);

    _efxList.addAll([
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
      RoseCompLiteMk2(),
      KCompLiteMk2(),
      TouchWahLiteMk2(),
      TremoloEFXLiteMk2(),
      VibeEFXLiteMk2(),
      PH100LiteMk2()
    ]);

    _amplifierList.addAll([
      JazzClean(),
      DeluxeRvb(),
      BassMate(),
      Tweedy(),
      //this one and VibroKing cause crashes or ear piercing feedbacks
      //TwinRvb(),
      HiWire(),
      CaliCrunch(),
      ClassA15(),
      ClassA30(),
      Plexi100(),
      Plexi45(),
      Brit800(),
      Pl1987x50(),
      Slo100(),
      FiremanHBE(),
      DualRect(),
      DIEVH4(),
      //VibroKing(),
      Budda(),
      MrZ38(),
      SuperRvb(),
      BritBlues(),
      MatchD30(),
      Brit2000(),
      UberHiGain(),
      AGL(),
      MLD(),
      OptimaAir(),
      Stageman(),
    ]);

    _cabinetList.addAll([
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

    //add the user cabs
    for (int i = 0; i < PlugProCommunication.customIRsCount; i++) {
      var userCab = UserCab();
      userCab.setNuxIndex(i + PlugProCommunication.customIRStart + 1);
      if (i == 0) {
        userCab.isSeparator = true;
        userCab.category = "User IRs";
      }
      _cabinetList.add(userCab);
    }

    _delayList.addAll([
      AnalogDelayLiteMk2(),
      DigitalDelayLiteV2(),
      ModDelayLiteMk2(),
      TapeEchoLiteMk2(),
      PhiDelayLiteMk2()
    ]);

    //reverb is available in all presets
    _reverbList.addAll([
      RoomReverbLiteMk2(),
      HallReverbLiteMk2(),
      PlateReverb(),
      SpringReverb(),
      DampReverbLiteMk2()
    ]);
  }

  /// checks if the effect slot can be switched on and off
  @override
  bool slotSwitchable(int index) {
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
      case 2:
        return ampEnabled;
      case 3:
        return cabEnabled;
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
      case 2:
        ampEnabled = value;
        break;
      case 3:
        cabEnabled = value;
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
  @override
  List<Processor> getEffectsForSlot(int slot) {
    switch (slot) {
      case 0:
        return [noiseGate];
      case 1:
        return _efxList;
      case 2:
        return _amplifierList;
      case 3:
        return _cabinetList;
      case 4:
        return _modulationList;
      case 5:
        return _delayList;
      case 6:
        return _reverbList;
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

  @override
  int getEffectArrayIndexFromNuxIndex(NuxFXID fxid, int nuxIndex) {
    List<Processor> list = [];
    list = getEffectsForSlot(fxid.value);

    for (int i = 0; i < list.length; i++) {
      if (list[i].nuxIndex == nuxIndex) return i;
    }

    return 0;
  }

  @override
  Color effectColor(int index) {
    return device.processorList[index].color;
  }

  @override
  setFirmwareVersion(int ver) {
    version = LiteMK2Version.values[ver];
  }

  @override
  void setVolume(double vol, bool btTransmit) {
    _volume = vol;
    if (btTransmit) {
      sendVolume();
    }
  }

  @override
  void sendVolume() {
    (device.communication as LiteMk2Communication)
        .sendChannelVolume(device.decibelFormatter!.valueToMidi7Bit(_volume));
  }

  @override
  void setupPresetFromNuxDataArray(List<int> nuxData) {
    super.setupPresetFromNuxDataArray(nuxData);

    if (nuxData.length > PresetDataIndexPlugPro.MASTER) {
      _volume = device.decibelFormatter!
          .midi7BitToValue(nuxData[PresetDataIndexPlugPro.MASTER]);
    } else {
      debugPrint("Error: master volume outside of preset data!");
    }
  }
}
