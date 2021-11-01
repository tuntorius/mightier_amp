# flutter_midi_command

A Flutter plugin for sending and receiving MIDI messages between Flutter and physical and virtual MIDI devices. 

Wraps CoreMIDI/android.media.midi/ALSA in a thin dart/flutter layer.
Supports
- USB and BLE MIDI connections on Android
- USB, network(session) and BLE MIDI connections on iOS and macOS.
- ALSA Midi on Linux

## To install

- Make sure your project is created with Kotlin and Swift support.
- Add flutter_midi_command: ^0.3.0 to your pubspec.yaml file.
- In ios/Podfile uncomment and change the platform to 10.0 `platform :ios, '10.0'`
- After building, Add a NSBluetoothAlwaysUsageDescription to info.plist in the generated Xcode project.
- On Linux, make sure ALSA is installed.


## Getting Started

This plugin is build using Swift and Kotlin on the native side, so make sure your project supports this.

Import flutter_midi_command

`import 'package:flutter_midi_command/flutter_midi_command.dart';`

- Get a list of available MIDI devices by calling `MidiCommand().devices` which returns a list of `MidiDevice`
- Start scanning for BLE MIDI devices by calling `MidiCommand().startScanningForBluetoothDevices()`
- Connect to a specific `MidiDevice` by calling `MidiCommand.connectToDevice(selectedDevice)`
- Stop scanning for BLE MIDI devices by calling `MidiCommand().stopScanningForBluetoothDevices()`
- Disconnect from the current device by calling `MidiCommand.disconnectDevice()`
- Listen for updates in the MIDI setup by subscribing to `MidiCommand().onMidiSetupChanged`
- Listen for incoming MIDI messages on from the current device by subscribing to `MidiCommand().onMidiDataReceived`, after which the listener will recieve inbound MIDI messages as an UInt8List of variable length.
- Send a MIDI message by calling `MidiCommand.sendData(data)`, where data is an UInt8List of bytes following the MIDI spec.
- Or use the various `MidiCommand` subtypes to send PC, CC, NoteOn and NoteOff messages.

See example folder for how to use.

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).
