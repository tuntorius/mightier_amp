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

  ///Returns a stream telling the connection state of a device
  ///Used only for MIDI foot controllers and not for amps
  Stream<BleDeviceState> get state;
}

/// Ble connection class used for MIDI foot controllers only
/// Not needed for amps
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

  void sendData(List<int> data) {
    var queueLength = dataQueue.length;

    // Deduplicate standard CC messages to prevent saturation
    if (data.length > 3 && data[2] == MidiMessageValues.controlChange && dataQueue.isNotEmpty) {
      dataQueue.removeWhere((element) =>
          element.length > 3 &&
          element[2] == MidiMessageValues.controlChange &&
          element[3] == data[3]);
    }

    // Deduplicate custom NF SysEx messages so rapid slider movements don't choke the BLE queue.
    // The mighty-nam payload writes op(1) inside [0x80, 0x80, 0xF0, 0x43, 0x58, 0x70, 0x04, 0x02, 0x4E, 0x46]
    // where 0x4E ('N') is data[8] and 0x46 ('F') is data[9].
    if (data.length > 10 &&
        data[2] == MidiMessageValues.sysExStart &&
        data[8] == 0x4E && 
        data[9] == 0x46) {
      if (dataQueue.length > 1) {
        var first = dataQueue.removeFirst();
        dataQueue.removeWhere((element) =>
            element.length > 10 &&
            element[2] == MidiMessageValues.sysExStart &&
            element[8] == 0x4E &&
            element[9] == 0x46);
        dataQueue.addFirst(first);
      }
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
    bool noResponse = true;
    while (dataQueue.isNotEmpty) {
      if (connectedDevice == null) {
        dataQueue.clear();
        break;
      }
      try {
        if (isWriteReady) {
          var data = dataQueue.first;

          // Special NUX system commands that require response
          if (Platform.isAndroid &&
              data[2] == MidiMessageValues.sysExStart &&
              data[6] == SyxMsg.kSYX_MODULELINK) {
            noResponse = false;
            await Future.delayed(const Duration(milliseconds: 100));
          } else if (data.length > 10 &&
              data[2] == MidiMessageValues.sysExStart &&
              data[8] == 0x4E &&
              data[9] == 0x46) {
            noResponse = true;
          }
          await writeToCharacteristic(data, noResponse);
          if (Platform.isAndroid) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
          noResponse = true;
          dataQueue.removeFirst();
        } else {
          dataQueue.clear();
        }
      } catch (e) {
        debugPrint(e.toString());
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