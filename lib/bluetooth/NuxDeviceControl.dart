// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMighty8BT.dart';

import 'bleMidiHandler.dart';

import 'devices/NuxConstants.dart';
import 'devices/NuxDevice.dart';
import 'devices/NuxMightyPlugAir.dart';
import 'devices/effects/Processor.dart';

enum DeviceConnectionState { connectedStart, presetsLoaded, configReceived }

class NuxDeviceControl extends ChangeNotifier {
  static final NuxDeviceControl _nuxDeviceControl = NuxDeviceControl._();

  final BLEMidiHandler _midiHandler = BLEMidiHandler();

  //holds current device
  NuxDevice _device;
  StreamSubscription<List<int>> rxSubscription;
  Timer batteryTimer;

  //connect status control
  final StreamController<DeviceConnectionState> connectStatus =
      StreamController();
  final StreamController<int> batteryPercentage = StreamController<int>();

  bool get isConnected => _midiHandler.connectedDevice != null;

  final List<String> _devices = [
    "NUX MIGHTY PLUG MIDI",
    "NUX MIGHTY AIR MIDI",
    "NUX MIGHTY8BT MIDI", //this one and below are experimental
    "NUX MIGHTY20BT MIDI",
    "GUO AN MIDI",
    "MIGHTY BASS MIDI",
    "NUX MIGHTY GO MIDI",
    "NUX MIGHTY LITE MIDI",
    "AirBorne GO"
  ];

  List<NuxDevice> _deviceInstances = <NuxDevice>[];

  NuxDevice bleNameToInstance(String bleName) {
    if (!_devices.contains(bleName))
      throw UnsupportedError("Device with BLE name $bleName unsupported");

    switch (_devices.indexOf(bleName)) {
      case 0:
        return NuxMightyPlug(this);
      case 1:
        return NuxMightyAir(this);
      case 2:
        return NuxMighty8BT(this);
      default:
        return null;
    }
  }

  factory NuxDeviceControl() {
    return _nuxDeviceControl;
  }

  NuxDeviceControl._() {
    _midiHandler.status.listen(_statusListener);

    //create all supported devices
    for (int i = 0; i < _devices.length; i++) {
      var dev = bleNameToInstance(_devices[i]);
      if (dev != null) {
        _deviceInstances.add(dev);

        _deviceInstances[i]
            .presetChangedNotifier
            .addListener(presetChangedListener);
        _deviceInstances[i]
            .parameterChanged
            .stream
            .listen(parameterChangedListener);
        _deviceInstances[i].effectChanged.stream.listen(effectChangedListener);
        _deviceInstances[i]
            .effectSwitched
            .stream
            .listen(effectSwitchedListener);
      }
    }

    //just a test
    _device = _deviceInstances[2];
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
            //don't autoconnect on manual scan
            if (!_midiHandler.manualScan) {
              _midiHandler.connectToDevice(dev.device);
            }
          }
        });
        break;
      case midiSetupStatus.deviceConnected:
        //which device connected?
        //find which device connected
        print("${_midiHandler.connectedDevice.name} connected");
        int devIndex = _devices.indexOf(_midiHandler.connectedDevice.name);
        _device = _deviceInstances[devIndex];
        notifyListeners();
        _onConnect();
        break;
      case midiSetupStatus.deviceDisconnected:
        _device = _deviceInstances[2]; //TODO: JAT JUST A TEST
        notifyListeners();
        _onDisconnect();
        break;
      default:
        break;
    }
  }

  void _onConnect() {
    print("Device connected");
    device.onConnect();
    connectStatus.add(DeviceConnectionState.connectedStart);
    rxSubscription = _midiHandler.registerDataListener(_onDataReceive);
  }

  void _onDisconnect() {
    batteryTimer?.cancel();
    rxSubscription?.cancel();
    device.onDisconnect();
    print("Device disconnected");
  }

  void _onDataReceive(List<int> data) {
    if (data.length > 2)
      _device.onDataReceived(data.sublist(2));
    else if (!_device.nuxPresetsReceived) {
      //ask the presets now
      requestPresetDelayed();
    }
  }

  void _onBatteryTimer(Timer timer) {
    var data = createSysExMessage(DeviceMessageID.devSysCtrlMsgID,
        [SysCtrlState.syscmd_dsprun_battery, 0, 0, 0, 0]);
    _midiHandler.sendData(data);
  }

  //for some reason we should not ask for presets immediately
  void requestPresetDelayed() async {
    await Future.delayed(Duration(seconds: 1));
    requestPreset(0);
  }

  void requestPreset(int index) {
    var data = createSysExMessage(DeviceMessageID.devReqPresetMsgID, index);

    _midiHandler.sendData(data);
  }

  void onPresetsReady() async {
    batteryTimer = Timer.periodic(Duration(seconds: 15), _onBatteryTimer);
    _onBatteryTimer(null);
    print("Presets received");

    connectStatus.add(DeviceConnectionState.presetsLoaded);
    await Future.delayed(Duration(milliseconds: 200));
    //request other nux stuff

    //eco mode and other
    var data = createSysExMessage(DeviceMessageID.devReqManuMsgID, [0]);
    _midiHandler.sendData(data);
    //_midiHandler.sendData(data);
    //_midiHandler.sendData(data);

    await Future.delayed(Duration(milliseconds: 200));
    //usb settings. Send them 3 times as the module does not respond everytime.
    // This is what their software is doing)
    data = createSysExMessage(DeviceMessageID.devSysCtrlMsgID,
        [SysCtrlState.syscmd_usbaudio, 0, 0, 0, 0]);
    _midiHandler.sendData(data);
    //_midiHandler.sendData(data);
    //_midiHandler.sendData(data);

    //fw version
    //data = createSysExMessage(DeviceMessageID.devSysCtrlMsgID, [0, 0]);
    //_midiHandler.sendData(data);
  }

  void onConfigReceived() {
    connectStatus.add(DeviceConnectionState.configReceived);
  }

  void onBatteryPercentage(int val) {
    batteryPercentage.add(val);
  }

  void setEcoMode(bool enable) {
    var data = createSysExMessage(DeviceMessageID.devSysCtrlMsgID,
        [SysCtrlState.syscmd_eco_pro, enable ? 1 : 0, 0, 0, 0]);
    _midiHandler.sendData(data);
  }

  void setBtEq(int eq) {
    var data = createSysExMessage(
        DeviceMessageID.devSysCtrlMsgID, [SysCtrlState.syscmd_bt, 1, eq, 0, 0]);
    _midiHandler.sendData(data);
  }

  void setUsbAudioMode(int mode) {
    var data = createCCMessage(MidiCCValues.bCC_VolumePedalMin, mode);
    _midiHandler.sendData(data);
  }

  void setUsbInputVolume(int vol) {
    var data = createCCMessage(
        MidiCCValues.bCC_VolumePedal, percentageTo7Bit(vol.toDouble()));
    _midiHandler.sendData(data);
  }

  void setUsbOutputVolume(int vol) {
    var data = createCCMessage(
        MidiCCValues.bCC_VolumePrePost, percentageTo7Bit(vol.toDouble()));
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
    var preset = device.getPreset(device.selectedChannel);
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
    var preset = device.getPreset(device.selectedChannel);
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
    requestPreset(device.selectedChannel);
  }

  void resetNuxPresets() {
    if (_midiHandler.connectedDevice == null) return;
    var data = createCCMessage(MidiCCValues.bCC_CtrlCmd, 0x7f);
    _midiHandler.sendData(data);

    //show loading popup
    connectStatus.add(DeviceConnectionState.connectedStart);

    requestPresetDelayed();
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
    var msg = List<int>.filled(5, 0);
    msg[0] = 0x80;
    msg[1] = 0x80;
    msg[2] = MidiMessageValues.controlChange;
    msg[3] = controlNumber;
    msg[4] = value;
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
