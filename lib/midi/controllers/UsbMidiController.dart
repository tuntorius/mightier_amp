import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

class UsbMidiController extends MidiController {
  MidiDevice device;
  @override
  ControllerType get type => ControllerType.MidiUsb;
  UsbMidiController(this.device, super.onHotkeyReceived);

  @override
  String get id => device.id;

  String? _name;

  @override
  String get name {
    if (_name == null) {
      //custom fix for https://github.com/tuntorius/mightier_amp/issues/81
      _name = device.name;
      if (_name!.startsWith("Arduino LLC Arduino Leonardo") &&
          _name!.endsWith("MIDI 1.0")) _name = "Arduino Leonardo MIDI 1.0";
    }
    return device.name;
  }

  @override
  bool get connected => device.connected;

  @override
  Future<bool> connect() async {
    MidiCommand().connectToDevice(device);
    //wait for up to 2 seconds
    for (int i = 0; i < 4; i++) {
      var devs = await MidiCommand().devices;
      if (devs != null) {
        for (var d in devs) {
          if (d.name == name && d.id == id && d.connected) device = d;
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (device.connected) {
        onStatus?.call(this, ControllerStatus.Connected);
        return true;
      }
    }

    return device.connected;
  }

  void checkForDisconnection() async {
    bool found = false;
    var devs = await MidiCommand().devices;
    if (devs != null) {
      for (var d in devs) {
        if (d.name == name && d.id == id) {
          device = d;
          found = true;
        }
      }
    }
    //a shitty hack to work around missing functionality
    if (found == false) device.connected = false;
    if (!device.connected) onStatus?.call(this, ControllerStatus.Disconnected);
  }

  void onDataReceivedLoopback(List<int> data) {
    if (data[0] != 248 && data[0] != 254) onDataReceived?.call(this, data);
  }
}
