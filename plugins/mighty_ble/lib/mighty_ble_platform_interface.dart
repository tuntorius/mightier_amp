import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'mighty_ble.dart';
import 'mighty_ble_method_channel.dart';

abstract class MightyBlePlatform extends PlatformInterface {
  /// Constructs a MightyBlePlatform.
  MightyBlePlatform() : super(token: _token);

  Stream<bool> get scanStatus;
  Stream<List<ScanResult>> get scanResults;
  Stream<String> get onConnect;
  Stream<String> get onDisconnect;

  static final Object _token = Object();

  static MightyBlePlatform _instance = MethodChannelMightyBle();

  /// The default instance of [MightyBlePlatform] to use.
  ///
  /// Defaults to [MethodChannelMightyBle].
  static MightyBlePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MightyBlePlatform] when
  /// they register themselves.
  static set instance(MightyBlePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future init() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isAvailable() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future startScan() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future stopScan() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future connect(String id) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future disconnect(String id) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future setNotificationEnabled(String id, bool enabled) {
    throw UnimplementedError(
        'setNotificationEnabled() has not been implemented.');
  }

  Future<int> writeBle(String id, List<int> byteArray) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void setNotifyCallback(
      Function(String address, List<int> data) notifyCallback) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
