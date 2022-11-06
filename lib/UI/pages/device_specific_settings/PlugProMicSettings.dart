// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/communication/plugProCommunication.dart';

class PlugProMicSettings extends StatefulWidget {
  const PlugProMicSettings({Key? key}) : super(key: key);

  @override
  State createState() => _PlugProMicSettingsState();
}

class _PlugProMicSettingsState extends State<PlugProMicSettings> {
  final device = NuxDeviceControl.instance().device as NuxMightyPlugPro;
  final communication =
      NuxDeviceControl.instance().device.communication as PlugProCommunication;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Microphone Settings"),
      ),
      body: ListTileTheme(
        minLeadingWidth: 0,
        iconColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SwitchListTile(
                  title: const Text("Mute"),
                  onChanged: (value) {
                    device.config.micMute = value;
                    communication.setMicMute(device.config.micMute);
                    setState(() {});
                  },
                  value: device.config.micMute),
              ListTile(
                title: const Text("Mic Level"),
                subtitle: Slider(
                  min: 0,
                  max: 100,
                  label:
                      "${((device.config.micVolume - 50) / 50 * 12).toStringAsFixed(1)} db",
                  divisions: 100,
                  value: device.config.micVolume.toDouble(),
                  onChanged: (val) {
                    device.config.micVolume = val.round();
                    communication.setMicLevel(device.config.micVolume);
                    setState(() {});
                  },
                ),
              ),
              SwitchListTile(
                  title: const Text("Noise Gate"),
                  onChanged: (value) {
                    device.config.micNoiseGate = value;
                    communication.setMicNoiseGate(value);
                    setState(() {});
                  },
                  value: device.config.micNoiseGate),
              ListTile(
                enabled: device.config.micNoiseGate,
                title: const Text("Gate Sensitivity"),
                subtitle: Slider(
                  min: 0,
                  max: 100,
                  label: device.config.micNGSensitivity.toString(),
                  divisions: 100,
                  value: device.config.micNGSensitivity.toDouble(),
                  onChanged: device.config.micNoiseGate == false
                      ? null
                      : (val) {
                          device.config.micNGSensitivity = val.round();
                          communication.setMicNoiseGateSens(
                              device.config.micNGSensitivity);
                          setState(() {});
                        },
                ),
              ),
              ListTile(
                enabled: device.config.micNoiseGate,
                title: const Text("Gate Decay"),
                subtitle: Slider(
                  min: 0,
                  max: 100,
                  label: device.config.micNGDecay.toString(),
                  divisions: 100,
                  value: device.config.micNGDecay.toDouble(),
                  onChanged: device.config.micNoiseGate == false
                      ? null
                      : (val) {
                          device.config.micNGDecay = val.round();
                          communication
                              .setMicNoiseGateDecay(device.config.micNGDecay);
                          setState(() {});
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
