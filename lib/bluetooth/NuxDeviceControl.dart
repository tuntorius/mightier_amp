// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

import 'bleMidiHandler.dart';

import 'devices/NuxConstants.dart';
import 'devices/NuxDevice.dart';
import 'devices/effects/Processor.dart';

class NuxDeviceControl {
  static final NuxDeviceControl _nuxDeviceControl = NuxDeviceControl._();

  final BLEMidiHandler _midiHandler = BLEMidiHandler();

  NuxDevice _device;
  StreamSubscription<List<int>> rxSubscription;

  bool _presetsReceived = false;

  final List<String> _devices = ["NUX MIGHTY PLUG MIDI", "NUX MIGHTY AIR MIDI"];
  factory NuxDeviceControl() {
    return _nuxDeviceControl;
  }

  NuxDeviceControl._() {
    _midiHandler.status.listen(_statusListener);
    _device = NuxMightyPlug(this);

    device.presetChangedNotifier.addListener(presetChangedListener);
    device.parameterChanged.stream.listen(parameterChangedListener);
    device.effectChanged.stream.listen(effectChangedListener);
    device.effectSwitched.stream.listen(effectSwitchedListener);
  }

  void _statusListener(statusValue) {
    switch (statusValue) {
      case midiSetupStatus.deviceFound:
        // check if this is valid nux device
        print("Devices found " + _midiHandler.scanResults.toString());
        _midiHandler.scanResults.forEach((dev) {
          if (dev.device.type != BluetoothDeviceType.classic &&
              dev.advertisementData.localName != null &&
              _devices.contains(dev.advertisementData.localName)) {
            //_device = _devices[dev.name];

            //don't autoconnect on auto scan
            if (!_midiHandler.manualScan)
              _midiHandler.connectToDevice(dev.device);
          }
        });
        break;
      case midiSetupStatus.deviceConnected:
        _onConnect();
        break;
      case midiSetupStatus.deviceDisconnected:
        _onDisconnect();
        break;
      default:
        break;
    }
  }

  void _onConnect() {
    print("Mighty plug connected");
    device.resetDrumSettings();
    rxSubscription = _midiHandler.registerDataListener(_onDataReceive);
  }

  void _onDisconnect() {
    rxSubscription.cancel();
    _presetsReceived = false;
    print("Mighty plug disconnected");
  }

  void _onDataReceive(List<int> data) {
    if (data.length < 3) print(data);
    if (data.length > 2)
      _device.onDataReceived(data.sublist(2));
    else if (!_presetsReceived) {
      //ask the presets now
      getPresetDelayed();
      _presetsReceived = true;
    }
  }

  //for some reason we should not ask for presets immediately
  void getPresetDelayed() async {
    await Future.delayed(Duration(seconds: 1));
    getPreset(0);
  }

  void getPreset(int index) {
    var data = createSysExMessage(DeviceMessageID.devReqPresetMsgID, index);

    _midiHandler.sendData(data);
  }

  //preset editing listeners
  void parameterChangedListener(Parameter param) {
    if (_midiHandler.connectedDevice == null) return;
    sendParameter(param, false);
  }

  void presetChangedListener() {
    if (_midiHandler.connectedDevice == null) return;
    changeDevicePreset(device.presetChangedNotifier.value);
  }

  void changeDevicePreset(int preset) {
    if (_midiHandler.connectedDevice == null) return;

    var data = createCCMessage(MidiCCValues.bCC_CtrlType, preset);
    _midiHandler.sendData(data);
  }

  void effectSwitchedListener(int slot) {
    if (_midiHandler.connectedDevice == null) return;
    var preset = device.getPresetByNuxIndex(device.selectedChannelNuxIndex);
    var swIndex = preset
        .getEffectsForSlot(slot)[preset.getSelectedEffectForSlot(slot)]
        .deviceSwitchIndex;

    //in midi boolean is 00 and 7f for false and true
    int enabled = preset.slotEnabled(slot) ? 0x7f : 0x00;
    var data = createCCMessage(swIndex, enabled);
    _midiHandler.sendData(data);
  }

  void effectChangedListener(int slot) {
    sendFullEffectSettings(slot);
  }

  void sendFullEffectSettings(int slot) {
    if (_midiHandler.connectedDevice == null) return;
    var preset = device.getPresetByNuxIndex(device.selectedChannelNuxIndex);
    var effect;
    int index;
    effect =
        preset.getEffectsForSlot(slot)[preset.getSelectedEffectForSlot(slot)];
    index = effect.nuxIndex;
    //List<int> accumData = List<int>();
    //set effect
    if (slot != 0) {
      var data = createCCMessage(effect.deviceSelectionIndex, index);
      //accumData.addAll(data);
      _midiHandler.sendData(data);
    }

    //

    //send parameters
    for (int i = 0; i < effect.parameters.length; i++) {
      sendParameter(effect.parameters[i], false);
      // if (accumData.length > 17) {
      //   _midiHandler.sendData(Uint8List.fromList(accumData));
      //   accumData.clear();
      // }
    }
    //send switched
    if (preset.slotSwitchable(slot)) {
      int enabled = preset.slotEnabled(slot) ? 0x7f : 0x00;
      var data = createCCMessage(effect.deviceSwitchIndex, enabled);
      _midiHandler.sendData(data);
    }
    // if (accumData.length > 0)
    //   _midiHandler.sendData(Uint8List.fromList(accumData));
  }

  List<int> sendParameter(Parameter param, bool returnOnly) {
    int val;
    if (param.valueType == ValueType.db)
      val = dbTo7Bit(param.value);
    else
      val = percentageTo7Bit(param.value);
    var data = createCCMessage(param.midiCC, val);
    if (!returnOnly) _midiHandler.sendData(data);
    return data;
  }

  void saveNuxPreset() {
    if (_midiHandler.connectedDevice == null) return;
    var data = createCCMessage(MidiCCValues.bCC_CtrlCmd, 0x7e);
    _midiHandler.sendData(data);
  }

  void sendDrumsEnabled(bool enabled) {
    if (_midiHandler.connectedDevice == null) return;
    var data =
        createCCMessage(MidiCCValues.bCC_drumOnOff_No, enabled ? 0x7f : 0);
    _midiHandler.sendData(data);
  }

  void sendDrumsStyle(int style) {
    if (_midiHandler.connectedDevice == null) return;
    var data = createCCMessage(MidiCCValues.bCC_drumType_No, style);
    _midiHandler.sendData(data);
  }

  void sendDrumsLevel(int volume) {
    if (_midiHandler.connectedDevice == null) return;
    var data = createCCMessage(MidiCCValues.bCC_drumLevel_No, volume);
    _midiHandler.sendData(data);
  }

  void sendDrumsTempo(double tempo) {
    if (_midiHandler.connectedDevice == null) return;

    int tempoNux = (((tempo - 40) / 200) * 16384).floor();
    //these must be sent as 2 7bit values
    int tempoL = tempoNux & 0x7f;
    int tempoH = (tempoNux >> 7);

    //no idea what the first 2 messages are for
    var data = createCCMessage(MidiCCValues.bCC_drumTempo1, 0x06);
    _midiHandler.sendData(data);
    data = createCCMessage(MidiCCValues.bCC_drumTempo2, 0x26);
    _midiHandler.sendData(data);
    data = createCCMessage(MidiCCValues.bCC_drumTempoH, tempoH);
    _midiHandler.sendData(data);
    data = createCCMessage(MidiCCValues.bCC_drumTempoL, tempoL);
    _midiHandler.sendData(data);
  }

  int percentageTo7Bit(double val) {
    return (val / 100 * 127).floor();
  }

  int dbTo7Bit(double db) {
    return ((db + 6) / 12 * 127).floor();
  }

  List<int> createCCMessage(int controlNumber, int value) {
    var msg = List<int>(5);
    msg[0] = 0x80;
    msg[1] = 0x80;
    msg[2] = MidiMessageValues.controlChange;
    msg[3] = controlNumber;
    msg[4] = value;
    return msg;
  }

  List<int> createSysExMessage(int deviceMessageId, var data,
      {int sysExMsgId = CherubSysExMessageID.cSysExDeviceSpecMsgID}) {
    List<int> msg = List<int>();

    //create header
    msg.addAll([
      0x80,
      0x80,
      MidiMessageValues.sysExStart,
      0,
      device.vendorID & 255,
      device.vendorID >> 8 & 255,
      device.productVID & 255,
      device.productVID >> 8 & 255,
      (7 & sysExMsgId) << 4,
      deviceMessageId
    ]);

    //add payload
    if (data is int)
      msg.add(data);
    else
      msg.addAll(data);

    //add termination symbol
    msg.add(0x80);
    msg.add(MidiMessageValues.sysExEnd);

    return msg;
  }

  NuxDevice get device => _device;
}
