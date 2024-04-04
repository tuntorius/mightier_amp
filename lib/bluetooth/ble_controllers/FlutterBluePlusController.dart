/*
The original plugin used in Mightier Amp. For Android and iOS
https://pub.dev/packages/flutter_blue_plus

This plugin works great. Unfortunately it's only for mobile platforms.
MacOS is possible, due to almost 100% identical code to iOS
*/

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mighty_plug_manager/bluetooth/ble_controllers/BLEController.dart';
import 'package:mighty_plug_manager/utilities/list_extenstions.dart';

class FBPScanResult extends BLEScanResult {
  @override
  String get id => (device as FBPBleDevice).device.id.toString().toLowerCase();

  @override
  String get name => (device as FBPBleDevice).device.name;

  FBPScanResult(ScanResult sr) {
    device = FBPBleDevice(sr.device);
  }
}

class FBPBleDevice extends BLEDevice {
  final BluetoothDevice _device;
  BluetoothDevice get device => _device;

  FBPBleDevice(this._device);

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

class FlutterBluePlusController extends BLEController {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  FBPBleDevice? _device;
  @override
  BLEDevice? get connectedDevice => _device;
  BluetoothCharacteristic? _midiCharacteristic;
  StreamSubscription? _deviceStreamSubscription;
  bool _connectInProgress = false;

  StreamSubscription<bool>? _scanningStatusSubscription;
  StreamSubscription<BluetoothState>? _bluetoothStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  FlutterBluePlusController(List<String> forcedDevices) : super(forcedDevices);

  @override
  Future<bool> isAvailable() {
    return flutterBlue.isAvailable;
  }

  @override
  Future init(ScanResultsCallback callback) async {
    await super.init(callback);
    _subscribeBleState();
    _subscribeScanningStatus();
    _subscribeScanResults();

    flutterBlue.setLogLevel(LogLevel.info);
  }

  @override
  void startScanning() {
    if (bleState == BleState.off) return;
    setMidiSetupStatus(MidiSetupStatus.deviceSearching);
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
  Future stopScanning() {
    if (bleState == BleState.off) return Future.value(null);
    return flutterBlue.stopScan();
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
    await stopScanning();
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
        if (Platform.isAndroid) {
          //android deadObjectException fix
          device.clearGattCache().then((value) {
            device.disconnect();
          }).catchError((_) {});
        }
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
    _bluetoothStateSubscription = flutterBlue.state.listen((event) {
      debugPrint(event.toString());
      switch (event) {
        case BluetoothState.unknown:
          //fix for ios not recognizing bluetooth on at startup
          if (Platform.isIOS) {
            Future.delayed(const Duration(milliseconds: 500)).then((value) {
              flutterBlue.isOn.then((value) {
                if (value) {
                  bleState = BleState.on;
                  setMidiSetupStatus(MidiSetupStatus.deviceSearching);
                  startScanning();
                }
              });
            });
          }
          break;
        case BluetoothState.unavailable:
        case BluetoothState.unauthorized:
          bleState = BleState.off;
          setMidiSetupStatus(MidiSetupStatus.bluetoothOff);
          break;
        case BluetoothState.turningOn:
        case BluetoothState.on:
          bleState = BleState.on;
          setMidiSetupStatus(MidiSetupStatus.deviceSearching);
          startScanning();
          break;
        case BluetoothState.turningOff:
          flutterBlue.stopScan();
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

  _subscribeScanningStatus() {
    _scanningStatusSubscription = flutterBlue.isScanning.listen((event) {
      setScanningStatus(event);
    });
  }

  _subscribeScanResults() {
    _scanSubscription = flutterBlue.scanResults.listen((results) {
      List<ScanResult> nuxDevices = <ScanResult>[];
      List<ScanResult> controllerDevices = <ScanResult>[];
      //filter the scan results
      var devNames = deviceListProvider.call();

      for (ScanResult result in results) {
        if (devNames.containsPartial(result.device.name)) {
          nuxDevices.add(result);
        } else {
          bool validDevice = false;
          //check if it advertises the MIDI service
          for (var uuid in result.advertisementData.serviceUuids) {
            if (uuid.toLowerCase() == BLEController.midiServiceGuid) {
              validDevice = true;
            }
          }

          //check if it is in the special device list
          if (validDevice ||
              forcedDevices.contains(result.advertisementData.localName) ||
              forcedDevices.contains(result.device.name)) {
            controllerDevices.add(result);
          }
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
    });
  }

  @override
  bool get isWriteReady => _midiCharacteristic != null;

  @override
  Future writeToCharacteristic(List<int> data, bool noResponse) async {
    bool withoutResponse = noResponse;
    //wait for response on sysex messages
    //if (data[2] == 0xf0) withoutResponse = false;
    return _midiCharacteristic!.write(data, withoutResponse: withoutResponse);
  }
}
