// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMighty8BT.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMighty8BTMk2.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:mighty_plug_manager/utilities/list_extenstions.dart';
import 'package:undo/undo.dart';
import 'bleMidiHandler.dart';
import 'ble_controllers/BLEController.dart';
import 'devices/NuxConstants.dart';
import 'devices/NuxDevice.dart';
import 'devices/NuxMighty2040BT.dart';
import 'devices/NuxMightyLite.dart';
import 'devices/NuxMightyLiteMk2.dart';
import 'devices/NuxMightyPlugAir.dart';
import 'devices/NuxMightyNamPro.dart';
import 'devices/communication/namProCommunication.dart';
import 'devices/presets/NamProPreset.dart';
import 'devices/NuxMightyPlugPro.dart';
import 'devices/NuxMightySpace.dart';
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

  late NuxDevice _device;

  StreamSubscription<List<int>>? rxSubscription;
  Timer? batteryTimer;

  String _presetName = "";
  String presetCategory = "";
  String presetUUID = "";
  String get presetName => _presetName;
  set presetName(String name) {
    _presetName = name;
    presetNameNotifier.value = name;
  }

  ValueNotifier presetNameNotifier = ValueNotifier<String>("");

  ValueNotifier<double> masterVolumeNotifier = ValueNotifier<double>(100);
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
    masterVolumeNotifier.value = vol;
    if (device.fakeMasterVolume) {
      _masterVolume = vol;
      if (isConnected) {
        device.sendAmpLevel();
      }
    } else {
      device.presets[device.selectedChannel].volume = vol;
    }
  }

  final StreamController<DeviceConnectionState> _connectStatus =
      StreamController.broadcast();
  final StreamController<int> _batteryPercentage =
      StreamController<int>.broadcast();

  Stream<DeviceConnectionState> get connectStatus => _connectStatus.stream;
  Stream<int> get batteryPercentage => _batteryPercentage.stream;

  bool get isConnected => _midiHandler.connectedDevice != null;

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
    if (_device.productBLENames.containsPartial(id)) {
      return _device;
    }
    for (int i = 0; i < _deviceInstances.length; i++) {
      if (_deviceInstances[i].productBLENames.containsPartial(id)) {
        return _deviceInstances[i];
      }
    }
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

  NuxDevice? getDeviceFromPresetClass(String presetClass) {
    for (int i = 0; i < _deviceInstances.length; i++) {
      if (_deviceInstances[i].presetClass == presetClass) {
        return _deviceInstances[i];
      }
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

    _deviceInstances.add(NuxMightyPlug(this));
    _deviceInstances.add(NuxMightyPlugPro(this));
    _deviceInstances.add(NuxMightyNamPro(this));
    _deviceInstances.add(NuxMightySpace(this));
    _deviceInstances.add(NuxMighty8BT(this));
    _deviceInstances.add(NuxMighty2040BT(this));
    _deviceInstances.add(NuxMightyLite(this));
    _deviceInstances.add(NuxMightyLiteMk2(this));
    _deviceInstances.add(NuxMighty8BTMk2(this));

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
        if (isConnected ||
            _midiHandler.currentStatus == MidiSetupStatus.deviceConnecting) {
          return;
        }
        debugPrint("Devices found ${_midiHandler.nuxDevices}");
        for (var dev in _midiHandler.nuxDevices) {
          if (!_midiHandler.manualScan) {
            _midiHandler.connectToDevice(dev.device);
            break;
          }
        }
        break;
      case MidiSetupStatus.deviceConnected:
        _clearDeviceStack();
        if (isConnected) {
          debugPrint("${_midiHandler.connectedDevice!.name} connected");
          _device = deviceFromBLEId(_midiHandler.connectedDevice!.name);
          updateDiagnosticsData(connected: true);
          SharedPrefs().setValue(SettingsKeys.device, _device.productStringId);
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

  void parameterChangedListener(Parameter param) {
    if (!isConnected) return;
    if (param.midiCC < 0) {
      if (device.communication is NamProCommunication) {
        var preset = device.getPreset(device.selectedChannel);
        if (preset is NamProPreset) {
          (device.communication as NamProCommunication)
              .sendNfPayload(preset.generateNfPayload());
          return;
        }
      }
      return;
    }
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
    bool switchable = preset.slotSwitchable(slot);
    bool enabled = preset.slotEnabled(slot);
    bool distinctCCodes =
        effect.midiCCSelectionValue != effect.midiCCEnableValue;
    bool send = !switchable || (switchable && enabled) || force;

    if (effect.midiCCSelectionValue >= 0) {
      if (distinctCCodes) {
        if (device.presets[0].getEffectsForSlot(slot).length > 1) {
          device.communication.sendSlotEffect(slot, index);
        }
      } else {
        device.communication.sendSlotEnabledState(slot);
      }
    }

    if (send) {
      bool isCustomSysEx = effect.parameters.isNotEmpty &&
          effect.parameters.any((p) => p.midiCC < 0);
      if (isCustomSysEx) {
        if (device.communication is NamProCommunication &&
            preset is NamProPreset) {
          (device.communication as NamProCommunication)
              .sendNfPayload(preset.generateNfPayload());
        }
      } else {
        for (int i = 0; i < effect.parameters.length; i++) {
          sendParameter(effect.parameters[i], false);
        }
      }
    }

    if (switchable && distinctCCodes) {
      device.communication.sendSlotEnabledState(slot);
    }
  }

  void sendFullPresetSettings() {
    if (!isConnected) return;
    clearDataQueue();
    if (!device.fakeMasterVolume) {
      device.presets[device.selectedChannel].sendVolume();
    }

    bool sentCustomSysEx = false;
    for (var i = 0; i < device.processorList.length; i++) {
      var preset = device.getPreset(device.selectedChannel);
      var effect =
          preset.getEffectsForSlot(i)[preset.getSelectedEffectForSlot(i)];
      bool isCustomSysEx = effect.parameters.isNotEmpty &&
          effect.parameters.any((p) => p.midiCC < 0);

      if (isCustomSysEx) {
        if (!sentCustomSysEx) {
          sendFullEffectSettings(i, false);
          sentCustomSysEx = true;
        }
      } else {
        sendFullEffectSettings(i, false);
      }
    }

    if (device.reorderableFXChain) {
      device.communication.sendSlotOrder();
    }
  }

  void resetToChannelDefaults() {
    int channel = device.selectedChannel;
    changeDeviceChannel(channel);
    sendFullPresetSettings();
  }

  List<int> sendParameter(Parameter param, bool returnOnly) {
    if (param.midiCC < 0) {
      if (!returnOnly && device.communication is NamProCommunication) {
        var preset = device.getPreset(device.selectedChannel);
        if (preset is NamProPreset) {
          (device.communication as NamProCommunication)
              .sendNfPayload(preset.generateNfPayload());
        }
      }
      return [];
    }
    int outVal;
    if (device.fakeMasterVolume && param.masterVolume) {
      outVal = param.masterVolMidiValue;
    } else {
      outVal = param.midiValue;
    }
    var data = createCCMessage(param.midiCC, outVal);
    if (!returnOnly) sendBLEData(data);
    return data;
  }

  void saveNuxPreset() async {
    if (!isConnected) return;
    double vol = 0;
    if (device.fakeMasterVolume) {
      vol = masterVolume;
      if (vol < 100) {
        _masterVolume = 100;
        device.sendAmpLevel();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
    device.communication.saveCurrentPreset(device.selectedChannel);
    if (device.fakeMasterVolume) {
      _masterVolume = vol;
    }
    requestPreset(device.selectedChannel);
  }

  void resetNuxPresets() async {
    if (!isConnected) return;
    device.communication.sendReset();
    if (device.presetSaveSupport) {
      await Future.delayed(const Duration(seconds: 3));
      _connectStatus.add(DeviceConnectionState.connectionBegin);
      requestPresetDelayed(3000);
    }
  }

  void clearDataQueue() {
    _midiHandler.clearDataQueue();
  }

  void sendBLEData(List<int> data) {
    if (data.isEmpty) return;
    if (data.length == 32 && data[0] != 0x80 && data[0] != 0xF0) {
      if (device.communication is NamProCommunication) {
        (device.communication as NamProCommunication).sendNfPayload(data);
        return;
      }
    } else if (data[0] == 0xF0) {
      data = [0x80, 0x80, ...data];
    }
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
  }

  NuxDevice get device => _device;
}