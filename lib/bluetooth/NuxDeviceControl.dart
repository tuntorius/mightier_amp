// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMighty8BT.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:undo/undo.dart';

import 'bleMidiHandler.dart';

import 'devices/NuxConstants.dart';
import 'devices/NuxDevice.dart';
import 'devices/NuxMighty2040BT.dart';
import 'devices/NuxMightyLite.dart';
import 'devices/NuxMightyPlugAir.dart';
import 'devices/NuxMightyPlugPro.dart';
import 'devices/effects/Processor.dart';

enum DeviceConnectionState {
  connectionBegin,
  presetsLoaded,
  connectionComplete
}

class NuxDiagnosticData {
  String device = "";
  bool connected = false;
  String lastNuxPreset = "";

  Map<String, dynamic> toMap(bool includeJsonPreset) {
    var data = Map<String, dynamic>();
    data['device'] = device;
    data['connected'] = connected;
    data['lastNuxPreset'] = lastNuxPreset;

    if (includeJsonPreset)
      data['jsonPreset'] = NuxDeviceControl.instance().device.presetToJson();

    return data;
  }
}

class NuxDeviceControl extends ChangeNotifier {
  static final NuxDeviceControl _nuxDeviceControl = NuxDeviceControl._();

  final BLEMidiHandler _midiHandler = BLEMidiHandler.instance();

  factory NuxDeviceControl.instance() {
    return _nuxDeviceControl;
  }

  NuxDiagnosticData diagData = NuxDiagnosticData();

  //holds current device
  late NuxDevice _device;
  StreamSubscription<List<int>>? rxSubscription;
  Timer? batteryTimer;

  double _masterVolume = 100;

  var changes = ChangeStack();

  bool developer = false;
  Function(List<int>)? onDataReceiveDebug;

  double get masterVolume => _masterVolume;
  set masterVolume(double vol) {
    _masterVolume = vol;
    if (isConnected) {
      device.sendAmpLevel();
    }
  }

  //connect status control
  final StreamController<DeviceConnectionState> connectStatus =
      StreamController();
  final StreamController<int> batteryPercentage =
      StreamController<int>.broadcast();

  bool get isConnected => _midiHandler.connectedDevice != null;

  //list of all different nux devices
  List<NuxDevice> _deviceInstances = <NuxDevice>[];

  List<NuxDevice> get deviceList => _deviceInstances;

  List<String> deviceBLEName() {
    var names = <String>[];
    for (int i = 0; i < _deviceInstances.length; i++)
      names.addAll(_deviceInstances[i].productBLENames);
    return names;
  }

  List<String> get deviceNameList {
    var names = <String>[];
    for (int i = 0; i < _deviceInstances.length; i++)
      names.add(_deviceInstances[i].productNameShort);
    return names;
  }

  int get deviceIndex {
    for (int i = 0; i < _deviceInstances.length; i++)
      if (_device == _deviceInstances[i]) return i;
    return 0;
  }

  set deviceIndex(int index) {
    clearUndoStack();
    _device = _deviceInstances[index];

    updateDiagnosticsData();
    SharedPrefs().setValue(SettingsKeys.device, _device.productStringId);
    SharedPrefs().setValue(SettingsKeys.deviceVersion, _device.productVersion);
    notifyListeners();
  }

  List<String> get deviceVersionsList {
    var names = <String>[];
    for (int i = 0; i < device.getAvailableVersions(); i++)
      names.add(device.getProductNameVersion(i));
    return names;
  }

  int get deviceFirmwareVersion => device.productVersion;

  set deviceFirmwareVersion(int ver) {
    clearUndoStack();
    device.setFirmwareVersionByIndex(ver);
    SharedPrefs().setValue(SettingsKeys.deviceVersion, ver);
  }

  NuxDevice deviceFromBLEId(String id) {
    for (int i = 0; i < _deviceInstances.length; i++)
      if (_deviceInstances[i].productBLENames.contains(id))
        return _deviceInstances[i];

    //return plug/air by default
    return _deviceInstances[0];
  }

  String getDeviceNameFromId(String id) {
    for (int i = 0; i < _deviceInstances.length; i++) {
      if (_deviceInstances[i].productStringId == id)
        return _deviceInstances[i].productNameShort;
    }
    return "Unknown";
  }

  NuxDevice? getDeviceFromId(String id) {
    for (int i = 0; i < _deviceInstances.length; i++) {
      if (_deviceInstances[i].productStringId == id) return _deviceInstances[i];
    }
    return null;
  }

  clearUndoStack() {
    changes.clearHistory();
    notifyListeners();
  }

  undoStackChanged() {
    notifyListeners();
  }

  forceNotifyListeners() {
    notifyListeners();
  }

  factory NuxDeviceControl() {
    return _nuxDeviceControl;
  }

  NuxDeviceControl._() {
    masterVolume = SharedPrefs().getValue(SettingsKeys.masterVolume, 100.0);

    _midiHandler.setAmpDeviceIdProvider(deviceBLEName);
    _midiHandler.status.listen(_statusListener);

    //create all supported devices
    _deviceInstances.add(NuxMightyPlug(this));
    _deviceInstances.add(NuxMightyPlugPro(this));
    _deviceInstances.add(NuxMighty8BT(this));
    _deviceInstances.add(NuxMighty2040BT(this));
    _deviceInstances.add(NuxMightyLite(this));

    //make it read from config
    String _dev = SharedPrefs()
        .getValue(SettingsKeys.device, _deviceInstances[0].productStringId);

    _device = getDeviceFromId(_dev) ?? _deviceInstances[0];

    int ver = SharedPrefs().getValue(
        SettingsKeys.deviceVersion, _device.getAvailableVersions() - 1);
    _device.setFirmwareVersionByIndex(ver);

    updateDiagnosticsData(connected: false);

    for (int i = 0; i < _deviceInstances.length; i++) {
      var dev = _deviceInstances[i];
      dev.presetChangedNotifier.addListener(presetChangedListener);
      dev.parameterChanged.stream.listen(parameterChangedListener);
      _deviceInstances[i].effectChanged.stream.listen(effectChangedListener);
      _deviceInstances[i].effectSwitched.stream.listen(effectSwitchedListener);
      _deviceInstances[i].slotSwapped.stream.listen(slotSwappedListener);
    }
  }

  void _statusListener(statusValue) {
    switch (statusValue) {
      case MidiSetupStatus.deviceFound:
        // check if this is valid nux device
        print("Devices found " + _midiHandler.nuxDevices.toString());
        _midiHandler.nuxDevices.forEach((dev) {
          if (dev.device.type != BluetoothDeviceType.classic) {
            //don't autoconnect on manual scan
            if (!_midiHandler.manualScan) {
              _midiHandler.connectToDevice(dev.device);
            }
          }
        });
        break;
      case MidiSetupStatus.deviceConnected:
        clearUndoStack();

        //find which device connected
        if (isConnected) {
          print("${_midiHandler.connectedDevice!.name} connected");
          _device = deviceFromBLEId(_midiHandler.connectedDevice!.name);

          updateDiagnosticsData(connected: true);
          SharedPrefs().setValue(SettingsKeys.device, _device.productStringId);
          //can't set version yet, firmware is unknown
          notifyListeners();
          _onConnect();
        }
        break;
      case MidiSetupStatus.deviceDisconnected:
        clearUndoStack();
        updateDiagnosticsData(connected: false);
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
    connectStatus.add(DeviceConnectionState.connectionBegin);
    rxSubscription = _midiHandler.registerDataListener(_onDataReceive);

    requestFirmwareVersion();
  }

  void _onDisconnect() {
    batteryTimer?.cancel();
    rxSubscription?.cancel();
    device.onDisconnect();
    print("Device disconnected");
  }

  void _onDataReceive(List<int> data) {
    if (developer) onDataReceiveDebug?.call(data);
    _device.communication.onDataReceive(data);
  }

  void _onBatteryTimer(Timer? t) {
    device.communication.requestBatteryStatus();
  }

  void requestFirmwareVersion() async {
    await Future.delayed(Duration(seconds: 1));
    var data = device.communication.createFirmwareMessage();
    if (data.length > 0)
      _midiHandler.sendData(data);
    else
      onFirmwareVersionReady();
  }

  void onFirmwareVersionReady() {
    device.communication.performNextConnectionStep();
  }

  void onConnectionStepReady() {
    if (device.communication.isConnectionReady()) {
      if (device.batterySupport) {
        batteryTimer = Timer.periodic(Duration(seconds: 15), _onBatteryTimer);
        _onBatteryTimer(null);
      }
      device.sendAmpLevel();
      connectStatus.add(DeviceConnectionState.connectionComplete);
      print("Device connection complete");
      notifyListeners();
    } else
      device.communication.performNextConnectionStep();
  }

  void onPresetsReady() {
    connectStatus.add(DeviceConnectionState.presetsLoaded);
  }

  //for some reason we should not ask for presets immediately
  void requestPresetDelayed() async {
    await Future.delayed(Duration(milliseconds: 400));
    requestPreset(0);
  }

  void requestPreset(int index) {
    _midiHandler.sendData(_device.communication.requestPresetByIndex(index));
  }

  void onBatteryPercentage(int val) {
    batteryPercentage.add(val);
  }

  //preset editing listeners
  void parameterChangedListener(Parameter param) {
    if (!isConnected) return;
    sendParameter(param, false);
  }

  void presetChangedListener() {
    clearUndoStack();
    if (!isConnected) return;
    changeDevicePreset(device.presetChangedNotifier.value);
  }

  void changeDevicePreset(int preset) {
    clearUndoStack();
    if (!isConnected) return;
    _midiHandler.sendData(device.communication.setChannel(preset));
  }

  void effectChangedListener(int slot) {
    sendFullEffectSettings(slot, true);
  }

  void effectSwitchedListener(int slot) {
    device.communication.sendSlotEnabledState(slot);
  }

  void slotSwappedListener(int slot) {
    device.communication.sendSlotOrder();
  }

  void sendFullEffectSettings(int slot, bool force) {
    if (!isConnected) return;
    var preset = device.getPreset(device.selectedChannel);
    Processor effect;
    int index;

    effect =
        preset.getEffectsForSlot(slot)[preset.getSelectedEffectForSlot(slot)];
    index = effect.nuxIndex;

    //check if preset switchable
    bool switchable = preset.slotSwitchable(slot);
    bool enabled = preset.slotEnabled(slot);

    //send parameters only if the effect is on OR is not switchable off
    bool send = !switchable || (switchable && enabled) || force;
    send = true; //still buggy, fix it first

    //send effect type
    if (slot != 0 && send && effect.midiCCSelectionValue >= 0) {
      device.communication.sendSlotEffect(slot, index);
    }

    //send parameters
    if (send) {
      for (int i = 0; i < effect.parameters.length; i++) {
        sendParameter(effect.parameters[i], false);
      }
    }

    //send switched
    if (switchable) device.communication.sendSlotEnabledState(slot);
  }

  void sendFullPresetSettings() {
    if (!isConnected) return;
    for (var i = 0; i < device.processorList.length; i++)
      sendFullEffectSettings(i, false);

    device.communication.sendSlotOrder();
    //TODO: send some other stuff - volume etc
  }

  void resetToChannelDefaults() {
    int channel = device.selectedChannel;
    changeDevicePreset(channel);
    sendFullPresetSettings();
  }

  List<int> sendParameter(Parameter param, bool returnOnly) {
    int outVal;

    //implement master volume
    if (device.fakeMasterVolume && param.masterVolume)
      outVal = param.masterVolMidiValue;
    else
      outVal = param.midiValue;
    var data = createCCMessage(param.midiCC, outVal);
    if (!returnOnly) _midiHandler.sendData(data);
    return data;
  }

  void saveNuxPreset() {
    if (!isConnected) return;
    //TODO: This fixes nothing! you must send the original volume
    double vol = 0;
    if (device.fakeMasterVolume) {
      vol = masterVolume;
      if (vol < 100) masterVolume = 100;
    }

    device.communication.saveCurrentPreset();

    if (device.fakeMasterVolume) {
      masterVolume = vol;
    }
    requestPreset(device.selectedChannel);
  }

  void resetNuxPresets() {
    if (!isConnected) return;
    var data = createCCMessage(MidiCCValues.bCC_CtrlCmd, 0x7f);
    _midiHandler.sendData(data);

    //show loading popup
    if (device.presetSaveSupport) {
      connectStatus.add(DeviceConnectionState.connectionBegin);
      requestPresetDelayed();
    }
  }

  void sendBLEData(List<int> data) {
    _midiHandler.sendData(data);
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

  void updateDiagnosticsData(
      {bool? connected, String? nuxPreset, bool includeJsonPreset = false}) {
    if (nuxPreset != null) diagData.lastNuxPreset = nuxPreset;

    diagData.device = "${_device.productName} ${_device.productVersion}";
    if (connected != null) diagData.connected = connected;

    Sentry.configureScope((scope) {
      scope.setTag(
          "nuxDevice", "${_device.productName} ${_device.productVersion}");
      scope.setContexts('NUX', diagData.toMap(includeJsonPreset));
    });
  }

  NuxDevice get device => _device;
}
