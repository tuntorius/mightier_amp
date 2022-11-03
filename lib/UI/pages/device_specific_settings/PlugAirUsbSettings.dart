// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugAir.dart';
import '../../../bluetooth/NuxDeviceControl.dart';

class PlugAirUsbSettings extends StatefulWidget {
  const PlugAirUsbSettings({Key? key}) : super(key: key);

  @override
  State createState() => _PlugAirUsbSettingsState();
}

class _PlugAirUsbSettingsState extends State<PlugAirUsbSettings> {
  final usbModes = ["Reamp", "Normal", "Dry Out"];
  final device = NuxDeviceControl.instance().device as NuxMightyPlug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("USB Audio Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTileTheme(
          iconColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                title: const Text("Routing"),
                subtitle: Text(usbModes[device.usbMode]),
                onTap: () {
                  var dialog = AlertDialogs.showOptionDialog(context,
                      confirmButton: "OK",
                      cancelButton: "Cancel",
                      title: "Select Routing Mode",
                      value: device.usbMode,
                      confirmColor: Colors.blue,
                      options: usbModes, onConfirm: (changed, newValue) {
                    if (changed) {
                      setState(() {
                        device.setUsbMode(newValue);
                      });
                    }
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => dialog,
                  );
                },
              ),
              ListTile(
                title: const Text("Input Volume"),
                subtitle: Slider(
                  min: 0,
                  max: 100,
                  label: "${device.inputVol}",
                  divisions: 100,
                  value: device.inputVol.toDouble(),
                  onChanged: (val) {
                    setState(() {
                      device.setUsbInputVol(val.round());
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("Output Volume"),
                subtitle: Slider(
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: "${device.outputVol}",
                  value: device.outputVol.toDouble(),
                  onChanged: (val) {
                    setState(() {
                      device.setUsbOutputVol(val.round());
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
