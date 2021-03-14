// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/UsbSettings.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../platform/simpleSharedPrefs.dart';
import 'package:screen/screen.dart';
import '../../bluetooth/bleMidiHandler.dart';
import '../widgets/deviceList.dart';
import 'calibration.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';

enum TimeUnit { BPM, Seconds }

class Settings extends StatefulWidget {
  static String output = "";
  static void print(String value) {
    if (output.isNotEmpty) output += "\n";
    output += value;
  }

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  BLEMidiHandler midiHandler = BLEMidiHandler();

  final eqOptions = [
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

  final timeUnit = ["BPM", "Seconds"];

  List<String> nuxDevices;

  String _version = "";

  @override
  void initState() {
    super.initState();
    NuxDeviceControl().addListener(_deviceChanged);

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _version = packageInfo.version;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl().removeListener(_deviceChanged);
  }

  void _deviceChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final NuxDevice device = NuxDeviceControl().device;
    List<String> items =
        Settings.output != null ? Settings.output.split('\n') : <String>[];
    return ListView(
      children: [
        if (kDebugMode)
          Container(
            height: 150,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Text(items[index]);
              },
              itemCount: items.length,
            ),
          ),
        ListTileTheme(
          iconColor: Colors.white,
          child: Column(
            children: [
              SwitchListTile(
                title: Text("Keep Screen On"),
                value:
                    SharedPrefs().getValue(SettingsKeys.screenAlwaysOn, false),
                onChanged: (val) {
                  setState(() {
                    Screen.keepOn(val);
                    SharedPrefs().setValue(SettingsKeys.screenAlwaysOn, val);
                  });
                },
              ),
              ListTile(
                title: Text("Delay Time Unit"),
                subtitle: Text(timeUnit[SharedPrefs()
                    .getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index)]),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  var dialog = AlertDialogs.showOptionDialog(context,
                      confirmButton: "OK",
                      cancelButton: "Cancel",
                      title: "Delay Time Unit",
                      value: SharedPrefs()
                          .getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index),
                      options: timeUnit, onConfirm: (changed, newValue) {
                    if (changed) {
                      setState(() {
                        SharedPrefs().setValue(SettingsKeys.timeUnit, newValue);
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
                enabled: !device.deviceControl.isConnected,
                title: Text("Device"),
                subtitle: Text(device.productName),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  var dialog = AlertDialogs.showOptionDialog(context,
                      confirmButton: "OK",
                      cancelButton: "Cancel",
                      title: "Select Device",
                      value: NuxDeviceControl().deviceIndex,
                      options: NuxDeviceControl().deviceNameList,
                      onConfirm: (changed, newValue) {
                    if (changed) {
                      NuxDeviceControl().deviceIndex = newValue;
                      setState(() {});
                    }
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => dialog,
                  );
                },
              ),
              Divider(),
              ListTile(
                enabled: device.deviceControl.isConnected,
                title: Text("USB Audio Settings"),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  //if (midiHandler.connectedDevice != null) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => UsbSettings()));
                  //}
                },
              ),
              //Divider(),
              ListTile(
                enabled: device.deviceControl.isConnected,
                title: Text("Bluetooth Audio EQ"),
                subtitle: Text(eqOptions[device.btEq]),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  var dialog = AlertDialogs.showOptionDialog(context,
                      confirmButton: "OK",
                      cancelButton: "Cancel",
                      title: "Bluetooth Audio EQ",
                      value: device.btEq,
                      options: eqOptions, onConfirm: (changed, newValue) {
                    if (changed) {
                      setState(() {
                        device.setBtEq(newValue);
                      });
                    }
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => dialog,
                  );
                },
              ),
              //Divider(),
              ListTile(
                enabled: device.deviceControl.isConnected,
                title: Text("Reset Device Presets"),
                onTap: () {
                  if (midiHandler.connectedDevice != null) {
                    AlertDialogs.showConfirmDialog(context,
                        title: "Reset device presets",
                        cancelButton: "Cancel",
                        confirmButton: "Reset",
                        confirmColor: Colors.red,
                        description: "Are you sure?", onConfirm: (val) {
                      if (val) device.resetNuxPresets();
                    });
                  }
                },
              ),
              //Divider(),
              SwitchListTile(
                  title: Text("Eco Mode"),
                  value: device.ecoMode,
                  onChanged: device.deviceControl.isConnected
                      ? (val) {
                          setState(
                            () {
                              device.setEcoMode(val);
                            },
                          );
                        }
                      : null),
              //Divider(),
              ListTile(
                enabled: device.deviceControl.isConnected,
                title: Text("Calibrate Latency"),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Calibration()));
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            height: 150,
            child: StreamBuilder<midiSetupStatus>(
                builder: (BuildContext context, snapshot) {
                  return DeviceList();
                },
                stream: midiHandler.status),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: Text("Scan"),
              onPressed: () {
                midiHandler.startScanning(true);
              },
            ),
            ElevatedButton(
              child: Text("Stop Scanning"),
              onPressed: () {
                midiHandler.stopScanning();
              },
            ),
            ElevatedButton(
              child: Text("Disconnect"),
              onPressed: () {
                midiHandler.disconnectDevice();
                setState(() {});
              },
            ),
          ],
        ),
        Divider(),
        ListTile(title: Text("App Version"), trailing: Text(_version))
      ],
    );
  }
}
