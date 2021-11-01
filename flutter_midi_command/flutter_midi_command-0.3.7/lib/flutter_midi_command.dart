import 'dart:async';
import 'dart:io';

import 'dart:typed_data';
import 'package:flutter_midi_command_linux/flutter_midi_command_linux.dart';
import 'package:flutter_midi_command_platform_interface/flutter_midi_command_platform_interface.dart';
export 'package:flutter_midi_command_platform_interface/flutter_midi_command_platform_interface.dart' show MidiDevice, MidiPacket, MidiPort;

class MidiCommand {
  factory MidiCommand() {
    if (_instance == null) {
      _instance = MidiCommand._();
    }
    return _instance!;
  }

  MidiCommand._();

  static MidiCommand? _instance;

  static MidiCommandPlatform? __platform;

  StreamController<Uint8List> _txStreamCtrl = StreamController.broadcast();

  /// Get the platform specific implementation
  static MidiCommandPlatform get _platform {
    if (__platform != null) return __platform!;

    if (Platform.isLinux) {
      __platform = FlutterMidiCommandLinux();
    } else {
      __platform = MidiCommandPlatform.instance;
    }
    return __platform!;
  }

  /// Gets a list of available MIDI devices and returns it
  Future<List<MidiDevice>?> get devices async {
    return _platform.devices;
  }

  /// Starts scanning for BLE MIDI devices
  ///
  /// Found devices will be included in the list returned by [devices]
  Future<void> startScanningForBluetoothDevices() async {
    return _platform.startScanningForBluetoothDevices();
  }

  /// Stop scanning for BLE MIDI devices
  void stopScanningForBluetoothDevices() {
    _platform.stopScanningForBluetoothDevices();
  }

  /// Connects to the device
  void connectToDevice(MidiDevice device) {
    _platform.connectToDevice(device);
  }

  /// Disconnects from the device
  void disconnectDevice(MidiDevice device) {
    _platform.disconnectDevice(device);
  }

  /// Disconnects from all devices
  void teardown() {
    _platform.teardown();
  }

  /// Sends data to the currently connected device
  ///
  /// Data is an UInt8List of individual MIDI command bytes
  void sendData(Uint8List data, {String? deviceId, int? timestamp}) {
    _platform.sendData(data, deviceId: deviceId, timestamp: timestamp);
    _txStreamCtrl.add(data);
  }

  /// Stream firing events whenever a midi package is received
  ///
  /// The event contains the raw bytes contained in the MIDI package
  Stream<MidiPacket>? get onMidiDataReceived {
    return _platform.onMidiDataReceived;
  }

  /// Stream firing events whenever a change in the MIDI setup occurs
  ///
  /// For example, when a new BLE devices is discovered
  Stream<String>? get onMidiSetupChanged {
    return _platform.onMidiSetupChanged;
  }

  /// Stream firing events whenever a midi package is sent
  ///
  /// The event contains the raw bytes contained in the MIDI package
  Stream<Uint8List> get onMidiDataSent {
    return _txStreamCtrl.stream;
  }
}
