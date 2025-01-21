import 'package:flutter/material.dart';

import '../../../bluetooth/bleMidiHandler.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../popups/alertDialogs.dart';
import 'PlugProUsbSettings.dart';

class LiteMk2Settings extends StatefulWidget {
  final NuxDevice device;
  const LiteMk2Settings({Key? key, required this.device}) : super(key: key);

  @override
  State<LiteMk2Settings> createState() => _LiteMk2SettingsState();
}

class _LiteMk2SettingsState extends State<LiteMk2Settings> {
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
        /*ListTile(
          leading: const Icon(Icons.bluetooth_audio),
          enabled: widget.device.deviceControl.isConnected,
          title: const Text("Bluetooth Audio EQ"),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PlugProEQSettings()));
          },
        ),*/
        /*
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
        */
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
        const Divider()
      ],
    );
  }
}
