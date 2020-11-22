import 'dart:async';
import 'dart:collection';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mighty_plug_manager/main.dart';
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

  static final BLEMidiHandler _bleHandler = BLEMidiHandler._();

  FlutterBlue flutterBlue = FlutterBlue.instance;

  StreamController<midiSetupStatus> _status = StreamController.broadcast();
  Stream<midiSetupStatus> get status => _status.stream;

  BluetoothState bluetoothState = BluetoothState.unknown;

  BluetoothDevice _device;
  BluetoothService _midiService;
  BluetoothCharacteristic _midiCharacteristic;

  bool queueFree = true;

  factory BLEMidiHandler() {
    return _bleHandler;
  }

  // Future<List<MidiDevice>> get devices {
  //   return _midiCommand.devices;
  // }
  List<ScanResult> scanResults;

  BluetoothDevice get connectedDevice {
    return _device;
  }

  StreamSubscription<List<ScanResult>> _scanSubscription;

  BLEMidiHandler._() {
    //_midiCommand.teardown();

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
          // TODO: Handle this case.
          _status.add(midiSetupStatus.bluetoothOff);
          break;
        case BluetoothState.unavailable:
          // TODO: Handle this case.
          _status.add(midiSetupStatus.bluetoothOff);
          break;
        case BluetoothState.unauthorized:
          // TODO: Handle this case.
          _status.add(midiSetupStatus.bluetoothOff);
          break;
        case BluetoothState.turningOn:
          break;
        case BluetoothState.on:
          _status.add(midiSetupStatus.deviceSearching);
          startScanning();
          break;
        case BluetoothState.turningOff:
        case BluetoothState.off:
          _status.add(midiSetupStatus.bluetoothOff);
          _device = null;
          break;
      }
    });

    _scanSubscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      scanResults = results;
      _status.add(midiSetupStatus.deviceFound);
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
  }

  void startScanning() {
    _status.add(midiSetupStatus.deviceSearching);
    if (bluetoothState != BluetoothState.on) return;
    flutterBlue.startScan(
        timeout: Duration(seconds: 8),
        withServices: [Guid(midiService)]).then((result) {
      //if device is not connected after the search - set to idle
      if (_device == null) _status.add(midiSetupStatus.deviceIdle);
    });
  }

  void stopScanning() {
    if (bluetoothState != BluetoothState.on) return;
    flutterBlue.stopScan();
  }

  void connectToDevice(BluetoothDevice device) async {
    if (bluetoothState != BluetoothState.on) return;
    stopScanning();
    _status.add(midiSetupStatus.deviceConnecting);
    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      if (e.code == 'already_connected') return;
      throw (e);
    } finally {
      _device = device;

      List<BluetoothService> services = await device.discoverServices();
      //find midi service
      services.forEach((element) {
        if (element.uuid == Guid(midiService)) _midiService = element;
      });

      _midiService.characteristics.forEach((element) {
        if (element.uuid == Guid(midiCharacteristic))
          _midiCharacteristic = element;

        _midiCharacteristic.setNotifyValue(true);

        queueFree = true;
        _status.add(midiSetupStatus.deviceConnected);
        device.state.listen((event) {
          if (event == BluetoothDeviceState.disconnected) {
            _device = null;
            queueFree = true;
            _status.add(midiSetupStatus.deviceDisconnected);
          }
        });
      });
    }
  }

  void disconnectDevice() async {
    await _device.disconnect();
    queueFree = true;
    _device = null;
  }

  StreamSubscription<List<int>> registerDataListener(
      Function(List<int>) listener) {
    return _midiCharacteristic.value.listen(listener);
    //StreamSubscription<List<int>> _rxSubscription =
    //   _midiCommand.onMidiDataReceived.listen(listener);
  }

  ListQueue<List<int>> dataQueue = ListQueue<List<int>>();

  void sendData(List<int> _data) {
    dataQueue.addLast(_data);
    if (queueFree) queueSender();
  }

  void queueSender() async {
    queueFree = false;
    Stopwatch stopwatch = new Stopwatch()..start();
    //List<int> currentData = List<int>();
    while (dataQueue.isNotEmpty) {
      //TODO: sending here
      await _midiCharacteristic.write(dataQueue.removeFirst(),
          withoutResponse: true);
    }

    Settings.print('sending executed in ${stopwatch.elapsed.inMilliseconds}');
    queueFree = true;
  }

  void dispose() {
    _scanSubscription.cancel();
    _device.disconnect();
  }
}
