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
  String get id =>
      (device as FBPBleDevice).device.remoteId.toString().toLowerCase();

  @override
  String get name => (device as FBPBleDevice).device.platformName;

  FBPScanResult(ScanResult sr) {
    device = FBPBleDevice(sr.device);
  }
}

class FBPBleDevice extends BLEDevice {
  final BluetoothDevice _device;
  BluetoothDevice get device => _device;

  FBPBleDevice(this._device);

  @override
  String get name => _device.platformName;

  @override
  String get id => _device.remoteId.toString().toLowerCase();

  @override
  Stream<BleDeviceState> get state {
    StreamController<BleDeviceState> stateStream = StreamController();
    StreamSubscription<BluetoothConnectionState> s =
        _device.connectionState.listen((event) {
      switch (event) {
        case BluetoothConnectionState.disconnected:
          stateStream.add(BleDeviceState.disconnected);
          break;
        case BluetoothConnectionState.connected:
          stateStream.add(BleDeviceState.connected);
          break;
        default:
          // Handle other states if necessary, or ignore
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
  // FlutterBluePlus is now static only

  FBPBleDevice? _device;
  @override
  BLEDevice? get connectedDevice => _device;
  BluetoothCharacteristic? _midiCharacteristic;
  StreamSubscription? _deviceStreamSubscription;
  bool _connectInProgress = false;

  StreamSubscription<bool>? _scanningStatusSubscription;
  StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  FlutterBluePlusController(List<String> forcedDevices) : super(forcedDevices);

  @override
  Future<bool> isAvailable() {
    return FlutterBluePlus.isSupported;
  }

  @override
  Future init(ScanResultsCallback callback) async {
    await super.init(callback);
    _subscribeBleState();
    _subscribeScanningStatus();
    _subscribeScanResults();

    FlutterBluePlus.setLogLevel(LogLevel.info);
  }

  @override
  void startScanning() {
    if (bleState == BleState.off) return;
    setMidiSetupStatus(MidiSetupStatus.deviceSearching);
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 8),
      //withServices: [Guid(midiService)]
    ).then((result) {
      //if device is not connected after the search - set to idle
      if (_device == null) setMidiSetupStatus(MidiSetupStatus.deviceIdle);
    });
  }

  @override
  Future stopScanning() {
    if (bleState == BleState.off) return Future.value(null);
    return FlutterBluePlus.stopScan();
  }

  @override
  Future<BLEConnection?> connectToDevice(BLEDevice device) async {
    if (bleState != BleState.on) return null;
    var ownDevice = (device as FBPBleDevice).device;

    bool ampDevice = false;
    if (deviceListProvider.call().containsPartial(ownDevice.platformName)) {
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
          autoConnect: false,
          timeout: const Duration(seconds: 5),
          license: License.free);
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
            return BLEConnection(characteristic.lastValueStream);
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
    _deviceStreamSubscription = device.connectionState.listen((event) {
      if (event == BluetoothConnectionState.disconnected) {
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
    return _midiCharacteristic!.lastValueStream.listen(listener);
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
    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen((event) {
      debugPrint(event.toString());
      switch (event) {
        case BluetoothAdapterState.unknown:
          //fix for ios not recognizing bluetooth on at startup
          if (Platform.isIOS) {
            Future.delayed(const Duration(milliseconds: 500)).then((value) {
              FlutterBluePlus.adapterState.first.then((value) {
                if (value == BluetoothAdapterState.on) {
                  bleState = BleState.on;
                  setMidiSetupStatus(MidiSetupStatus.deviceSearching);
                  startScanning();
                }
              });
            });
          }
          break;
        case BluetoothAdapterState.unavailable:
        case BluetoothAdapterState.unauthorized:
          bleState = BleState.off;
          setMidiSetupStatus(MidiSetupStatus.bluetoothOff);
          break;
        case BluetoothAdapterState.turningOn:
        case BluetoothAdapterState.on:
          bleState = BleState.on;
          setMidiSetupStatus(MidiSetupStatus.deviceSearching);
          startScanning();
          break;
        case BluetoothAdapterState.turningOff:
          FlutterBluePlus.stopScan();
          break;
        case BluetoothAdapterState.off:
          bleState = BleState.off;
          setMidiSetupStatus(MidiSetupStatus.bluetoothOff);
          _device = null;
          _connectInProgress = false;
          break;
      }
    });
  }

  _subscribeScanningStatus() {
    _scanningStatusSubscription = FlutterBluePlus.isScanning.listen((event) {
      setScanningStatus(event);
    });
  }

  _subscribeScanResults() {
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      List<ScanResult> nuxDevices = <ScanResult>[];
      List<ScanResult> controllerDevices = <ScanResult>[];
      //filter the scan results
      var devNames = deviceListProvider.call();

      for (ScanResult result in results) {
        if (devNames.containsPartial(result.device.platformName)) {
          nuxDevices.add(result);
        } else {
          bool validDevice = false;
          //check if it advertises the MIDI service
          for (var uuid in result.advertisementData.serviceUuids) {
            if (uuid.toString().toLowerCase() ==
                BLEController.midiServiceGuid) {
              validDevice = true;
            }
          }

          //check if it is in the special device list
          if (validDevice ||
              forcedDevices.contains(result.advertisementData.advName) ||
              forcedDevices.contains(result.device.platformName)) {
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
        debugPrint('${r.device.platformName} found! rssi: ${r.rssi}');
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
