import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

class UsbMidiController extends MidiController {
  MidiDevice device;
  ControllerType get type => ControllerType.MidiUsb;
  UsbMidiController(this.device);

  @override
  String get id => device.id;

  @override
  String get name => device.name;

  @override
  bool get connected => device.connected;

  @override
  Future<bool> connect() async {
    MidiCommand().connectToDevice(device);
    //wait for up to 2 seconds
    for (int i = 0; i < 4; i++) {
      var devs = await MidiCommand().devices;
      if (devs != null) {
        for (var d in devs)
          if (d.name == name && d.id == id && d.connected) device = d;
      }
      await Future.delayed(Duration(milliseconds: 500));
      if (device.connected) return true;
    }

    return device.connected;
  }

  void checkForDisconnection() async {
    bool found = false;
    var devs = await MidiCommand().devices;
    if (devs != null) {
      for (var d in devs)
        if (d.name == name && d.id == id) {
          device = d;
          found = true;
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
