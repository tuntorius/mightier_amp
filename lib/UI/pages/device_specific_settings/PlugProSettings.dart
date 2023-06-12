import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/device_specific_settings/eq/MightySpaceSpeakerEQ.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightySpace.dart';

import '../../../bluetooth/bleMidiHandler.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../popups/alertDialogs.dart';
import 'PlugProMicSettings.dart';
import 'PlugProUsbSettings.dart';
import 'eq/PlugProEQSettings.dart';

class PlugProSettings extends StatefulWidget {
  final NuxDevice device;
  final bool mightySpace;
  const PlugProSettings(
      {Key? key, required this.device, required this.mightySpace})
      : super(key: key);

  @override
  State<PlugProSettings> createState() => _PlugProSettingsState();

  NuxMightyPlugPro get plugProDevice => device as NuxMightyPlugPro;
}

class _PlugProSettingsState extends State<PlugProSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          enabled: widget.device.deviceControl.isConnected,
          leading: const Icon(Icons.volume_up),
          title: const Text("USB Audio Settings"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PlugProUsbSettings()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.bluetooth_audio),
          enabled: widget.device.deviceControl.isConnected,
          title: const Text("Bluetooth Audio EQ"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PlugProEQSettings()));
          },
        ),
        if (!widget.device.deviceControl.isConnected ||
            (widget.mightySpace &&
                (widget.device as NuxMightySpace).speakerAvailable))
          ListTile(
            leading: const Icon(Icons.speaker),
            enabled: widget.device.deviceControl.isConnected,
            title: const Text("Speaker EQ"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SpaceSpeakerEQSettings()));
            },
          ),
        if (!widget.mightySpace)
          ListTile(
            enabled: widget.device.deviceControl.isConnected,
            leading: const Icon(Icons.mic),
            title: const Text("Microphone Settings"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PlugProMicSettings()));
            },
          ),
        ListTile(
          enabled: widget.device.deviceControl.isConnected,
          leading: const Icon(Icons.restart_alt),
          title: const Text("Reset Device Presets"),
          onTap: () {
            if (BLEMidiHandler.instance().connectedDevice != null) {
              AlertDialogs.showConfirmDialog(context,
                  title: "Reset device presets",
                  cancelButton: "Cancel",
                  confirmButton: "Reset",
                  confirmColor: Colors.red,
                  description: "Are you sure?", onConfirm: (val) {
                if (val) widget.device.resetNuxPresets();
              });
            }
          },
        ),
      ],
    );
  }
}
