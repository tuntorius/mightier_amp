/*
Controller that uses win_ble plugin for adding BLE support for Windows
https://pub.dev/packages/win_ble

Summary
State: Unusable

BLE support detection works 10% of the time
Connection to the device works
IF the peripheral device sends a packet that has a byte with value 0x40,
maybe also 0x41, the packet is not received at all:
https://github.com/rohitsangwan01/win_ble/issues/17
*/

/*
import 'dart:async';
import 'dart:typed_data';

import 'package:win_ble/win_ble.dart' as ble;

import 'BLEController.dart';

class WinBleScanResult extends BLEScanResult {
  @override
  String get id => (device as WinBleDevice).id;

  @override
  String get name => (device as WinBleDevice).name;

  WinBleScanResult(ble.BleDevice dev) {
    device = WinBleDevice(dev);
  }
}

class WinBleDevice extends BLEDevice {
  final ble.BleDevice _device;

  WinBleDevice(this._device);

  @override
  // TODO: implement id
  String get id => _device.address;

  @override
  // TODO: implement name
  String get name => _device.name;

  String get address => _device.address;

  ble.BleDevice get device => _device;

  @override
  // TODO: implement state
  Stream<BleDeviceState> get state => throw UnimplementedError();
}

class WinBleController extends BLEController {
  WinBleController(List<String> forcedDevices) : super(forcedDevices);

  WinBleDevice? _device;
  ble.BleCharacteristic? _midiCharacteristic;
  bool _connectInProgress = false;

  bool? _bleSupported;
  bool _scanning = false;
  DateTime _scanStarted = DateTime.now();
  List<ble.BleDevice> scannedDevices = [];

  late List<String> nuxDeviceNames;

  StreamSubscription<ble.BleDevice>? _scanSubscription;
  StreamSubscription<ble.BleState>? _bluetoothStateSubscription;
  StreamSubscription<bool>? _deviceStreamSubscription;

  @override
  BLEDevice? get connectedDevice => _device;

  @override
  Future init(ScanResultsCallback callback) async {
    await super.init(callback);

    nuxDeviceNames = deviceListProvider.call();
    _subscribeBleState();
    _subscribeScanResults();

    await ble.WinBle.initialize(enableLog: false);
    print("WinBle controller init.");

    bleState = BleState.on;
  }

  @override
  Future<bool> isAvailable() async {
    for (int i = 0; i < 10; i++) {
      if (_bleSupported != null) break;
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (_bleSupported == null) {
      print("Can't get info if bluetooth is supported");
    }
    return _bleSupported ?? false;
  }

  @override
  void startScanning() {
    if (bleState == BleState.off) return;

    scannedDevices.clear();
    _scanSubscription?.cancel();
    _subscribeScanResults();
    ble.WinBle.startScanning();
    setMidiSetupStatus(MidiSetupStatus.deviceSearching);
    setScanningStatus(true);
    _scanning = true;
    _scanStarted = DateTime.now();
  }

  @override
  void stopScanning() {
    if (bleState == BleState.off) return;
    _scanSubscription?.cancel();
    ble.WinBle.stopScanning();
    setScanningStatus(false);
    _scanning = false;
  }

  @override
  Future<BLEConnection?> connectToDevice(BLEDevice device) async {
    if (bleState != BleState.on) return null;
    WinBleDevice ownDevice = device as WinBleDevice;

    bool ampDevice = false;
    if (deviceListProvider.call().contains(ownDevice.name)) {
      ampDevice = true;
      if (_connectInProgress || _device != null) {
        print("Denying secondary connection!");
        return null;
      }
    }

    _connectInProgress = true;
    stopScanning();

    setMidiSetupStatus(MidiSetupStatus.deviceConnecting);

    try {
      await ble.WinBle.connect(ownDevice.address);
    } on Exception {
      _connectInProgress = false;
      return null;
    } catch (e) {
      print("Connect error $e");
      _connectInProgress = false;
      return null;
    }

    if (ampDevice) {
      if (_device != null) return null;
      _device = device;
    }

    var services = await ble.WinBle.discoverServices(_device!.address);

    if (services.contains(BLEController.midiServiceGuid)) {
      List<ble.BleCharacteristic> bleCharacteristics =
          await ble.WinBle.discoverCharacteristics(
              address: _device!.address,
              serviceId: BLEController.midiServiceGuid);

      for (var characteristic in bleCharacteristics) {
        if (characteristic.uuid == BLEController.midiCharacteristicGuid) {
          if (ampDevice) {
            _connectAmpDevice(_device!.device, characteristic);
          } else {
            ble.WinBle.subscribeToCharacteristic(
                address: _device!.address,
                serviceId: BLEController.midiServiceGuid,
                characteristicId: characteristic.uuid);
            _connectInProgress = false;
            //Stream  _connectionStream =
            //ble.WinBle.connectionStreamOf(_device.address)
            //return BLEConnection(characteristic.value);
          }
          break;
        }
      }
    }
    return null;
  }

  void _connectAmpDevice(
      ble.BleDevice device, ble.BleCharacteristic characteristic) async {
    _midiCharacteristic = characteristic;

    await ble.WinBle.subscribeToCharacteristic(
        address: device.address,
        serviceId: BLEController.midiServiceGuid,
        characteristicId: characteristic.uuid);

    _connectInProgress = false;

    setMidiSetupStatus(MidiSetupStatus.deviceConnected);
    _deviceStreamSubscription =
        ble.WinBle.connectionStreamOf(device.address).listen((event) {
      if (event == false) {
        _deviceStreamSubscription?.cancel();
        _device = null;
        _midiCharacteristic = null;
        _connectInProgress = false;
        setMidiSetupStatus(MidiSetupStatus.deviceDisconnected);
      }
    });
  }

  @override
  void disconnectDevice() async {
    if (bleState != BleState.on) return;
    if (_device != null) {
      _connectInProgress = false;
      await ble.WinBle.disconnect(_device!.address);
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    _deviceStreamSubscription?.cancel();
    ble.WinBle.dispose();
  }

  @override
  StreamSubscription<List<int>> registerDataListener(
      Function(List<int> data) listener) {
    StreamController<List<int>> streamCtrl = StreamController();

    // ble.WinBle.characteristicValueStream.listen((event) {
    //   print(event);
    // });

    var dataSubscr = ble.WinBle.characteristicValueStreamOf(
            address: _device!.address,
            serviceId: BLEController.midiServiceGuid,
            characteristicId: _midiCharacteristic!.uuid)
        .listen((data) {
      streamCtrl.add(data.cast<int>());
    });

    streamCtrl.onCancel = () {
      dataSubscr.cancel();
    };
    return streamCtrl.stream.listen(listener);
  }

  @override
  bool get isWriteReady => _midiCharacteristic != null;

  @override
  Future writeToCharacteristic(List<int> data) {
    Uint8List byteData = Uint8List.fromList(data);
    print("WinBle: Write $data");
    return ble.WinBle.write(
        address: _device!.address,
        service: BLEController.midiServiceGuid,
        characteristic: _midiCharacteristic!.uuid,
        data: byteData,
        writeWithResponse: false);
  }

  void _subscribeBleState() {
    _bluetoothStateSubscription =
        ble.WinBle.bleState.listen((ble.BleState event) {
      print("Ble Event: $event");
      _bleSupported = true;
      switch (event) {
        case ble.BleState.On:
          bleState = BleState.on;
          //setMidiSetupStatus(MidiSetupStatus.deviceSearching);
          //startScanning();
          break;
        case ble.BleState.Off:
        case ble.BleState.Unknown:
        case ble.BleState.Disabled:
          bleState = BleState.off;
          setMidiSetupStatus(MidiSetupStatus.bluetoothOff);
          if (_scanning) stopScanning();
          break;
        case ble.BleState.Unsupported:
          _bleSupported = false;
          break;
      }
    });
  }

  void _subscribeScanResults() {
    _scanSubscription = ble.WinBle.scanStream.listen((device) {
      final index = scannedDevices
          .indexWhere((element) => element.address == device.address);
      // Updating existing device
      if (index != -1) {
        if (device.name.isNotEmpty && scannedDevices[index].name.isEmpty) {
          scannedDevices[index].name = device.name;
        }

        if (device.serviceUuids.isNotEmpty &&
            scannedDevices[index].serviceUuids.isEmpty) {
          scannedDevices[index].serviceUuids = device.serviceUuids;
        }
      } else {
        scannedDevices.add(device);
      }

      if ((DateTime.now().difference(_scanStarted).inMilliseconds < 5000)) {
        return;
      }

      stopScanning();
      scannedDevices.retainWhere((device) =>
          nuxDeviceNames.containsPartial(device.name) &&
          device.serviceUuids.contains("{${BLEController.midiServiceGuid}}"));

      List<BLEScanResult> nuxBle = [], ctrlBle = [];
      for (var dev in scannedDevices) {
        nuxBle.add(WinBleScanResult(dev));
      }

      onScanResults(nuxBle, []);
      setMidiSetupStatus(MidiSetupStatus.deviceFound);
    });
  }
}
*/