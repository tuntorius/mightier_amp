// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/thickSlider.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/features/proUsbSettings.dart';
import '../../widgets/common/modeControlRegular.dart';

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
  final config =
      NuxDeviceControl.instance().device.config as NuxPlugProConfiguration;
  final usbSettings = NuxDeviceControl.instance().device as ProUsbSettings;
  static const fontSize = TextStyle(fontSize: 20);

  @override
  void didChangeDependencies() {
    // Adjust the provider based on the image type
    for (var route in PlugProUsbSettings.routes) {
      precacheImage(AssetImage(route.schemeAsset), context);
    }
    super.didChangeDependencies();
  }

  void _setUsbDryWetValue(double value, bool skip) {
    if (skip) {
      config.usbDryWet = value.round();
    } else {
      usbSettings.setUsbDryWetVol(value.round());
    }
    setState(() {});
  }

  void _setUsbRecordingValue(double value, bool skip) {
    if (skip) {
      config.recLevel = value.round();
    } else {
      usbSettings.setUsbRecordingVol(value.round());
    }
    setState(() {});
  }

  void _setUsbPlaybackValue(double value, bool skip) {
    if (skip) {
      config.playbackLevel = value.round();
    } else {
      usbSettings.setUsbPlaybackVol(value.round());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const routes = PlugProUsbSettings.routes;
    var routeModeInt = config.routingMode & modeMask;
    var routeMode = routes.firstWhere((r) => r.value == routeModeInt);
    var modeIndex = routes.indexOf(routeMode);
    var loopback = config.routingMode & loopbackMask != 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("USB Audio Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Route Mode",
                  style: fontSize,
                ),
              ),
              ModeControlRegular(
                selected: modeIndex,
                options: routes.map((e) => e.name).toList(),
                onSelected: (index) {
                  var mode = routes[index];
                  var value = mode.value;
                  if (mode.loopback && loopback) value |= loopbackMask;
                  usbSettings.setUsbMode(value);
                  setState(() {});
                },
                textStyle: fontSize,
              ),
              const SizedBox(
                height: 8,
              ),
              SwitchListTile(
                  title: const Text(
                    "Loopback",
                    style: fontSize,
                  ),
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
                          usbSettings.setUsbMode(routeModeInt);
                          setState(() {});
                        }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset(routeMode.schemeAsset),
              ),
              ThickSlider(
                enabled: routeMode.dryWet,
                activeColor: Colors.blue,
                label: "Dry/Wet",
                value: config.usbDryWet.toDouble(),
                min: 0,
                max: 100,
                labelFormatter: (val) {
                  return "${config.usbDryWet}%";
                },
                handleVerticalDrag: true,
                onChanged: _setUsbDryWetValue,
                onDragEnd: (value) => _setUsbDryWetValue(value, false),
              ),
              ThickSlider(
                activeColor: Colors.blue,
                label: "Recording Level",
                value: config.recLevel.toDouble(),
                min: 0,
                max: 100,
                labelFormatter: (val) {
                  return "${((val - 50) / 50 * 12).toStringAsFixed(2)} db";
                },
                handleVerticalDrag: true,
                onChanged: _setUsbRecordingValue,
                onDragEnd: (value) => _setUsbRecordingValue(value, false),
              ),
              ThickSlider(
                activeColor: Colors.blue,
                label: "Playback Level",
                value: config.playbackLevel.toDouble(),
                min: 0,
                max: 100,
                labelFormatter: (val) {
                  return "${((val - 50) / 50 * 12).toStringAsFixed(2)} db";
                },
                handleVerticalDrag: true,
                onChanged: _setUsbPlaybackValue,
                onDragEnd: (value) => _setUsbPlaybackValue(value, false),
              )
            ],
          ),
        ),
      ),
    );
  }
}
