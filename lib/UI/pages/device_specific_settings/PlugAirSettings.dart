import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugAir.dart';

import '../../../bluetooth/bleMidiHandler.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../popups/alertDialogs.dart';
import 'PlugAirUsbSettings.dart';

const _eqOptions = [
  "Normal",
  "Acoustic",
  "Blues",
  "Clean Bass",
  "Guitar Cut",
  "Metal",
  "Pop",
  "Rock",
  "Solo Cut"
];

class PlugAirSettings extends StatefulWidget {
  final NuxDevice device;
  const PlugAirSettings({Key? key, required this.device}) : super(key: key);

  @override
  State<PlugAirSettings> createState() => _PlugAirSettingsState();

  NuxMightyPlug get plugAirDevice => device as NuxMightyPlug;
}

class _PlugAirSettingsState extends State<PlugAirSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          enabled: widget.device.deviceControl.isConnected,
          title: const Text("USB Audio Settings"),
          leading: const Icon(Icons.volume_up),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PlugAirUsbSettings()));
          },
        ),
        ListTile(
          enabled: widget.device.deviceControl.isConnected,
          title: const Text("Bluetooth Audio EQ"),
          subtitle: Text(_eqOptions[widget.plugAirDevice.btEq]),
          leading: const Icon(Icons.bluetooth_audio),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            var oldValue = widget.plugAirDevice.btEq;
            var dialog = AlertDialogs.showOptionDialog(context,
                confirmButton: "OK",
                cancelButton: "Cancel",
                title: "Bluetooth Audio EQ",
                confirmColor: Theme.of(context).hintColor,
                value: widget.plugAirDevice.btEq,
                options: _eqOptions, onConfirm: (changed, newValue) {
              setState(() {
                if (changed) {
                  widget.plugAirDevice.setBtEq(newValue);
                } else {
                  widget.plugAirDevice.setBtEq(oldValue);
                }
              });
            }, onSelectionChanged: (selected) {
              widget.plugAirDevice.setBtEq(selected);
            });
            showDialog(
              context: context,
              builder: (BuildContext context) => dialog,
            );
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
        SwitchListTile(
            secondary: const Icon(Icons.eco),
            title: const Text("Eco Mode"),
            value: widget.device.ecoMode,
            onChanged: widget.device.deviceControl.isConnected
                ? (val) {
                    setState(
                      () {
                        widget.device.setEcoMode(val);
                      },
                    );
                  }
                : null),
      ],
    );
  }
}
