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

  DeviceCommunication(NuxDevice _device) : device = _device;
  List<int> createFirmwareMessage();

  List<int> requestPresetByIndex(int index);
  List<int> requestIRName(int index);

  void requestBatteryStatus();

  void requestPrimaryData();
  void requestSecondaryData();

  void sendSlotEnabledState(int slot);
  void setSlotEffect(int slot, int index);

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

  void onDisconnect();

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
  List<int> createSysexMessage(
      SysexPrivacy privacy, SyxMsg msgType, SyxDir dir, List<int> data) {
    List<int> msg = [];
    //create header
    msg.addAll([
      0x80,
      0x80,
      MidiMessageValues.sysExStart,
      0x43,
      0x58,
      privacy.toInt(),
      msgType.toInt(),
      dir.index,
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
