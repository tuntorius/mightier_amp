import 'dart:async';
import 'package:mighty_plug_manager/utilities/list_extenstions.dart';

import 'BLEController.dart';
import 'package:mighty_ble/mighty_ble.dart';

class MBScanResult extends BLEScanResult {
  @override
  String get id => (device as MBDevice).id;

  @override
  String get name => (device as MBDevice).name;

  MBScanResult(ScanResult sr) {
    device = MBDevice(sr.id, sr.name);
  }
}

class MBDevice extends BLEDevice {
  final String _device;
  final String _name;
  String get device => _device;
  final StreamController<BleDeviceState> _stateStream = StreamController();

  MBDevice(this._device, this._name);

  @override
  String get name => _name;

  @override
  String get id => _device;

  @override
  Stream<BleDeviceState> get state => _stateStream.stream;

  void statePost(BleDeviceState state) {
    _stateStream.add(state);
  }

  void dispose() {
    _stateStream.close();
  }
}

class MightyBLEController extends BLEController {
  MightyBle mightyBle = MightyBle();

  MightyBLEController(List<String> forcedDevices) : super(forcedDevices);

  StreamSubscription<bool>? _scanningStatusSubscription;
  //StreamSubscription<BluetoothState>? _bluetoothStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  Future init(ScanResultsCallback callback) async {
    await super.init(callback);
    mightyBle.init();
    //_subscribeBleState();
    _subscribeScanningStatus();
    _subscribeScanResults();
    _subscribeConnectStatus();
    mightyBle.setNotifyCallback(_notifyCallback);

    setMidiSetupStatus(MidiSetupStatus.deviceIdle);
    bleState = BleState.on;
  }

  MBDevice? _connectedDevice;
  MBDevice? _tmpConnectingDevice;

  @override
  MBDevice? get connectedDevice => _connectedDevice;

  StreamController<List<int>>? _dataStreamController;

  @override
  Future<BLEConnection?> connectToDevice(BLEDevice device) async {
    var ownDevice = (device as MBDevice);
    _tmpConnectingDevice = device;
    mightyBle.connect(ownDevice.id);
    ownDevice.statePost(BleDeviceState.connecting);
    setMidiSetupStatus(MidiSetupStatus.deviceConnecting);
    return null;
  }

  @override
  void disconnectDevice() async {
    if (_connectedDevice == null) {
      return;
    }
    var ownDevice = (connectedDevice as MBDevice);
    _connectedDevice!.statePost(BleDeviceState.disconnecting);
    await mightyBle.disconnect(ownDevice.id);
  }

  @override
  void dispose() {
    _scanningStatusSubscription?.cancel();
    _scanSubscription?.cancel();
    _dataStreamController?.close();
  }

  @override
  Future<bool> isAvailable() async {
    return await mightyBle.isAvailable();
  }

  @override
  bool get isWriteReady => _connectedDevice != null;

  @override
  Future writeToCharacteristic(List<int> data, bool noResponse) {
    return mightyBle.writeBle(_connectedDevice!.id, data);
  }

  @override
  StreamSubscription<List<int>> registerDataListener(
      Function(List<int> value) listener) {
    _dataStreamController = StreamController();
    return _dataStreamController!.stream.listen(listener);
  }

  @override
  void startScanning() {
    mightyBle.startScan();
    setMidiSetupStatus(MidiSetupStatus.deviceSearching);
  }

  @override
  void stopScanning() {
    mightyBle.stopScan();
  }

/*
  @override
  Future setNotificationEnabled(bool enabled) async {
    if (_connectedDevice == null) return;
    return mightyBle.setNotificationEnabled(_connectedDevice!.id, enabled);
  }
*/
  _notifyCallback(String id, List<int> data) {
    if (_connectedDevice != null) {
      if (_connectedDevice!.id == id) {
        _dataStreamController?.add(data);
      }
    }
  }

  _subscribeScanningStatus() {
    _scanningStatusSubscription = mightyBle.scanStatus.listen((event) {
      print("ScanStatus $event");
      setScanningStatus(event);
    });
  }

  _subscribeScanResults() {
    _scanSubscription = mightyBle.scanResults.listen((results) {
      List<ScanResult> nuxDevices = <ScanResult>[];
      List<ScanResult> controllerDevices = <ScanResult>[];
      //filter the scan results
      var devNames = deviceListProvider.call();

      for (ScanResult result in results) {
        if (devNames.containsPartial(result.name)) {
          nuxDevices.add(result);
        } else {
          //check if it is in the special device list
          if (result.hasMidiService || forcedDevices.contains(result.name)) {
            controllerDevices.add(result);
          }
        }
      }
      //convert to blescanresult
      List<BLEScanResult> nuxBle = [], ctrlBle = [];
      for (var dev in nuxDevices) {
        nuxBle.add(MBScanResult(dev));
      }
      for (var dev in controllerDevices) {
        ctrlBle.add(MBScanResult(dev));
      }
      onScanResults(nuxBle, ctrlBle);
      setMidiSetupStatus(MidiSetupStatus.deviceFound);
      for (ScanResult r in results) {
        print('${r.name} found!');
      }
    });
  }

  _subscribeConnectStatus() {
    mightyBle.onConnect.listen((id) {
      print("MightyBle on connect $id");
      if (_tmpConnectingDevice?.id == id) {
        _connectedDevice = _tmpConnectingDevice;
        _tmpConnectingDevice = null;
        setMidiSetupStatus(MidiSetupStatus.deviceConnected);
        _connectedDevice!.statePost(BleDeviceState.connected);
      }
    });
    mightyBle.onDisconnect.listen((id) {
      print("MightyBle on disconnect $id");
      if (id == _connectedDevice?.id) {
        setMidiSetupStatus(MidiSetupStatus.deviceDisconnected);
        _connectedDevice!.statePost(BleDeviceState.disconnected);
        _connectedDevice!.dispose();
        _connectedDevice = null;
        _dataStreamController?.close();
      }
    });
  }
}
