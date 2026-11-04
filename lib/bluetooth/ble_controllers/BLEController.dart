import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../devices/NuxConstants.dart';

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

enum BleError {
  unavailable,
  permissionDenied,
  locationServiceOff,
  scanPermissionDenied
}

typedef ScanResultsCallback = void Function(
    List<BLEScanResult> nuxDevices, List<BLEScanResult> controllerDevices);

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
  static const String midiCharacteristicGuid =
      "7772e5db-3868-4112-a1a9-f2669d106bf3";

  MidiSetupStatus _currentStatus = MidiSetupStatus.unknown;
  final StreamController<MidiSetupStatus> _status =
      StreamController.broadcast();
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

  Future init(ScanResultsCallback callback) async {
    onScanResults = callback;
  }

  Future<bool> isAvailable();

  void startScanning();
  void stopScanning();
  Future<BLEConnection?> connectToDevice(BLEDevice device);
  void disconnectDevice();
  StreamSubscription<List<int>> registerDataListener(
      Function(List<int>) listener);

  bool _isNfSysEx(List<int> data) {
    return data.length > 10 &&
        data[2] == MidiMessageValues.sysExStart &&
        data[8] == 0x4E &&
        data[9] == 0x46;
  }

  void sendData(List<int> data) {
    var queueLength = dataQueue.length;
    if (data.length > 3 &&
        data[2] == MidiMessageValues.controlChange &&
        dataQueue.isNotEmpty) {
      var inFlight = dataQueue.removeFirst();
      dataQueue.removeWhere((element) =>
          element.length > 3 &&
          element[2] == MidiMessageValues.controlChange &&
          element[3] == data[3]);
      dataQueue.addFirst(inFlight);
    }
    if (_isNfSysEx(data) && dataQueue.isNotEmpty) {
      var inFlight = dataQueue.removeFirst();
      dataQueue.removeWhere((element) => _isNfSysEx(element));
      dataQueue.addFirst(inFlight);
    }

    dataQueue.addLast(data);
    if (queueLength == 0) _queueSender();
  }

  void clearDataQueue() {
    dataQueue.clear();
  }

  VoidCallback? _onQueueEmpty;

  void onDataQueueEmpty(VoidCallback onQueueEmpty) {
    if (dataQueue.isEmpty) {
      onQueueEmpty.call();
    } else {
      _onQueueEmpty = onQueueEmpty;
    }
  }

  void dispose();

  void _queueSender() async {
    while (dataQueue.isNotEmpty) {
      if (connectedDevice == null) {
        dataQueue.clear();
        break;
      }
      var data = dataQueue.first;
      try {
        if (isWriteReady) {
          bool noResponse = true;

          // PROTECT A2DP AUDIO: 
          // If the OS spams massive SysEx writes consecutively without response pacing,
          // it chokes the shared Bluetooth cache and drops music player audio.
          if ((Platform.isAndroid || Platform.isIOS) &&
              data.length > 6 &&
              data[2] == MidiMessageValues.sysExStart &&
              data[6] == SyxMsg.kSYX_MODULELINK) {
            noResponse = false;
            await Future.delayed(const Duration(milliseconds: 100));
          }
          
          await writeToCharacteristic(data, noResponse);

          if (Platform.isAndroid || Platform.isIOS) {
            // SysEx payload pacing to save the audio stream
            if (data.length > 20) {
              await Future.delayed(const Duration(milliseconds: 25));
            } else {
              await Future.delayed(const Duration(milliseconds: 8));
            }
          }
        } else {
          dataQueue.clear();
          break;
        }
      } catch (e) {
        debugPrint("BLE write error: $e");
      } finally {
        if (dataQueue.isNotEmpty && identical(dataQueue.first, data)) {
          dataQueue.removeFirst();
        }
      }
    }
    _onQueueEmpty?.call();
    _onQueueEmpty = null;
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
  Future writeToCharacteristic(List<int> data, bool noResponse);
}