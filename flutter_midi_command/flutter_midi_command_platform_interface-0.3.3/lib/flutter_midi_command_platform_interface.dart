import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_midi_command_platform_interface/midi_device.dart';
import 'package:flutter_midi_command_platform_interface/midi_packet.dart';
import 'package:flutter_midi_command_platform_interface/midi_port.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'method_channel_midi_command.dart';

export 'package:flutter_midi_command_platform_interface/midi_device.dart';
export 'package:flutter_midi_command_platform_interface/midi_packet.dart';
export 'package:flutter_midi_command_platform_interface/midi_port.dart';

abstract class MidiCommandPlatform extends PlatformInterface {
  /// Constructs a MidiCommandPlatform.
  MidiCommandPlatform() : super(token: _token);

  static final Object _token = Object();

  static MidiCommandPlatform _instance = MethodChannelMidiCommand();

  /// The default instance of [MidiCommandPlatform] to use.
  ///
  /// Defaults to [MethodChannelMidiCommand].
  static MidiCommandPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MidiCommandPlatform] when they register themselves.
  static set instance(MidiCommandPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns a list of found MIDI devices.
  Future<List<MidiDevice>?> get devices async {
    throw UnimplementedError('get devices has not been implemented.');
  }

  /// Starts scanning for BLE MIDI devices.
  ///
  /// Found devices will be included in the list returned by [devices].
  Future<void> startScanningForBluetoothDevices() async {
    throw UnimplementedError('startScanningForBluetoothDevices() has not been implemented.');
  }

  /// Stops scanning for BLE MIDI devices.
  void stopScanningForBluetoothDevices() {
    throw UnimplementedError('stopScanningForBluetoothDevices() has not been implemented.');
  }

  /// Connects to the device.
  void connectToDevice(MidiDevice device, {List<MidiPort>? ports}) {
    throw UnimplementedError('connectToDevice() has not been implemented.');
  }

  /// Disconnects from the device.
  void disconnectDevice(MidiDevice device) {
    throw UnimplementedError('disconnectDevice() has not been implemented.');
  }

  /// Disconnects from all devices.
  void teardown() {
    throw UnimplementedError('teardown() has not been implemented.');
  }

  /// Sends data to the currently connected device.
  ///
  /// Data is an UInt8List of individual MIDI command bytes.
  void sendData(Uint8List data, {int? timestamp, String? deviceId}) {
    throw UnimplementedError('sendData() has not been implemented.');
  }

  Stream<MidiPacket>? get onMidiDataReceived {
    throw UnimplementedError('get onMidiDataReceived has not been implemented.');
  }

  /// Stream firing events whenever a change in the MIDI setup occurs.
  ///
  /// For example, when a new BLE devices is discovered.
  Stream<String>? get onMidiSetupChanged {
    throw UnimplementedError('get onMidiSetupChanged has not been implemented.');
  }
}
