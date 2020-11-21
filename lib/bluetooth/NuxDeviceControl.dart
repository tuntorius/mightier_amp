import 'dart:async';
import 'dart:typed_data';

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
    _midiHandler.status.addListener(_statusListener);
    _device = NuxMightyPlug(this);

    device.parameterChangedNotifier.addListener(parameterChangedListener);
    device.presetChangedNotifier.addListener(presetChangedListener);
    device.effectChangedNotifier.addListener(effectChangedListener);
    device.effectSwitchedNotifier.addListener(effectSwitchedListener);
  }

  void _statusListener() {
    switch (_midiHandler.status.value) {
      case midiSetupStatus.deviceFound:
        // check if this is valid nux device
        print("Devices found " + _midiHandler.scanResults.toString());
        _midiHandler.scanResults.forEach((dev) {
          if (dev.device.type != BluetoothDeviceType.classic &&
              dev.advertisementData.localName != null &&
              _devices.contains(dev.advertisementData.localName)) {
            //_device = _devices[dev.name];
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
  void parameterChangedListener() {
    if (_midiHandler.connectedDevice == null) return;
    var param = device.parameterChangedNotifier.value;
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

  void effectSwitchedListener() {
    if (_midiHandler.connectedDevice == null) return;
    var slot = device.effectSwitchedNotifier.value;
    var preset = device.getPresetByNuxIndex(device.selectedChannelNuxIndex);
    var swIndex = preset
        .getEffectsForSlot(slot)[preset.getSelectedEffectForSlot(slot)]
        .deviceSwitchIndex;

    //in midi boolean is 00 and 7f for false and true
    int enabled = preset.slotEnabled(slot) ? 0x7f : 0x00;
    var data = createCCMessage(swIndex, enabled);
    _midiHandler.sendData(data);
  }

  void effectChangedListener() {
    var slot = device.effectChangedNotifier.value;
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
