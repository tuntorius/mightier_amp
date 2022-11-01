// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import '../../../bluetooth/NuxDeviceControl.dart';

class PlugProUsbSettings extends StatefulWidget {
  @override
  _PlugProUsbSettingsState createState() => _PlugProUsbSettingsState();
}

class _PlugProUsbSettingsState extends State<PlugProUsbSettings> {
  final usbModes = ["Reamp", "Normal", "Dry Out"];
  final device = NuxDeviceControl.instance().device as NuxMightyPlugPro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("USB Audio Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTileTheme(
          iconColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                title: Text("Routing"),
                subtitle: Text(usbModes[device.config.routingMode]),
                onTap: () {
                  var dialog = AlertDialogs.showOptionDialog(context,
                      confirmButton: "OK",
                      cancelButton: "Cancel",
                      title: "Select Routing Mode",
                      value: device.config.routingMode,
                      confirmColor: Colors.blue,
                      options: usbModes, onConfirm: (changed, newValue) {
                    if (changed) {
                      setState(() {
                        //device.setUsbMode(newValue);
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
                title: Text("Playback Level"),
                subtitle: Slider(
                  min: 0,
                  max: 100,
                  label: "${device.config.playbackLevel}",
                  divisions: 100,
                  value: device.config.playbackLevel.toDouble(),
                  onChanged: (val) {
                    setState(() {
                      //device.setUsbInputVol(val.round());
                    });
                  },
                ),
              ),
              ListTile(
                title: Text("Recording Level"),
                subtitle: Slider(
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: "${device.config.recLevel}",
                  value: device.config.recLevel.toDouble(),
                  onChanged: (val) {
                    setState(() {
                      //device.setUsbOutputVol(val.round());
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
