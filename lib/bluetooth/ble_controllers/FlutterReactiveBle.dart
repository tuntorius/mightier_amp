
/*
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:mighty_plug_manager/bluetooth/ble_controllers/BLEController.dart';

class FRBScanResult extends BLEScanResult {
  @override
  String get id => (device as FRBleDevice).id.toString().toLowerCase();

  @override
  String get name => (device as FRBleDevice).name;

  FRBScanResult(DiscoveredDevice sr) {
    device = FRBleDevice(sr);
  }
}

class FRBleDevice extends BLEDevice {
  final DiscoveredDevice _device;
  DiscoveredDevice get device => _device;

  FRBleDevice(this._device);

  @override
  String get name => _device.name;

  @override
  String get id => _device.id.toString().toLowerCase();

  @override
  Stream<BleDeviceState> get state {
    StreamController<BleDeviceState> stateStream = StreamController();
    StreamSubscription<BluetoothDeviceState> s = _device.state.listen((event) {
      switch (event) {
        case BluetoothDeviceState.disconnected:
          stateStream.add(BleDeviceState.disconnected);
          break;
        case BluetoothDeviceState.connecting:
          stateStream.add(BleDeviceState.connecting);
          break;
        case BluetoothDeviceState.connected:
          stateStream.add(BleDeviceState.connected);
          break;
        case BluetoothDeviceState.disconnecting:
          stateStream.add(BleDeviceState.disconnecting);
          break;
      }
    });

    stateStream.onCancel = () {
      s.cancel();
    };
    return stateStream.stream;
  }
}

class FlutterReactiveBleController extends BLEController {
  FlutterReactiveBle flutterBlue = FlutterReactiveBle();

  FRBleDevice? _device;
  @override
  BLEDevice? get connectedDevice => _device;
  BluetoothCharacteristic? _midiCharacteristic;
  StreamSubscription? _deviceStreamSubscription;
  bool _connectInProgress = false;

  StreamSubscription<bool>? _scanningStatusSubscription;
  StreamSubscription<BluetoothState>? _bluetoothStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  FlutterReactiveBleController(List<String> forcedDevices)
      : super(forcedDevices);

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future init(ScanResultsCallback callback) async {
    await super.init(callback);
    _subscribeBleState();
    _subscribeScanningStatus();
    _subscribeScanResults();
  }

  @override
  void startScanning() {
    if (bleState == BleState.off) return;
    setMidiSetupStatus(MidiSetupStatus.deviceSearching);

    flutterBlue.scanForDevices(
      withServices: [],
    );

    flutterBlue
        .startScan(
      timeout: const Duration(seconds: 8),
      //withServices: [Guid(midiService)]
    )
        .then((result) {
      //if device is not connected after the search - set to idle
      if (_device == null) setMidiSetupStatus(MidiSetupStatus.deviceIdle);
    });
  }

  @override
  void stopScanning() {
    if (bleState == BleState.off) return;
    flutterBlue.stopScan();
  }

  @override
  Future<BLEConnection?> connectToDevice(BLEDevice device) async {
    if (bleState != BleState.on) return null;
    var ownDevice = (device as FBPBleDevice).device;

    bool ampDevice = false;
    if (deviceListProvider.call().containsPartial(ownDevice.name)) {
      ampDevice = true;
      if (_connectInProgress || _device != null) {
        debugPrint("Denying secondary connection!");
        return null;
      }
    }

    _connectInProgress = true;
    stopScanning();
    setMidiSetupStatus(MidiSetupStatus.deviceConnecting);
    try {
      await ownDevice.connect(
          autoConnect: false, timeout: const Duration(seconds: 5));
    } on Exception {
      _connectInProgress = false;
      return null;
    } catch (e) {
      debugPrint("Connect error $e");
      _connectInProgress = false;
      if (e == 'already_connected') return null;
      rethrow;
    }

    if (ampDevice) {
      if (_device != null) return null;
      _device = device;
    }

    List<BluetoothService> services = await ownDevice.discoverServices();
    //find midi service
    BluetoothService? midiService;
    for (var element in services) {
      if (element.uuid == Guid(BLEController.midiServiceGuid)) {
        midiService = element;
      }
    }

    if (midiService != null) {
      for (var characteristic in midiService.characteristics) {
        if (characteristic.uuid == Guid(BLEController.midiCharacteristicGuid)) {
          if (ampDevice) {
            _connectAmpDevice(device.device, characteristic);
          } else {
            characteristic.setNotifyValue(true);
            _connectInProgress = false;
            return BLEConnection(characteristic.value);
          }
        }
      }
    }
    return null;
  }

  void _connectAmpDevice(
      BluetoothDevice device, BluetoothCharacteristic characteristic) {
    _midiCharacteristic = characteristic;

    _midiCharacteristic?.setNotifyValue(true);

    _connectInProgress = false;

    setMidiSetupStatus(MidiSetupStatus.deviceConnected);
    _deviceStreamSubscription = device.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        _deviceStreamSubscription?.cancel();
        _device = null;
        _midiCharacteristic = null;
        _connectInProgress = false;
        setMidiSetupStatus(MidiSetupStatus.deviceDisconnected);
      }
    });
  }

  @override
  StreamSubscription<List<int>> registerDataListener(
      Function(List<int>) listener) {
    return _midiCharacteristic!.value.listen(listener);
  }

  @override
  void disconnectDevice() async {
    if (_device != null) {
      _connectInProgress = false;
      await _device?.device.disconnect();
      _midiCharacteristic = null;
      _device = null;
    }
  }

  @override
  void dispose() {
    _scanningStatusSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _device?.device.disconnect();
    _connectInProgress = false;
  }

  _subscribeBleState() {
    _bluetoothStateSubscription = flutterBlue.statusStream.listen((event) {
      debugPrint(event.toString());
      switch (event) {
        case BleStatus.unknown:
        case BleStatus.poweredOff:
        case BleStatus.unauthorized:
        case BleStatus.unsupported:
        case BleStatus.locationServicesDisabled:
          bleState = BleState.off;
          setMidiSetupStatus(MidiSetupStatus.bluetoothOff);
          break;
        case BleStatus.ready:
          bleState = BleState.on;
          setMidiSetupStatus(MidiSetupStatus.deviceSearching);
          startScanning();
          break;
        case BleStatus.poweredOff:
          //flutterBlue.
          break;
        case BluetoothState.off:
          bleState = BleState.off;
          setMidiSetupStatus(MidiSetupStatus.bluetoothOff);
          _device = null;
          _connectInProgress = false;
          break;
      }
    });
  }

  _onScanResults(DiscoveredDevice result) {
    List<DiscoveredDevice> nuxDevices = [];
    List<DiscoveredDevice> controllerDevices = [];
    //filter the scan results
    var devNames = deviceListProvider.call();

    if (devNames.containsPartial(result.name)) {
      nuxDevices.add(result);
    } else {
      bool validDevice = false;
      //check if it advertises the MIDI service
      for (var uuid in result.serviceUuids) {
        if (uuid.toString().toLowerCase() == BLEController.midiServiceGuid) {
          validDevice = true;
        }
      }

      //check if it is in the special device list
      if (validDevice || forcedDevices.contains(result.name)) {
        controllerDevices.add(result);
      }
    }

    //convert to blescanresult
    List<BLEScanResult> nuxBle = [], ctrlBle = [];
    for (var dev in nuxDevices) {
      nuxBle.add(FBPScanResult(dev));
    }
    for (var dev in controllerDevices) {
      ctrlBle.add(FBPScanResult(dev));
    }
    onScanResults(nuxBle, ctrlBle);
    setMidiSetupStatus(MidiSetupStatus.deviceFound);
    for (ScanResult r in results) {
      debugPrint('${r.device.name} found! rssi: ${r.rssi}');
    }
  }

  @override
  bool get isWriteReady => _midiCharacteristic != null;

  @override
  Future writeToCharacteristic(List<int> data) async {
    return _midiCharacteristic!.write(data, withoutResponse: true);
  }
}
*/