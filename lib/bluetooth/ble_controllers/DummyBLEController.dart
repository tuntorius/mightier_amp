import 'dart:async';

import 'BLEController.dart';

class DummyBLEController extends BLEController {
  DummyBLEController(List<String> forcedDevices) : super(forcedDevices);

  @override
  Future<BLEConnection?> connectToDevice(BLEDevice device) {
    throw UnimplementedError();
  }

  @override
  BLEDevice? get connectedDevice => null;

  @override
  void disconnectDevice() {}

  @override
  void dispose() {}

  @override
  Future<bool> isAvailable() async {
    return false;
  }

  @override
  bool get isWriteReady => false;

  @override
  StreamSubscription<List<int>> registerDataListener(
      Function(List<int> p1) listener) {
    throw UnimplementedError();
  }

  @override
  void startScanning() {}

  @override
  void stopScanning() {}

  @override
  Future writeToCharacteristic(List<int> data, bool noResponse) {
    return Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future setNotificationEnabled(bool enabled) {
    return Future.delayed(const Duration(milliseconds: 100));
  }
}
