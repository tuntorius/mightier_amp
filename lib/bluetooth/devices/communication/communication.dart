import 'package:flutter/widgets.dart';

import '../NuxConstants.dart';
import '../NuxDevice.dart';

abstract class DeviceCommunication {
  int get productVID;
  int get vendorID {
    return 8721;
  }

  @protected
  NuxDevice device;
  NuxDeviceConfiguration config;

  DeviceCommunication(NuxDevice _device, NuxDeviceConfiguration _config)
      : device = _device,
        config = _config;
  List<int> createFirmwareMessage();

  List<int> requestPresetByIndex(int index);

  void requestBatteryStatus();

  @protected
  int get connectionSteps;

  @protected
  int currentConnectionStep = 0;

  bool isConnectionReady() {
    return connectionSteps == currentConnectionStep;
  }

  void performNextConnectionStep();

  @protected
  void connectionStepReady() {
    currentConnectionStep++;
    device.deviceControl.onConnectionStepReady();
  }

  void sendSlotEnabledState(int slot) {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    var swIndex = preset
        .getEffectsForSlot(slot)[preset.getSelectedEffectForSlot(slot)]
        .midiCCEnableValue;

    //in midi boolean is 00 and 7f for false and true
    int enabled = preset.slotEnabled(slot) ? 0x7f : 0x00;
    var data = createCCMessage(swIndex, enabled);
    device.deviceControl.sendBLEData(data);
  }

  void sendSlotEffect(int slot, int index) {
    if (!device.deviceControl.isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    var paramIndex = preset
        .getEffectsForSlot(slot)[preset.getSelectedEffectForSlot(slot)]
        .midiCCSelectionValue;
    var data = createCCMessage(paramIndex, index);
    device.deviceControl.sendBLEData(data);
  }

  void saveCurrentPreset();
  void sendSlotOrder() {}

  void sendDrumsEnabled(bool enabled);
  void sendDrumsStyle(int style);
  void sendDrumsLevel(double volume);
  void sendDrumsTempo(double tempo);

  void setEcoMode(bool enable);
  void setBTEq(int eq);
  void setUsbAudioMode(int mode);
  void setUsbInputVolume(int vol);
  void setUsbOutputVolume(int vol);

  void onDataReceive(List<int> data);

  void onDisconnect() {
    currentConnectionStep = 0;
  }

  List<int> setChannel(int channel);

  @protected
  List<int> createCCMessage(int controlNumber, int value) {
    var msg = List<int>.filled(5, 0);
    msg[0] = 0x80;
    msg[1] = 0x80;
    msg[2] = MidiMessageValues.controlChange;
    msg[3] = controlNumber;
    msg[4] = value;
    return msg;
  }

  List<int> createPCMessage(int programNumber) {
    var msg = List<int>.filled(5, 0);
    msg[0] = 0x80;
    msg[1] = 0x80;
    msg[2] = MidiMessageValues.programChange;
    msg[3] = programNumber;
    return msg;
  }

  List<int> createSysExMessage(int deviceMessageId, var data,
      {int sysExMsgId = CherubSysExMessageID.cSysExDeviceSpecMsgID}) {
    List<int> msg = [];

    //create header
    msg.addAll([
      0x80,
      0x80,
      MidiMessageValues.sysExStart,
      0,
      vendorID & 255,
      vendorID >> 8 & 255,
      productVID & 255,
      productVID >> 8 & 255,
      (7 & sysExMsgId) << 4,
      deviceMessageId
    ]);

    //add payload
    if (data is int)
      msg.add(data);
    else
      msg.addAll(data);

    //add termination symbol
    msg.addAll([0x80, MidiMessageValues.sysExEnd]);

    return msg;
  }

  //version for Mighty Plug Pro
  List<int> createSysExMessagePro(
      int privacy, int syxMsgType, int syxDir, List<int> data) {
    List<int> msg = [];
    //create header
    msg.addAll([
      0x80,
      0x80,
      MidiMessageValues.sysExStart,
      0x43,
      0x58,
      privacy,
      syxMsgType,
      syxDir,
    ]);

    msg.addAll(data);
    msg.addAll([0x80, MidiMessageValues.sysExEnd]);

    return msg;
  }

  @protected
  int percentageTo7Bit(double val) {
    return (val / 100 * 127).floor();
  }
}
