// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMighty8BT.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:undo/undo.dart';

import 'bleMidiHandler.dart';

import 'ble_controllers/BLEController.dart';
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
  connectionComplete,
  disconnected
}

class NuxDiagnosticData {
  String device = "";
  bool connected = false;
  String lastNuxPreset = "";

  Map<String, dynamic> toMap(bool includeJsonPreset) {
    var data = <String, dynamic>{};
    data['device'] = device;
    data['connected'] = connected;
    data['lastNuxPreset'] = lastNuxPreset;

    if (includeJsonPreset) {
      data['jsonPreset'] = NuxDeviceControl.instance().device.presetToJson();
    }

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

  //Preset Name Stuff
  String _presetName = "";
  String presetCategory = "";
  String presetUUID = "";

  String get presetName => _presetName;
  set presetName(String name) {
    _presetName = name;
    presetNameNotifier.value = name;
  }

  ValueNotifier presetNameNotifier = ValueNotifier<String>("");
  ValueNotifier<int> masterVolumeNotifier = ValueNotifier<int>(100);

  double _masterVolume = 100;

  ChangeStack get changes => device.presets[device.selectedChannel].changes;

  bool developer = false;
  Function(List<int>)? onDataReceiveDebug;

  double get masterVolume {
    if (device.fakeMasterVolume) {
      return _masterVolume;
    } else {
      return device.presets[device.selectedChannel].volume;
    }
  }

  set masterVolume(double vol) {
    masterVolumeNotifier.value = vol.toInt();
    if (device.fakeMasterVolume) {
      _masterVolume = vol;
      if (isConnected) {
        device.sendAmpLevel();
      }
    } else {
      device.presets[device.selectedChannel].volume = vol;
    }
  }

  //connect status control
  final StreamController<DeviceConnectionState> _connectStatus =
      StreamController.broadcast();
  final StreamController<int> _batteryPercentage =
      StreamController<int>.broadcast();

  Stream<DeviceConnectionState> get connectStatus => _connectStatus.stream;
  Stream<int> get batteryPercentage => _batteryPercentage.stream;

  bool get isConnected => _midiHandler.connectedDevice != null;

  //list of all different nux devices
  final List<NuxDevice> _deviceInstances = <NuxDevice>[];

  List<NuxDevice> get deviceList => _deviceInstances;

  List<String> deviceBLEName() {
    var names = <String>[];
    for (int i = 0; i < _deviceInstances.length; i++) {
      names.addAll(_deviceInstances[i].productBLENames);
    }
    return names;
  }

  List<String> get deviceNameList {
    var names = <String>[];
    for (int i = 0; i < _deviceInstances.length; i++) {
      names.add(_deviceInstances[i].productNameShort);
    }
    return names;
  }

  int get deviceIndex {
    for (int i = 0; i < _deviceInstances.length; i++) {
      if (_device == _deviceInstances[i]) return i;
    }
    return 0;
  }

  set deviceIndex(int index) {
    _clearAllDevicesStack();
    clearPresetData();
    _device = _deviceInstances[index];

    updateDiagnosticsData();
    SharedPrefs().setValue(SettingsKeys.device, _device.productStringId);
    SharedPrefs().setValue(SettingsKeys.deviceVersion, _device.productVersion);
    notifyListeners();
  }

  List<String> get deviceVersionsList {
    var names = <String>[];
    for (int i = 0; i < device.getAvailableVersions(); i++) {
      names.add(device.getProductNameVersion(i));
    }
    return names;
  }

  int get deviceFirmwareVersion => device.productVersion;

  set deviceFirmwareVersion(int ver) {
    _clearDeviceStack();
    clearPresetData();
    device.setFirmwareVersionByIndex(ver);
    SharedPrefs().setValue(SettingsKeys.deviceVersion, ver);
  }

  NuxDevice deviceFromBLEId(String id) {
    for (int i = 0; i < _deviceInstances.length; i++) {
      if (_deviceInstances[i].productBLENames.contains(id)) {
        return _deviceInstances[i];
      }
    }

    //return plug/air by default
    return _deviceInstances[0];
  }

  String getDeviceNameFromId(String id) {
    for (int i = 0; i < _deviceInstances.length; i++) {
      if (_deviceInstances[i].productStringId == id) {
        return _deviceInstances[i].productNameShort;
      }
    }
    return "Unknown";
  }

  NuxDevice? getDeviceFromId(String id) {
    for (int i = 0; i < _deviceInstances.length; i++) {
      if (_deviceInstances[i].productStringId == id) return _deviceInstances[i];
    }
    return null;
  }

  _clearDeviceStack({NuxDevice? device}) {
    bool notify = device == null;
    device ??= _device;
    for (int i = 0; i < device.channelsCount; i++) {
      device.presets[i].changes.clearHistory();
    }

    if (notify) notifyListeners();
  }

  _clearAllDevicesStack() {
    for (int i = 0; i < _deviceInstances.length; i++) {
      _clearDeviceStack(device: _deviceInstances[i]);
    }
  }

  undoStackChanged() {
    notifyListeners();
  }

  void clearPresetData() {
    presetName = "";
    presetCategory = "";
    presetUUID = "";
  }

  forceNotifyListeners() {
    notifyListeners();
  }

  factory NuxDeviceControl() {
    return _nuxDeviceControl;
  }

  NuxDeviceControl._() {
    _midiHandler.setAmpDeviceIdProvider(deviceBLEName);
    _midiHandler.status.listen(_statusListener);

    //create all supported devices
    _deviceInstances.add(NuxMightyPlug(this));
    _deviceInstances.add(NuxMightyPlugPro(this));
    _deviceInstances.add(NuxMighty8BT(this));
    _deviceInstances.add(NuxMighty2040BT(this));
    _deviceInstances.add(NuxMightyLite(this));

    //make it read from config
    String dev = SharedPrefs()
        .getValue(SettingsKeys.device, _deviceInstances[0].productStringId);

    _device = getDeviceFromId(dev) ?? _deviceInstances[0];

    int ver = SharedPrefs().getValue(
        SettingsKeys.deviceVersion, _device.getAvailableVersions() - 1);
    _device.setFirmwareVersionByIndex(ver);

    updateDiagnosticsData(connected: false);

    if (device.fakeMasterVolume) {
      masterVolume = SharedPrefs().getValue(SettingsKeys.masterVolume, 100.0);
    }

    for (int i = 0; i < _deviceInstances.length; i++) {
      var dev = _deviceInstances[i];
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
        debugPrint("Devices found ${_midiHandler.nuxDevices}");
        for (var dev in _midiHandler.nuxDevices) {
          //don't autoconnect on manual scan
          if (!_midiHandler.manualScan) {
            _midiHandler.connectToDevice(dev.device);
          }
        }
        break;
      case MidiSetupStatus.deviceConnected:
        _clearDeviceStack();

        //find which device connected
        if (isConnected) {
          debugPrint("${_midiHandler.connectedDevice!.name} connected");
          _device = deviceFromBLEId(_midiHandler.connectedDevice!.name);

          updateDiagnosticsData(connected: true);
          SharedPrefs().setValue(SettingsKeys.device, _device.productStringId);
          //can't set version yet, firmware is unknown
          notifyListeners();
          _onConnect();
        }
        break;
      case MidiSetupStatus.deviceDisconnected:
        _clearDeviceStack();
        updateDiagnosticsData(connected: false);
        notifyListeners();
        _onDisconnect();
        break;
      default:
        break;
    }
  }

  void _onConnect() {
    debugPrint("Device connected");
    clearPresetData();
    device.onConnect();
    _connectStatus.add(DeviceConnectionState.connectionBegin);
    rxSubscription = _midiHandler.registerDataListener(_onDataReceive);

    requestFirmwareVersion();
  }

  void _onDisconnect() {
    batteryTimer?.cancel();
    rxSubscription?.cancel();
    clearPresetData();
    device.onDisconnect();
    debugPrint("Device disconnected");
    _connectStatus.add(DeviceConnectionState.disconnected);
  }

  void _onDataReceive(List<int> data) {
    if (developer) onDataReceiveDebug?.call(data);
    _device.communication.onDataReceive(data);
  }

  void _onBatteryTimer(Timer? t) {
    device.communication.requestBatteryStatus();
  }

  void requestFirmwareVersion() async {
    await Future.delayed(const Duration(seconds: 1));
    var data = device.communication.createFirmwareMessage();
    if (data.isNotEmpty) {
      sendBLEData(data);
    } else {
      onFirmwareVersionReady();
    }
  }

  void onFirmwareVersionReady() {
    device.communication.performNextConnectionStep();
  }

  void onConnectionStepReady() {
    if (device.communication.isConnectionReady()) {
      if (device.batterySupport) {
        batteryTimer =
            Timer.periodic(const Duration(seconds: 15), _onBatteryTimer);
        _onBatteryTimer(null);
      }
      device.sendAmpLevel();
      _connectStatus.add(DeviceConnectionState.connectionComplete);
      debugPrint("Device connection complete");
      notifyListeners();
    } else {
      device.communication.performNextConnectionStep();
    }
  }

  bool isConnectionComplete() {
    return device.communication.isConnectionReady();
  }

  void onPresetsReady() {
    _connectStatus.add(DeviceConnectionState.presetsLoaded);
  }

  //for some reason we should not ask for presets immediately
  void requestPresetDelayed(int? delay) async {
    await Future.delayed(Duration(milliseconds: delay ?? 400));
    requestPreset(0);
  }

  void requestPreset(int index) {
    sendBLEData(_device.communication.requestPresetByIndex(index));
  }

  void onBatteryPercentage(int val) {
    _batteryPercentage.add(val);
  }

  //preset editing listeners
  void parameterChangedListener(Parameter param) {
    if (!isConnected) return;
    sendParameter(param, false);
  }

  void changeDeviceChannel(int channel) {
    if (!isConnected) return;
    sendBLEData(device.communication.setChannel(channel));
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
    bool distinctCCodes =
        effect.midiCCSelectionValue != effect.midiCCEnableValue;
    //send parameters only if the effect is on OR is not switchable off
    bool send = !switchable || (switchable && enabled) || force;
    send = true; //still buggy, fix it first

    //send effect type
    if (slot != 0 && send && effect.midiCCSelectionValue >= 0) {
      if (distinctCCodes) {
        device.communication.sendSlotEffect(slot, index);
      } else {
        device.communication.sendSlotEnabledState(slot);
      }
    }

    //send parameters
    if (send) {
      for (int i = 0; i < effect.parameters.length; i++) {
        sendParameter(effect.parameters[i], false);
      }
    }

    //send switched
    if (switchable && distinctCCodes) {
      device.communication.sendSlotEnabledState(slot);
    }
  }

  void sendFullPresetSettings() {
    if (!isConnected) return;

    BLEMidiHandler.instance().clearDataQueue();
    if (!device.fakeMasterVolume) {
      device.presets[device.selectedChannel].sendVolume();
    }

    for (var i = 0; i < device.processorList.length; i++) {
      sendFullEffectSettings(i, false);
    }

    device.communication.sendSlotOrder();
  }

  void resetToChannelDefaults() {
    int channel = device.selectedChannel;
    changeDeviceChannel(channel);
    sendFullPresetSettings();
  }

  List<int> sendParameter(Parameter param, bool returnOnly) {
    int outVal;

    //implement master volume
    if (device.fakeMasterVolume && param.masterVolume) {
      outVal = param.masterVolMidiValue;
    } else {
      outVal = param.midiValue;
    }
    var data = createCCMessage(param.midiCC, outVal);
    if (!returnOnly) sendBLEData(data);
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

    device.communication.saveCurrentPreset(device.selectedChannel);

    if (device.fakeMasterVolume) {
      masterVolume = vol;
    }
    requestPreset(device.selectedChannel);
  }

  void resetNuxPresets() async {
    if (!isConnected) return;
    device.communication.sendReset();

    //show loading popup
    if (device.presetSaveSupport) {
      await Future.delayed(const Duration(seconds: 3));
      _connectStatus.add(DeviceConnectionState.connectionBegin);
      requestPresetDelayed(3000);
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

/*
    Sentry.configureScope((scope) {
      scope.setTag(
          "nuxDevice", "${_device.productName} ${_device.productVersion}");
      scope.setContexts('NUX', diagData.toMap(includeJsonPreset));
    });*/
  }

  NuxDevice get device => _device;
}
