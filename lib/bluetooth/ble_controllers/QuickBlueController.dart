/*
Controller that uses quick_blue plugin, which supports all platforms, except web
https://pub.dev/packages/quick_blue

Summary
State: Bad

Tested mostly in Windows, also in Linux and Android
Windows:
When app is launched, the first connection attempt works 50% of the time.
Any subsequent connects don't work. Few days later it stopped working AT ALL!
Sometimes even crashes the app

Linux:
the version from pub.dev has incomplete linux port, only scanning is done.
There's another nearly complete version here
https://github.com/woodemi/quick.flutter/tree/master/packages/quick_blue
However it's not reliable. While it connects, it does not raise connect &
disconnect events properly. It uses bluez plugin for linux:
https://pub.dev/packages/bluez
This can be used as a starting point for custom plugin

Android:
tested it just a little, works horrible, which proves that the plugin is crap,
because the actual Android plugin that I use - flutter_blue_plugin is flawless. 
Another problem is that it required API level 21 (Lollipop), however there are
too many people using the app on KitKat so it's important to keep compatibility.
This plugin doesn't provide device services while scanning. This is important,
because it can't filter by devices which support MIDI-BLE
*/

/*
import 'dart:async';
import 'dart:typed_data';
import 'package:quick_blue/quick_blue.dart';
import 'BLEController.dart';

class QuickBlueScanResult extends BLEScanResult {
  @override
  String get id => (device as QuickBlueDevice).id;

  @override
  String get name => (device as QuickBlueDevice).name;

  late BlueScanResult _scanResult;

  QuickBlueScanResult(BlueScanResult r) {
    _scanResult = r;
    device = QuickBlueDevice(_scanResult);
  }
}

class QuickBlueDevice extends BLEDevice {
  final BlueScanResult _scanResult;
  late StreamController<BleDeviceState> _deviceState;

  QuickBlueDevice(this._scanResult);

  @override
  String get id => _scanResult.deviceId;

  @override
  String get name => _scanResult.name;

  void setupDeviceStateStream() {
    _deviceState = StreamController();
  }

  void publishDeviceState(BleDeviceState devState) {
    _deviceState.add(devState);
    if (devState == BleDeviceState.disconnected) {
      _deviceState.close();
    }
  }

  @override
  // TODO: implement state
  Stream<BleDeviceState> get state => _deviceState.stream;
}

class QuickBlueController extends BLEController {
  QuickBlueController(List<String> forcedDevices) : super(forcedDevices);

  StreamSubscription<BlueScanResult>? _scanSubscription;

  QuickBlueDevice? _device;

  List<BlueScanResult> scannedDevices = [];

  DateTime _scanStarted = DateTime.now();

  late List<String> nuxDeviceNames;

  StreamController<List<int>>? _dataStreamController;

  bool _connected = false;
  bool _connectInProgress = false;

  @override
  // TODO: implement connectedDevice
  BLEDevice? get connectedDevice => _device;

  @override
  Future<bool> isAvailable() async {
    bool available = await QuickBlue.isBluetoothAvailable();
    if (available) bleState = BleState.on;
    return available;
  }

  @override
  Future init(ScanResultsCallback callback) async {
    await super.init(callback);
    nuxDeviceNames = deviceListProvider.call();
    //_subscribeBleState();
    //_subscribeScanningStatus();
    _subscribeScanResults();

    QuickBlue.setValueHandler(_handleValueChange);
  }

  @override
  void startScanning() {
    if (bleState == BleState.off) return;
    setMidiSetupStatus(MidiSetupStatus.deviceSearching);
    setScanningStatus(true);
    _scanStarted = DateTime.now();
    QuickBlue.startScan();
  }

  @override
  void stopScanning() {
    QuickBlue.stopScan();
    setScanningStatus(false);
  }

  @override
  StreamSubscription<List<int>> registerDataListener(
      Function(List<int> data) listener) {
    _dataStreamController = StreamController();
    return _dataStreamController!.stream.listen(listener);
  }

  @override
  Future<BLEConnection?> connectToDevice(BLEDevice device) async {
    if (bleState != BleState.on) return null;

    bool ampDevice = false;
    if (nuxDeviceNames.containsPartial(device.name)) {
      ampDevice = true;
      if (_connectInProgress || _device != null) {
        print("Denying secondary connection!");
        return null;
      }
    }

    _connectInProgress = true;
    stopScanning();
    setMidiSetupStatus(MidiSetupStatus.deviceConnecting);

    if (ampDevice) {
      if (_device != null) return null;
      _device = device as QuickBlueDevice;
      _device!.setupDeviceStateStream();
      _device!.publishDeviceState(BleDeviceState.connecting);
    }

    QuickBlue.setConnectionHandler(_handleConnectionChange);
    QuickBlue.connect(device.id);
  }

  void _handleConnectionChange(String deviceId, BlueConnectionState state) {
    if (_device != null && deviceId == _device!.id) {
      switch (state) {
        case BlueConnectionState.connected:
          print("QuickBlue: device connected");
          _device!.publishDeviceState(BleDeviceState.connected);
          QuickBlue.setServiceHandler(_handleServiceDiscovery);
          QuickBlue.discoverServices(_device!.id);
          break;
        case BlueConnectionState.disconnected:
          print("QuickBlue: device disconnected");
          _device!.publishDeviceState(BleDeviceState.disconnected);
          _dataStreamController?.close();
          _device = null;
          _connectInProgress = false;
          _connected = false;
          setMidiSetupStatus(MidiSetupStatus.deviceDisconnected);
          break;
      }
    }
  }

  void _handleServiceDiscovery(
      String deviceId, String serviceId, List<String> characteristicIds) {
    if (_device != null && deviceId == _device!.id) {
      if (serviceId == BLEController.midiServiceGuid) {
        print("QuickBlue: midi service discovered");
        if (characteristicIds.contains(BLEController.midiCharacteristicGuid)) {
          print("QuickBlue: midi characteristic discovered");
          _connectInProgress = false;
          _connected = true;
          setMidiSetupStatus(MidiSetupStatus.deviceConnected);
          QuickBlue.setNotifiable(
              deviceId,
              serviceId,
              BLEController.midiCharacteristicGuid,
              BleInputProperty.notification);
        }
      }
    }
  }

  void _handleValueChange(
      String deviceId, String characteristicId, Uint8List value) {
    print("QuickBlue: Data coming");
    if (_device != null && _device!.id == deviceId) {
      _dataStreamController?.add(value.toList());
    }
  }

  @override
  void disconnectDevice() {
    if (_device != null) {
      _connectInProgress = false;
      QuickBlue.disconnect(_device!.id);

      //TODO: this should not be here
      _dataStreamController?.close();
      _device = null;
      _connectInProgress = false;
      _connected = false;
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
  }

  @override
  bool get isWriteReady => _connected;

  @override
  Future writeToCharacteristic(List<int> data) async {
    print("QuickBlue: Writing");
    if (_connected) {
      return QuickBlue.writeValue(
          _device!.id,
          BLEController.midiServiceGuid,
          BLEController.midiCharacteristicGuid,
          Uint8List.fromList(data),
          BleOutputProperty.withoutResponse);
    }
  }

  void _subscribeScanResults() {
    _scanSubscription =
        _scanSubscription = QuickBlue.scanResultStream.listen((device) {
      print("---Scan Result---");
      print(device.deviceId);
      print(device.name);
      print(device.rssi);
      print(device.manufacturerData.toList());
      print(device.manufacturerDataHead.toList());

      final index = scannedDevices
          .indexWhere((element) => element.deviceId == device.deviceId);
      // Updating existing device
      if (index != -1) {
        // if (device.name.isNotEmpty && scannedDevices[index].name.isEmpty) {
        //   scannedDevices[index].name = device.name;
        // }

        // if (device.serviceUuids.isNotEmpty &&
        //     scannedDevices[index].serviceUuids.isEmpty) {
        //   scannedDevices[index].serviceUuids = device.serviceUuids;
        // }
      } else {
        scannedDevices.add(device);
      }

      //TODO: scan timeout must be implemented in a different way
      //because this breaks in linux
      if ((DateTime.now().difference(_scanStarted).inMilliseconds < 5000)) {
        return;
      }

      stopScanning();
      scannedDevices
          .retainWhere((device) => nuxDeviceNames.containsPartial(device.name));

      List<BLEScanResult> nuxBle = [], ctrlBle = [];
      for (var dev in scannedDevices) {
        nuxBle.add(QuickBlueScanResult(dev));
      }

      onScanResults(nuxBle, []);
      setMidiSetupStatus(MidiSetupStatus.deviceFound);
    });
  }
}
*/