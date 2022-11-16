// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

//Good explanation for location usage
//https://support.chefsteps.com/hc/en-us/articles/360009480814-I-have-an-Android-Why-am-I-being-asked-to-allow-location-access-
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../UI/pages/settings.dart';

enum MidiSetupStatus {
  bluetoothOff,
  deviceIdle,
  deviceSearching,
  deviceFound,
  deviceConnecting,
  deviceConnected,
  deviceDisconnected,
  unknown
}

enum BluetoothError { unavailable, permissionDenied, locationServiceOff }

typedef BluetoothErrorCallback = void Function(BluetoothError, dynamic data);

class BLEMidiHandler {
  static const String midiServiceGuid = "03b80e5a-ede8-4b33-a751-6ce34ec4c700";
  static const String midiCharacteristicGuid =
      "7772e5db-3868-4112-a1a9-f2669d106bf3";

  //List of devices that doesn't advertise its midi service
  static const List<String> forcedDevices = [
    "FootCtrl" //Cuvave / M-Wave Chocolate
  ];

  static final BLEMidiHandler _bleHandler = BLEMidiHandler._();

  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  final StreamController<MidiSetupStatus> _status =
      StreamController.broadcast();
  Stream<MidiSetupStatus> get status => _status.stream;

  MidiSetupStatus _currentStatus = MidiSetupStatus.unknown;
  MidiSetupStatus get currentStatus => _currentStatus;

  final StreamController<bool> _scanStatus = StreamController.broadcast();
  Stream<bool> get scanStatus => _scanStatus.stream;

  BluetoothState bluetoothState = BluetoothState.unknown;

  //amp device
  BluetoothDevice? _device;
  BluetoothCharacteristic? _midiCharacteristic;
  StreamSubscription? _deviceStreamSubscription;

  bool queueFree = true;

  bool manualScan = false;

  bool _granted = false;

  bool _permanentlyDenied = false;

  bool _isOn = false;

  bool _isScanning = false;

  bool get permissionGranted => _granted;
  bool get permanentlyDenied => _permanentlyDenied;

  bool get bluetoothOn => _isOn;
  bool get isScanning => _isScanning;

  bool _connectInProgress = false;

  late List<String> Function() deviceListProvider;

  factory BLEMidiHandler.instance() {
    return _bleHandler;
  }

  // Future<List<MidiDevice>> get devices {
  //   return _midiCommand.devices;
  // }
  List<ScanResult> nuxDevices = <ScanResult>[];
  //controller devices
  List<ScanResult> _controllerDevices = <ScanResult>[];

  List<ScanResult> get controllerDevices => _controllerDevices;

  BluetoothDevice? get connectedDevice {
    return _device;
  }

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _scanningStatusSubscription;
  BLEMidiHandler._();

  initBle(BluetoothErrorCallback onError) async {
    _controllerDevices = [];

    PermissionStatus pStatus;
    bool askOneTime = false;
    do {
      pStatus = await Permission.location.status;
      if (pStatus.isGranted) break;
      if (!askOneTime) {
        pStatus = await Permission.location.request();
        if (pStatus.isPermanentlyDenied) _permanentlyDenied = true;
        askOneTime = true;
        if (!pStatus.isGranted) {
          onError(BluetoothError.permissionDenied, pStatus);
        }
      }
      Future.delayed(const Duration(milliseconds: 500));
    } while (!pStatus.isGranted);
    debugPrint("Location permission granted!");
    _granted = true;
    _permanentlyDenied = false;

    var available = await flutterBlue.isAvailable;
    if (!available) {}
    flutterBlue.isAvailable.then((value) {
      if (value == false) {
        onError(BluetoothError.unavailable, null);
        return;
      }
    });

    ServiceStatus ss = await Permission.location.serviceStatus;

    if (!ss.isEnabled) {
      onError(BluetoothError.locationServiceOff, null);
    }

    debugPrint("BLEMidiHandler:Init()");

    _subscribeForBLEState();
    _subscribeForScanStatus();
    _subscribeForScanResults();
  }

  void _subscribeForBLEState() {
    flutterBlue.state.listen((event) {
      debugPrint(event.toString());
      bluetoothState = event;
      switch (event) {
        case BluetoothState.unknown:
        case BluetoothState.unavailable:
        case BluetoothState.unauthorized:
          _isOn = false;
          _setMidiSetupStatus(MidiSetupStatus.bluetoothOff);
          break;
        case BluetoothState.turningOn:
        case BluetoothState.on:
          _isOn = true;
          _setMidiSetupStatus(MidiSetupStatus.deviceSearching);
          startScanning(false);
          break;
        case BluetoothState.turningOff:
          flutterBlue.stopScan();
          break;
        case BluetoothState.off:
          _isOn = false;
          _setMidiSetupStatus(MidiSetupStatus.bluetoothOff);
          _device = null;
          _connectInProgress = false;
          break;
      }
    });
  }

  void _subscribeForScanStatus() {
    _scanningStatusSubscription = flutterBlue.isScanning.listen((event) {
      _isScanning = event;
      _scanStatus.add(event);
    });
  }

  void _subscribeForScanResults() {
    _scanSubscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results

      //filter the scan results
      var devNames = deviceListProvider.call();
      nuxDevices.clear();
      _controllerDevices.clear();

      for (ScanResult result in results) {
        if (devNames.contains(result.device.name)) {
          nuxDevices.add(result);
        } else {
          bool validDevice = false;
          //check if it advertises the MIDI service
          for (var uuid in result.advertisementData.serviceUuids) {
            if (uuid.toLowerCase() == midiServiceGuid) validDevice = true;
          }

          //check if it is in the special device list
          if (validDevice ||
              forcedDevices.contains(result.advertisementData.localName) ||
              forcedDevices.contains(result.device.name)) {
            _controllerDevices.add(result);
          }
        }
      }

      _setMidiSetupStatus(MidiSetupStatus.deviceFound);
      for (ScanResult r in results) {
        debugPrint('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
  }

  void setAmpDeviceIdProvider(List<String> Function() provider) {
    deviceListProvider = provider;
  }

  void startScanning(bool manual) {
    if (!_granted) return;
    manualScan = manual;
    _setMidiSetupStatus(MidiSetupStatus.deviceSearching);
    if (bluetoothState != BluetoothState.on) return;
    flutterBlue
        .startScan(
      timeout: const Duration(seconds: 8),
      //withServices: [Guid(midiService)]
    )
        .then((result) {
      //if device is not connected after the search - set to idle
      if (_device == null) _setMidiSetupStatus(MidiSetupStatus.deviceIdle);
    });
  }

  void stopScanning() {
    if (!_granted) return;
    if (bluetoothState != BluetoothState.on) return;
    flutterBlue.stopScan();
  }

  void connectToDevice(BluetoothDevice device) async {
    if (!_granted) return;
    if (bluetoothState != BluetoothState.on) return;

    bool ampDevice = false;
    if (deviceListProvider.call().contains(device.name)) {
      ampDevice = true;
      if (_connectInProgress || _device != null) {
        debugPrint("Denying secondary connection!");
        return;
      }
    }

    _connectInProgress = true;
    stopScanning();
    _setMidiSetupStatus(MidiSetupStatus.deviceConnecting);
    try {
      await device.connect(
          autoConnect: false, timeout: const Duration(seconds: 5));
    } on Exception {
      _connectInProgress = false;
      return;
    } catch (e) {
      debugPrint("Connect error $e");
      _connectInProgress = false;
      if (e == 'already_connected') return;
      rethrow;
    }

    if (ampDevice) {
      if (_device != null) return;
      _device = device;
    }

    List<BluetoothService> services = await device.discoverServices();
    //find midi service
    BluetoothService? midiService;
    for (var element in services) {
      if (element.uuid == Guid(midiServiceGuid)) midiService = element;
    }

    if (midiService != null) {
      for (var element in midiService.characteristics) {
        if (element.uuid == Guid(midiCharacteristicGuid)) {
          _connectAmpDevice(device, element);
        }
      }
    }
  }

  void _connectAmpDevice(
      BluetoothDevice device, BluetoothCharacteristic characteristic) {
    _midiCharacteristic = characteristic;

    _midiCharacteristic?.setNotifyValue(true);

    queueFree = true;
    _connectInProgress = false;

    _setMidiSetupStatus(MidiSetupStatus.deviceConnected);
    _deviceStreamSubscription = device.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        _deviceStreamSubscription?.cancel();
        _device = null;
        _connectInProgress = false;
        queueFree = true;
        _setMidiSetupStatus(MidiSetupStatus.deviceDisconnected);
      }
    });
  }

  Future<BluetoothCharacteristic?> connectToController(
      BluetoothDevice device) async {
    if (!_granted) return null;
    if (bluetoothState != BluetoothState.on) return null;

    if (deviceListProvider.call().contains(device.name)) {
      throw ("Error, trying to connect to NUX device as a controller");
    }

    _connectInProgress = true;
    stopScanning();
    _setMidiSetupStatus(MidiSetupStatus.deviceConnecting);
    try {
      await device.connect(
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

    List<BluetoothService> services = await device.discoverServices();
    //find midi service
    BluetoothService? midiService;
    for (var element in services) {
      if (element.uuid == Guid(midiServiceGuid)) midiService = element;
    }

    if (midiService != null) {
      for (var characteristic in midiService.characteristics) {
        if (characteristic.uuid == Guid(midiCharacteristicGuid)) {
          characteristic.setNotifyValue(true);
          _connectInProgress = false;
          return characteristic;
        }
      }
    }
    return null;
  }

  void disconnectDevice() async {
    if (!_granted) return;
    if (_device != null) {
      _connectInProgress = false;
      await _device!.disconnect();
      queueFree = true;
      _device = null;
    }
  }

  StreamSubscription<List<int>> registerDataListener(
      Function(List<int>) listener) {
    return _midiCharacteristic!.value.listen(listener);
  }

  ListQueue<List<int>> dataQueue = ListQueue<List<int>>();

  void _setMidiSetupStatus(MidiSetupStatus status) {
    _currentStatus = status;
    _status.add(status);
  }

  void sendData(List<int> data) {
    if (!_granted) return;
    dataQueue.addLast(data);
    if (queueFree) _queueSender();
  }

  void _queueSender() async {
    queueFree = false;
    Stopwatch stopwatch = Stopwatch()..start();
    //List<int> currentData = List<int>();

    while (dataQueue.isNotEmpty) {
      if (connectedDevice == null) {
        dataQueue.clear();
        break;
      }
      try {
        if (_midiCharacteristic != null) {
          var data = dataQueue.first;
          await _midiCharacteristic!.write(data, withoutResponse: true);

          dataQueue.removeFirst();
        } else {
          dataQueue.clear();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    queueFree = true;
    if (kDebugMode) {
      Settings.print('sending executed in ${stopwatch.elapsed.inMilliseconds}');
    }
  }

  void dispose() {
    _scanSubscription?.cancel();
    _scanningStatusSubscription?.cancel();
    _device?.disconnect();
    _connectInProgress = false;
  }
}
