// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/thickSlider.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugAir.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import '../../../bluetooth/NuxDeviceControl.dart';

class RouteModel {
  final String name;
  final int value;
  final String schemeAsset;
  const RouteModel(
      {required this.name, required this.value, required this.schemeAsset});
}

class PlugAirUsbSettings extends StatefulWidget {
  static const List<RouteModel> routes = [
    RouteModel(
        name: "Normal",
        value: 1,
        schemeAsset: "assets/images/route_normal_mp2.png"),
    RouteModel(
        name: "Reamp", value: 0, schemeAsset: "assets/images/route_reamp.png"),
    RouteModel(
        name: "Dry Out",
        value: 2,
        schemeAsset: "assets/images/route_dryout.png"),
  ];

  const PlugAirUsbSettings({Key? key}) : super(key: key);

  @override
  State createState() => _PlugAirUsbSettingsState();
}

class _PlugAirUsbSettingsState extends State<PlugAirUsbSettings> {
  final device = NuxDeviceControl.instance().device as NuxMightyPlug;
  static const fontSize = TextStyle(fontSize: 20);

  @override
  void didChangeDependencies() {
    // Adjust the provider based on the image type
    for (var route in PlugAirUsbSettings.routes) {
      precacheImage(AssetImage(route.schemeAsset), context);
    }
    super.didChangeDependencies();
  }

  Widget _modeButton(String mode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(mode, style: fontSize),
    );
  }

  void _setUsbInputValue(double value, bool skip) {
    if (skip) {
      device.config.inputVol = value.round();
    } else {
      device.setUsbInputVol(value.round());
    }
    setState(() {});
  }

  void _setUsbOutputValue(double value, bool skip) {
    if (skip) {
      device.config.outputVol = value.round();
    } else {
      device.setUsbOutputVol(value.round());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const routes = PlugAirUsbSettings.routes;
    var routeMode = routes.firstWhere((r) => r.value == device.config.usbMode);
    var arrayIndex = routes.indexOf(routeMode);

    var selected = List<bool>.filled(routes.length, false);
    selected[arrayIndex] = true;

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
              ToggleButtons(
                fillColor: Colors.blue,
                selectedBorderColor: Colors.blue,
                color: Colors.grey,
                isSelected: selected,
                onPressed: (index) {
                  var mode = routes[index];
                  var value = mode.value;
                  device.setUsbMode(value);
                  setState(() {});
                },
                children: [
                  for (var i = 0; i < routes.length; i++)
                    _modeButton(routes[i].name)
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset(routeMode.schemeAsset),
              ),
              ThickSlider(
                activeColor: Colors.blue,
                label: "Input Level",
                value: device.config.inputVol.toDouble(),
                min: 0,
                max: 100,
                labelFormatter: (val) {
                  return "${val.round()}%";
                },
                handleVerticalDrag: true,
                onChanged: _setUsbInputValue,
                onDragEnd: (value) => _setUsbInputValue(value, false),
              ),
              ThickSlider(
                activeColor: Colors.blue,
                label: "Output Level",
                value: device.config.outputVol.toDouble(),
                min: 0,
                max: 100,
                labelFormatter: (val) {
                  return "${val.round()}%";
                },
                handleVerticalDrag: true,
                onChanged: _setUsbOutputValue,
                onDragEnd: (value) => _setUsbOutputValue(value, false),
              )
            ],
          ),
        ),
      ),
    );
  }
}
