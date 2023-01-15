import 'mighty_ble_platform_interface.dart';

enum DeviceConnectState { connected, disconnected }

class ScanResult {
  String id;
  String name;
  bool hasMidiService;
  ScanResult(this.id, this.name, this.hasMidiService);
}

class MightyBle {
  Stream<List<ScanResult>> get scanResults =>
      MightyBlePlatform.instance.scanResults;

  Stream<bool> get scanStatus => MightyBlePlatform.instance.scanStatus;

  Stream<String> get onConnect => MightyBlePlatform.instance.onConnect;
  Stream<String> get onDisconnect => MightyBlePlatform.instance.onDisconnect;

  Future<String?> getPlatformVersion() {
    return MightyBlePlatform.instance.getPlatformVersion();
  }

  Future init() {
    return MightyBlePlatform.instance.init();
  }

  Future<bool> isAvailable() {
    return MightyBlePlatform.instance.isAvailable();
  }

  Future startScan() {
    return MightyBlePlatform.instance.startScan();
  }

  Future stopScan() {
    return MightyBlePlatform.instance.stopScan();
  }

  Future connect(String id) {
    return MightyBlePlatform.instance.connect(id);
  }

  Future disconnect(String id) {
    return MightyBlePlatform.instance.disconnect(id);
  }

  Future setNotificationEnabled(String id, bool enabled) async {
    return MightyBlePlatform.instance.setNotificationEnabled(id, enabled);
  }

  Future<int> writeBle(String id, List<int> byteArray) {
    return MightyBlePlatform.instance.writeBle(id, byteArray);
  }

  void setNotifyCallback(
      Function(String address, List<int> data) notifyCallback) {
    MightyBlePlatform.instance.setNotifyCallback(notifyCallback);
  }
}
