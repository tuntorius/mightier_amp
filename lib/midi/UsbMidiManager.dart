import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mighty_plug_manager/midi/MidiControllerManager.dart';
import 'package:mighty_plug_manager/midi/controllers/UsbMidiController.dart';

import '../platform/platformUtils.dart';
import 'ControllerConstants.dart';
import 'controllers/MidiController.dart';

class UsbMidiManager {
  List<MidiDevice> _devices = [];
  final Function(HotkeyControl) onHotkeyReceived;
  final Function() onMidiDeviceFound;

  final List<UsbMidiController> _controllers = [];

  bool usbMidiSupported = false;

  UsbMidiManager(this.onHotkeyReceived, this.onMidiDeviceFound) {
    _init();
  }

  _init() async {
    if (PlatformUtils.isAndroid) {
      var deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      usbMidiSupported = (androidInfo.version.sdkInt) >= 23;
    } else if (PlatformUtils.isIOS) {
      //TODO: Check if all ios versions support midi
      usbMidiSupported = true;
    }
    if (usbMidiSupported) {
      MidiCommand().onMidiDataReceived!.listen(_onDataReceive);
      MidiCommand().onMidiSetupChanged!.listen(_onMidiSetupChanged);
    }
  }

  Future<List<MidiController>> getDevices() async {
    if (!usbMidiSupported) return [];
    _devices = await MidiCommand().devices ?? [];

    _controllers.clear();
    for (var dev in _devices) {
      var udev = UsbMidiController(dev, onHotkeyReceived);
      _controllers.add(udev);
    }
    return _controllers;
  }

  // connectToDevice(MidiDevice device) {
  //   MidiCommand().connectToDevice(device);
  // }

  _onMidiSetupChanged(String data) {
    //deviceFound - when plugged in - might be used for scanning
    //deviceLost - for disconnect
    //deviceOpened - for connect
    //onDeviceStatusChanged - for connect probably
    var ctls = MidiControllerManager().controllers;

    if (data == "deviceLost") {
      for (var ctl in ctls) {
        if (ctl is UsbMidiController) ctl.checkForDisconnection();
      }
    } else if (data == "deviceFound") {
      onMidiDeviceFound();
    } else if (data == "deviceOpened") {}
    debugPrint("OnMidiSetupChanged: $data");
  }

  _onDataReceive(MidiPacket event) {
    //find which device this belongs to
    var ctls = MidiControllerManager().controllers;
    for (var ctl in ctls) {
      if (ctl.name == event.device.name && ctl.id == event.device.id) {
        (ctl as UsbMidiController).onDataReceivedLoopback(event.data);
      }
    }
  }
}
