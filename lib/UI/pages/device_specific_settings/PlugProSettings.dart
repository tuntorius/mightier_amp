import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';

import '../../../bluetooth/bleMidiHandler.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../popups/alertDialogs.dart';
import 'PlugProUsbSettings.dart';

class PlugProSettings extends StatefulWidget {
  final NuxDevice device;
  const PlugProSettings({Key? key, required this.device}) : super(key: key);

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
          title: const Text("USB Audio Settings"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            //if (midiHandler.connectedDevice != null) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PlugProUsbSettings()));
            //}
          },
        ),
        ListTile(
          enabled: widget.device.deviceControl.isConnected,
          title: const Text("Bluetooth Audio EQ"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {},
        ),
        ListTile(
          enabled: widget.device.deviceControl.isConnected,
          title: const Text("Microphone Settings"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {},
        ),
        ListTile(
          enabled: widget.device.deviceControl.isConnected,
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
