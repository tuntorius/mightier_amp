/*
Controller that uses flutter_web_bluetooth plugin for adding BLE support for web
https://pub.dev/packages/flutter_web_bluetooth

Summary
State: works somewhat

The plugin works, but is not very reliable. Can't determine if the platform
has bluetooth hardware or not. Connects half of the time, sometimes disconnects
in 1-2 minutes of inactivity. This may be due to the very early staage of
web bluetooth standard. 
*/

/*
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:flutter_web_bluetooth/js_web_bluetooth.dart';
import 'BLEController.dart';

class WebBleScanResult extends BLEScanResult {
  @override
  String get id => (device as WebBleDevice).device.id.toString().toLowerCase();

  @override
  String get name => (device as WebBleDevice).device.name ?? "Unknown";

  WebBleScanResult(BluetoothDevice dev) {
    device = WebBleDevice(dev);
  }
}

class WebBleDevice extends BLEDevice {
  final BluetoothDevice _device;
  BluetoothDevice get device => _device;

  WebBleDevice(this._device);

  @override
  String get name => _device.name ?? "Unknown";

  @override
  String get id => _device.id.toString().toLowerCase();

  @override
  Stream<BleDeviceState> get state {
    StreamController<BleDeviceState> stateStream = StreamController();
    StreamSubscription<bool> s = _device.connected.listen((event) {
      if (event) {
        stateStream.add(BleDeviceState.disconnected);
      } else {
        stateStream.add(BleDeviceState.connected);
      }
    });

    stateStream.onCancel = () {
      s.cancel();
    };
    return stateStream.stream;
  }
}

class WebBleController extends BLEController {
  WebBleController(List<String> forcedDevices) : super(forcedDevices);

  StreamSubscription<bool>? _bluetoothStateSubscription;
  StreamSubscription<bool>? _deviceStreamSubscription;

  WebBleDevice? _device;
  @override
  BLEDevice? get connectedDevice => _device;

  BluetoothCharacteristic? _characteristic;
  bool? lastBleState;

  @override
  Future init(ScanResultsCallback callback) async {
    await super.init(callback);
    _subscribeBleState();
  }

  @override
  Future<bool> isAvailable() async {
    // The bluetooth api exists in this user agent.
    final supported = FlutterWebBluetooth.instance
        .isBluetoothApiSupported; // A stream that says if a bluetooth adapter is available to the browser.
    return supported;
  }

  @override
  Future<BLEConnection?> connectToDevice(BLEDevice dev) async {
    var ownDevice = dev as WebBleDevice;
    var device = ownDevice.device;
    setMidiSetupStatus(MidiSetupStatus.deviceConnecting);
    await device.connect();
    final services = await device.discoverServices();
    final service = services
        .firstWhere((service) => service.uuid == BLEController.midiServiceGuid);
    // Now get the characteristic
    _characteristic =
        await service.getCharacteristic(BLEController.midiCharacteristicGuid);
    await _characteristic?.startNotifications();
    _device = dev;
    setMidiSetupStatus(MidiSetupStatus.deviceConnected);

    _deviceStreamSubscription = device.connected.listen((event) {
      if (event == false) {
        _deviceStreamSubscription?.cancel();
        _device = null;
        setMidiSetupStatus(MidiSetupStatus.deviceDisconnected);
      }
    });
    return null;
  }

  @override
  void disconnectDevice() {
    // TODO: implement disconnectDevice
    _device?.device.disconnect();
    _device = null;
    _characteristic = null;
  }

  @override
  void startScanning() async {
    final requestOptions = RequestOptionsBuilder.acceptAllDevices(
        optionalServices: [BLEController.midiServiceGuid]);

    try {
      final device =
          await FlutterWebBluetooth.instance.requestDevice(requestOptions);
      final scanResult = WebBleScanResult(device);
      onScanResults([scanResult], []);
      setMidiSetupStatus(MidiSetupStatus.deviceFound);
    } on UserCancelledDialogError {
      // The user cancelled the dialog
    } on DeviceNotFoundError {
      // There is no device in range for the options defined above
    }
  }

  @override
  void stopScanning() {}

  @override
  StreamSubscription<List<int>> registerDataListener(
      Function(List<int> data) listener) {
    StreamController<List<int>> streamCtrl = StreamController();
    var dataSubscr = _characteristic?.value.listen((data) {
      var listData = data.buffer.asUint8List().toList(growable: false);
      streamCtrl.add(listData);
    });

    streamCtrl.onCancel = () {
      dataSubscr?.cancel();
    };

    return streamCtrl.stream.listen(listener);
  }

  @override
  bool get isWriteReady => _characteristic != null;

  @override
  Future writeToCharacteristic(List<int> data) async {
    Uint8List byteData = Uint8List.fromList(data);
    return _characteristic!.writeValueWithoutResponse(byteData);
  }

  @override
  void dispose() {
    _bluetoothStateSubscription?.cancel();
  }

  _subscribeBleState() {
    _bluetoothStateSubscription =
        FlutterWebBluetooth.instance.isAvailable.listen((event) {
      if (lastBleState != null && lastBleState == event) return;
      debugPrint("Ble state ${event.toString()}");
      bleState = event ? BleState.on : BleState.off;
      lastBleState = event;
      if (event) {
        bleState = BleState.on;
        setMidiSetupStatus(MidiSetupStatus.deviceSearching);
        startScanning();
      } else {
        bleState = BleState.off;
        setMidiSetupStatus(MidiSetupStatus.bluetoothOff);
      }
    });
  }
}
*/