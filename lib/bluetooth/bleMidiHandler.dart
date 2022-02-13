// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

//Good explanation for location usage
//https://support.chefsteps.com/hc/en-us/articles/360009480814-I-have-an-Android-Why-am-I-being-asked-to-allow-location-access-
import 'dart:async';
import 'dart:collection';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mighty_plug_manager/main.dart';
import 'package:permission_handler/permission_handler.dart';
import '../UI/pages/settings.dart';

enum midiSetupStatus {
  bluetoothOff,
  deviceIdle,
  deviceSearching,
  deviceFound,
  deviceConnecting,
  deviceConnected,
  deviceDisconnected,
  unknown
}

class BLEMidiHandler {
  static const String midiService = "03b80e5a-ede8-4b33-a751-6ce34ec4c700";
  static const String midiCharacteristic =
      "7772e5db-3868-4112-a1a9-f2669d106bf3";

  //List of devices that doesn't advertise its midi service
  static const List<String> forcedDevices = [
    "FootCtrl" //Cuvave / M-Wave Chocolate
  ];

  static final BLEMidiHandler _bleHandler = BLEMidiHandler._();

  FlutterBlue flutterBlue = FlutterBlue.instance;

  StreamController<midiSetupStatus> _status = StreamController.broadcast();
  Stream<midiSetupStatus> get status => _status.stream;

  StreamController<bool> _scanStatus = StreamController.broadcast();
  Stream<bool> get scanStatus => _scanStatus.stream;

  BluetoothState bluetoothState = BluetoothState.unknown;

  //amp device
  BluetoothDevice? _device;
  BluetoothCharacteristic? _midiCharacteristic;

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

  factory BLEMidiHandler() {
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

  initBle(Function(PermissionStatus) onPermissionDenied) async {
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
        if (!pStatus.isGranted) onPermissionDenied(pStatus);
      }
      Future.delayed(Duration(milliseconds: 500));
    } while (!pStatus.isGranted);
    print("Location permission granted!");
    _granted = true;
    _permanentlyDenied = false;

    flutterBlue.isAvailable.then((value) {
      if (value == false) {
        showMessageDialog(
            "Warning!", "Your device does not support bluetooth!");
      }
    });

    print("BLEMidiHandler:Init()");
    flutterBlue.state.listen((event) {
      print(event.toString());
      bluetoothState = event;
      switch (event) {
        case BluetoothState.unknown:
        case BluetoothState.unavailable:
        case BluetoothState.unauthorized:
          _isOn = false;
          _status.add(midiSetupStatus.bluetoothOff);
          break;
        case BluetoothState.turningOn:
        case BluetoothState.on:
          _isOn = true;
          _status.add(midiSetupStatus.deviceSearching);
          startScanning(false);
          break;
        case BluetoothState.turningOff:
          flutterBlue.stopScan();
          break;
        case BluetoothState.off:
          _isOn = false;
          _status.add(midiSetupStatus.bluetoothOff);
          _device = null;
          _connectInProgress = false;
          break;
      }
    });

    _scanningStatusSubscription = flutterBlue.isScanning.listen((event) {
      _isScanning = event;
      _scanStatus.add(event);
    });

    _scanSubscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results

      //filter the scan results
      var devNames = deviceListProvider.call();
      nuxDevices.clear();
      _controllerDevices.clear();

      for (ScanResult result in results) {
        if (devNames.contains(result.device.name))
          nuxDevices.add(result);
        else {
          bool validDevice = false;
          //check if it advertises the MIDI service
          for (var uuid in result.advertisementData.serviceUuids) {
            if (uuid.toLowerCase() == midiService) validDevice = true;
          }

          //check if it is in the special device list
          if (validDevice ||
              forcedDevices.contains(result.advertisementData.localName) ||
              forcedDevices.contains(result.device.name))
            _controllerDevices.add(result);
        }
      }

      _status.add(midiSetupStatus.deviceFound);
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
  }

  void setAmpDeviceIdProvider(List<String> Function() provider) {
    deviceListProvider = provider;
  }

  void startScanning(bool manual) {
    if (!_granted) return;
    manualScan = manual;
    _status.add(midiSetupStatus.deviceSearching);
    if (bluetoothState != BluetoothState.on) return;
    flutterBlue
        .startScan(
      timeout: Duration(seconds: 8),
      //withServices: [Guid(midiService)]
    )
        .then((result) {
      //if device is not connected after the search - set to idle
      if (_device == null) _status.add(midiSetupStatus.deviceIdle);
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
        print("Denying secondary connection!");
        return;
      }
    }

    _connectInProgress = true;
    stopScanning();
    _status.add(midiSetupStatus.deviceConnecting);
    try {
      await device.connect(autoConnect: false, timeout: Duration(seconds: 5));
    } on Exception {
      _connectInProgress = false;
      return;
    } catch (e) {
      print("Connect error $e");
      _connectInProgress = false;
      if (e == 'already_connected') return;
      throw (e);
    }

    if (ampDevice) {
      if (_device != null) return;
      _device = device;
    }

    List<BluetoothService> services = await device.discoverServices();
    //find midi service
    BluetoothService? _midiService;
    services.forEach((element) {
      if (element.uuid == Guid(midiService)) _midiService = element;
    });

    _midiService?.characteristics.forEach((element) {
      if (element.uuid == Guid(midiCharacteristic)) {
        _connectAmpDevice(device, element);
      }
    });
  }

  _connectAmpDevice(
      BluetoothDevice device, BluetoothCharacteristic characteristic) {
    _midiCharacteristic = characteristic;

    _midiCharacteristic?.setNotifyValue(true);

    queueFree = true;
    _connectInProgress = false;

    _status.add(midiSetupStatus.deviceConnected);
    device.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        _device = null;
        _connectInProgress = false;
        queueFree = true;
        _status.add(midiSetupStatus.deviceDisconnected);
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
    _status.add(midiSetupStatus.deviceConnecting);
    try {
      await device.connect(autoConnect: false, timeout: Duration(seconds: 5));
    } on Exception {
      _connectInProgress = false;
      return null;
    } catch (e) {
      print("Connect error $e");
      _connectInProgress = false;
      if (e == 'already_connected') return null;
      throw (e);
    }

    List<BluetoothService> services = await device.discoverServices();
    //find midi service
    BluetoothService? _midiService;
    services.forEach((element) {
      if (element.uuid == Guid(midiService)) _midiService = element;
    });

    if (_midiService != null)
      for (var characteristic in _midiService!.characteristics) {
        if (characteristic.uuid == Guid(midiCharacteristic)) {
          characteristic.setNotifyValue(true);
          _connectInProgress = false;
          return characteristic;
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

  void sendData(List<int> _data) {
    if (!_granted) return;
    dataQueue.addLast(_data);
    if (queueFree) queueSender();
  }

  void queueSender() async {
    queueFree = false;
    Stopwatch stopwatch = new Stopwatch()..start();
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
        } else
          dataQueue.clear();
      } catch (e) {
        print(e);
      }
    }
    queueFree = true;
    //if (kDebugMode)
    Settings.print('sending executed in ${stopwatch.elapsed.inMilliseconds}');
  }

  void dispose() {
    _scanSubscription?.cancel();
    _scanningStatusSubscription?.cancel();
    _device?.disconnect();
    _connectInProgress = false;
  }
}
