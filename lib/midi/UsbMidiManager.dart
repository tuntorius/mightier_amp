import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mighty_plug_manager/midi/MidiControllerManager.dart';
import 'package:mighty_plug_manager/midi/controllers/UsbMidiController.dart';

import 'controllers/MidiController.dart';

class UsbMidiManager {
  static final UsbMidiManager _controller = UsbMidiManager._();
  List<MidiDevice> _devices = [];

  final List<UsbMidiController> _controllers = [];

  bool usbMidiSupported = false;

  factory UsbMidiManager() {
    return _controller;
  }

  UsbMidiManager._() {
    _init();
  }

  _init() async {
    if (Platform.isAndroid) {
      var deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      usbMidiSupported = (androidInfo.version.sdkInt ?? 0) >= 23;
    } else if (Platform.isIOS) {
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
      var udev = UsbMidiController(dev);
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
    }
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
