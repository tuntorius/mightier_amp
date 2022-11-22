import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

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

enum BleState { off, on }

enum BleDeviceState { disconnected, connecting, connected, disconnecting }

enum BleError { unavailable, permissionDenied, locationServiceOff }

typedef ScanResultsCallback = void Function(List<BLEScanResult> nuxDevices, List<BLEScanResult> controllerDevices);

abstract class BLEScanResult {
  String get id;
  String get name;

  late BLEDevice _device;

  @protected
  set device(BLEDevice val) => _device = val;
  BLEDevice get device => _device;
}

abstract class BLEDevice {
  String get name;
  String get id;

  Stream<BleDeviceState> get state;
}

class BLEConnection {
  final Stream<List<int>> _dataStream;
  Stream<List<int>> get data => _dataStream;

  BLEConnection(this._dataStream);
}

abstract class BLEController {
  static const String midiServiceGuid = "03b80e5a-ede8-4b33-a751-6ce34ec4c700";
  static const String midiCharacteristicGuid = "7772e5db-3868-4112-a1a9-f2669d106bf3";

  MidiSetupStatus _currentStatus = MidiSetupStatus.unknown;
  final StreamController<MidiSetupStatus> _status = StreamController.broadcast();
  Stream<MidiSetupStatus> get status => _status.stream;

  BleState _bleState = BleState.off;
  @protected
  set bleState(BleState state) => _bleState = state;
  BleState get bleState => _bleState;

  @protected
  set currentStatus(MidiSetupStatus val) => _currentStatus = val;
  MidiSetupStatus get currentStatus => _currentStatus;

  BLEDevice? get connectedDevice;
  final StreamController<bool> _scanStatus = StreamController.broadcast();
  Stream<bool> get isScanningStream => _scanStatus.stream;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  ListQueue<List<int>> dataQueue = ListQueue<List<int>>();

  @protected
  late List<String> Function() deviceListProvider;

  @protected
  late ScanResultsCallback onScanResults;

  @protected
  List<String> forcedDevices;

  BLEController(this.forcedDevices);

  void setAmpDeviceIdProvider(List<String> Function() provider) {
    deviceListProvider = provider;
  }

  void init(ScanResultsCallback callback) {
    onScanResults = callback;
  }

  Future<bool> isAvailable();

  void startScanning();
  void stopScanning();

  Future<BLEConnection?> connectToDevice(BLEDevice device);
  void disconnectDevice();

  StreamSubscription<List<int>> registerDataListener(Function(List<int>) listener);

  void sendData(List<int> data) {
    var queueLength = dataQueue.length;
    dataQueue.addLast(data);
    if (queueLength == 0) _queueSender();
  }

  void dispose();

  void _queueSender() async {
    //Stopwatch stopwatch = Stopwatch()..start();
    //List<int> currentData = List<int>();

    while (dataQueue.isNotEmpty) {
      if (connectedDevice == null) {
        dataQueue.clear();
        break;
      }
      try {
        if (isWriteReady) {
          var data = dataQueue.first;
          await writeToCharacteristic(data);
          dataQueue.removeFirst();
        } else {
          dataQueue.clear();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    // if (kDebugMode) {
    //   Settings.print('sending executed in ${stopwatch.elapsed.inMilliseconds}');
    // }
  }

  @protected
  void setMidiSetupStatus(MidiSetupStatus status) {
    _currentStatus = status;
    _status.add(status);
  }

  @protected
  void setScanningStatus(bool scanning) {
    _isScanning = scanning;
    _scanStatus.add(scanning);
  }

  bool get isWriteReady;
  Future writeToCharacteristic(List<int> data);
}
