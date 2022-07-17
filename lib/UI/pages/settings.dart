// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/UsbSettings.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../platform/simpleSharedPrefs.dart';
import 'package:wakelock/wakelock.dart';
import '../../bluetooth/bleMidiHandler.dart';
import '../widgets/deviceList.dart';
import 'DebugConsolePage.dart';
import 'calibration.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'developerPage.dart';
import 'midiControllers.dart';

enum TimeUnit { BPM, Seconds }

class Settings extends StatefulWidget {
  static bool devMode = false;
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

  String _version = "";

  int devCounter = 0;

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
    List<String> items = Settings.output.split('\n');
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
                    Wakelock.toggle(enable: val);
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
                      confirmColor: Colors.blue,
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
                      confirmColor: Colors.blue,
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
              if (device.getAvailableVersions() > 1)
                ListTile(
                  enabled: !device.deviceControl.isConnected,
                  title: Text("Firmware Version"),
                  subtitle:
                      Text(device.getProductNameVersion(device.productVersion)),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    var dialog = AlertDialogs.showOptionDialog(context,
                        confirmButton: "OK",
                        cancelButton: "Cancel",
                        title: "Select Version",
                        confirmColor: Colors.blue,
                        value: NuxDeviceControl().deviceFirmwareVersion,
                        options: NuxDeviceControl().deviceVersionsList,
                        onConfirm: (changed, newValue) {
                      if (changed) {
                        NuxDeviceControl().deviceFirmwareVersion = newValue;
                        setState(() {});
                      }
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => dialog,
                    );
                  },
                ),
              //Automatically set matching cabinet when changing an amp
              CheckboxListTile(
                  title: Text("Set matching cabinets automatically"),
                  value: SharedPrefs().getInt(SettingsKeys.changeCabs, 1) != 0,
                  onChanged: (value) {
                    setState(() {
                      if (value != null)
                        SharedPrefs()
                            .setInt(SettingsKeys.changeCabs, value ? 1 : 0);
                    });
                  }),
              Divider(),
              if (device.advancedSettingsSupport)
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
              if (device.advancedSettingsSupport)
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
                        confirmColor: Colors.blue,
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
              if (device.advancedSettingsSupport)
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
              if (device.advancedSettingsSupport)
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
                title: Text("Calibrate BT Audio Latency"),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Calibration()));
                },
              ),
              ListTile(
                title: Text("Remote Control"),
                subtitle: Text("Uses HID/MIDI device to control the amp"),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  //if (midiHandler.connectedDevice != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MidiControllers()));
                  //}
                },
              ),
            ],
          ),
        ),
        if (midiHandler.permissionGranted)
          StreamBuilder<midiSetupStatus>(
              stream: midiHandler.status,
              builder: (BuildContext context, snapshot) {
                return StreamBuilder<bool>(
                    builder: (BuildContext context, snapshot) {
                      var btOn = midiHandler.bluetoothOn;
                      if (!btOn) {
                        return ListTile(
                          title: Text("Please, turn bluetooth on!"),
                        );
                      }
                      bool scanning = midiHandler.isScanning;
                      bool connected = NuxDeviceControl().isConnected;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)),
                              height: 150,
                              child: DeviceList(),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                child: Text("Scan"),
                                onPressed: connected || scanning
                                    ? null
                                    : () {
                                        midiHandler.startScanning(true);
                                      },
                              ),
                              ElevatedButton(
                                child: Text("Stop Scanning"),
                                onPressed: connected || !scanning
                                    ? null
                                    : () {
                                        midiHandler.stopScanning();
                                      },
                              ),
                              ElevatedButton(
                                child: Text("Disconnect"),
                                onPressed: !connected
                                    ? null
                                    : () {
                                        midiHandler.disconnectDevice();
                                        setState(() {});
                                      },
                              ),
                            ],
                          )
                        ],
                      );
                    },
                    stream: midiHandler.scanStatus);
              }),

        if (!midiHandler.permissionGranted)
          ListTile(
            title: Text(
              "Please, grant location permission",
              style: TextStyle(color: Colors.orange),
            ),
            onTap: () async {
              AlertDialogs.showLocationPrompt(context, true, () async {
                await Future.delayed(Duration(milliseconds: 1000));
                setState(() {});
              });
            },
          ),
        Divider(),
        ListTile(
          title: Text("App Version"),
          trailing: Text(_version),
          onTap: () {
            devCounter++;
            if (devCounter == 7) {
              Settings.devMode = true;
              setState(() {});
            }
          },
        ),
        if (Settings.devMode)
          ListTile(
              title: Text("Debug Console"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DebugConsole()));
              }),
        if (Settings.devMode)
          ListTile(
              title: Text("MIDI Commands Utility"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DeveloperPage()));
              }),
        // ListTile(
        //   title: Text("More Info"),
        //   onTap: () {
        //     showAboutDialog(
        //       context: context,
        //       applicationIcon:
        //           Icon(MightierIcons.amp, color: Colors.blue, size: 30),
        //       applicationVersion: _version,
        //       applicationLegalese: "© 2021 Dian Iliev (Tuntori)",
        //     );
        //   },
        // )
      ],
    );
  }
}
