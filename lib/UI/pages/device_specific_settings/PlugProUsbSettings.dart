// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import '../../../bluetooth/NuxDeviceControl.dart';

class RouteModel {
  final String name;
  final int value;
  final String schemeAsset;
  final bool loopback;
  final bool dryWet;
  const RouteModel(
      {required this.name,
      required this.value,
      required this.schemeAsset,
      required this.loopback,
      required this.dryWet});
}

class PlugProUsbSettings extends StatefulWidget {
  static const List<RouteModel> routes = [
    RouteModel(
        name: "Normal",
        value: 1,
        schemeAsset: "assets/images/route_normal.png",
        loopback: true,
        dryWet: true),
    RouteModel(
        name: "Reamp",
        value: 2,
        schemeAsset: "assets/images/route_reamp.png",
        loopback: false,
        dryWet: false),
    RouteModel(
        name: "Dry Out",
        value: 0,
        schemeAsset: "assets/images/route_dryout.png",
        loopback: false,
        dryWet: false),
  ];

  const PlugProUsbSettings({Key? key}) : super(key: key);

  @override
  State createState() => _PlugProUsbSettingsState();
}

class _PlugProUsbSettingsState extends State<PlugProUsbSettings> {
  final loopbackMask = 0x10;
  final modeMask = 0x07;
  final device = NuxDeviceControl.instance().device as NuxMightyPlugPro;

  @override
  void didChangeDependencies() {
    // Adjust the provider based on the image type
    for (var route in PlugProUsbSettings.routes) {
      precacheImage(AssetImage(route.schemeAsset), context);
    }
    super.didChangeDependencies();
  }

  Widget _modeButton(String mode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    const routes = PlugProUsbSettings.routes;
    var routeModeInt = device.config.routingMode & modeMask;
    var routeMode = routes.firstWhere((r) => r.value == routeModeInt);
    var arrayIndex = routes.indexOf(routeMode);
    var loopback = device.config.routingMode & loopbackMask != 0;

    var selected = List<bool>.filled(routes.length, false);
    selected[arrayIndex] = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text("USB Audio Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTileTheme(
            iconColor: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Route Mode"),
                ),
                ToggleButtons(
                  fillColor: Colors.blue,
                  selectedBorderColor: Colors.blue,
                  color: Colors.grey,
                  isSelected: selected,
                  onPressed: (index) {
                    var mode = routes[index];
                    var value = mode.value;
                    if (mode.loopback && loopback) value |= loopbackMask;
                    device.setUsbMode(value);
                    setState(() {});
                  },
                  children: [
                    for (var i = 0; i < routes.length; i++)
                      _modeButton(routes[i].name)
                  ],
                ),
                SwitchListTile(
                    title: const Text("Loopback"),
                    subtitle: const Text(
                        "Redirect Bluetooth and microphone audio to USB input"),
                    value: loopback,
                    onChanged: !routeMode.loopback
                        ? null
                        : (value) {
                            if (value) {
                              routeModeInt |= loopbackMask;
                            } else {
                              routeModeInt &= modeMask;
                            }
                            device.setUsbMode(routeModeInt);
                            setState(() {});
                          }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.asset(routeMode.schemeAsset),
                ),
                ListTile(
                  title: const Text("Dry/Wet"),
                  subtitle: Slider(
                    min: 0,
                    max: 100,
                    label: "${device.config.usbDryWet}",
                    divisions: 100,
                    value: device.config.usbDryWet.toDouble(),
                    onChanged: !routeMode.dryWet
                        ? null
                        : (val) {
                            device.setUsbDryWetVol(val.round());
                            setState(() {});
                          },
                  ),
                ),
                ListTile(
                  title: const Text("Recording Level"),
                  subtitle: Slider(
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: "${device.config.recLevel}",
                    value: device.config.recLevel.toDouble(),
                    onChanged: (val) {
                      setState(() {
                        device.setUsbRecordingVol(val.round());
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text("Playback Level"),
                  subtitle: Slider(
                    min: 0,
                    max: 100,
                    label: "${device.config.playbackLevel}",
                    divisions: 100,
                    value: device.config.playbackLevel.toDouble(),
                    onChanged: (val) {
                      setState(() {
                        device.setUsbPlaybackVol(val.round());
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
