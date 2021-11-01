import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

class MidiControllerTile extends StatelessWidget {
  final MidiController controller;
  final Function() onTap;
  final Function() onSettings;
  const MidiControllerTile(
      {Key? key,
      required this.controller,
      required this.onTap,
      required this.onSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (controller.type) {
      case ControllerType.Hid:
        icon = Icons.keyboard_alt_outlined;
        break;
      case ControllerType.MidiUsb:
        icon = Icons.usb;
        break;
      case ControllerType.MidiBle:
        icon = Icons.bluetooth;
        break;
    }

    return ListTile(
      title: Text(controller.name),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.connected)
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: onSettings,
            ),
          Icon(
            icon,
            color: controller.connected ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }
}
