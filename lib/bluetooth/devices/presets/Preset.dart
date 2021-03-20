// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ui';

import '../effects/plug_air/Amps.dart';

import '../NuxConstants.dart';
import '../NuxDevice.dart';
import '../effects/Processor.dart';

abstract class Preset {
  static const List<Color> channelColors = [
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 255, 180, 0),
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(230, 230, 230, 255),
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

  Preset({this.device, this.channel, this.channelName});

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

  //change a parameter and announce it
  void setParameterValue(Parameter param, double value) {
    param.value = value;

    if (device != null) {
      device.parameterChanged.add(param);
    }
  }

  Color effectColor(int index);

  void resetNuxData() {
    nuxData.clear();
  }

  //receives data chunk from a device
  void addNuxPayloadPiece(List<int> data) {
    nuxData.addAll(data);
  }

  void setupPresetFromNuxData() {
    if (nuxData.length < 10) return;
    for (int i = 0; i < device.effectsChainLength; i++) {
      //set proper effect
      int effectIndex = nuxData[PresetDataIndexPlugAir.effectTypesIndex[i]];
      setSelectedEffectForSlot(i, effectIndex, false);

      //enable/disable effect
      setSlotEnabled(
          i, nuxData[PresetDataIndexPlugAir.effectEnabledIndex[i]] != 0, false);

      getEffectsForSlot(i)[getSelectedEffectForSlot(i)]
          .setupFromNuxPayload(nuxData);
    }
  }
}
