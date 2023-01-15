import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mighty_ble.dart';
import 'mighty_ble_platform_interface.dart';

/// An implementation of [MightyBlePlatform] that uses method channels.
class MethodChannelMightyBle extends MightyBlePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mighty_ble');

  final StreamController<List<ScanResult>> _scanResults = StreamController();

  Function(String address, List<int> data)? _notifyCallback;

  @override
  Stream<List<ScanResult>> get scanResults => _scanResults.stream;

  final StreamController<bool> _scanStatus = StreamController();

  @override
  Stream<bool> get scanStatus => _scanStatus.stream;

  final StreamController<String> _onConnect = StreamController();

  @override
  Stream<String> get onConnect => _onConnect.stream;

  final StreamController<String> _onDisconnect = StreamController();

  @override
  Stream<String> get onDisconnect => _onDisconnect.stream;

  MethodChannelMightyBle() {
    methodChannel.setMethodCallHandler(methodHandler); // set method handler
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future init() async {
    await methodChannel.invokeMethod("initBle");
  }

  @override
  Future<bool> isAvailable() async {
    return await methodChannel.invokeMethod("isAvailable");
  }

  @override
  Future startScan() async {
    await methodChannel.invokeMethod("startScan");
    _scanStatus.add(true);
  }

  @override
  Future stopScan() async {
    await methodChannel.invokeMethod("stopScan");
    _scanStatus.add(false);
  }

  @override
  Future connect(String id) async {
    _scanStatus.add(false);
    await methodChannel.invokeMethod("connect", id);
  }

  @override
  Future disconnect(String id) async {
    await methodChannel.invokeMethod("disconnect", id);
  }

  @override
  Future setNotificationEnabled(String id, bool enabled) async {
    var args = {"id": id, "enabled": enabled};
    return await methodChannel.invokeMethod("setNotificationEnabled", args);
  }

  @override
  Future<int> writeBle(String id, List<int> byteArray) async {
    var args = {"id": id, "value": Uint8List.fromList(byteArray)};
    return await methodChannel.invokeMethod("write", args);
  }

  @override
  void setNotifyCallback(
      Function(String address, List<int> data) notifyCallback) {
    _notifyCallback = notifyCallback;
  }

  Future<void> methodHandler(MethodCall call) async {
    switch (call.method) {
      case "onScanResult":
        var result = call.arguments;
        ScanResult sr =
            ScanResult(result['id'], result['name'], result['hasMidiService']);

        //todo: stupid
        _scanResults.add([sr]);
        break;
      case "onConnected":
        print("Flutter: on connected ${call.arguments}");
        _onConnect.add(call.arguments.toString());
        break;
      case "onDisconnected":
        print("Flutter: on disconnected ${call.arguments}");
        _onDisconnect.add(call.arguments.toString());
        break;
      case "onCharacteristicNotify":
        var result = call.arguments;
        var id = result['id'];
        Uint8List value = result['value'];
        _notifyCallback?.call(id, value.toList());
        break;
      default:
        print('no method handler for method ${call.method}');
    }
  }
}
