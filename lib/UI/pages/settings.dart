// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakelock/wakelock.dart';

import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/bleMidiHandler.dart';
import '../../bluetooth/ble_controllers/BLEController.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../bluetooth/devices/features/tuner.dart';
import '../../platform/simpleSharedPrefs.dart';
import '../mightierIcons.dart';
import '../widgets/deviceList.dart';
import 'DebugConsolePage.dart';
import 'developerPage.dart';
import 'midiControllers.dart';
import 'settings_advanced.dart';
import 'tunerPage.dart';

enum TimeUnit { BPM, Seconds }

const _timeUnit = ["BPM", "Seconds"];

class Settings extends StatefulWidget {
  static bool devMode = false;
  static String output = "";

  const Settings({Key? key}) : super(key: key);

  static void print(String value) {
    if (output.isNotEmpty) output += "\n";
    output += value;
  }

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final BLEMidiHandler midiHandler;
  String _version = "";
  int devCounter = 0;

  @override
  void initState() {
    super.initState();
    NuxDeviceControl.instance().addListener(_deviceChanged);
    midiHandler = BLEMidiHandler.instance();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _version = packageInfo.version;
      });
    });
  }

  @override
  void dispose() {
    NuxDeviceControl.instance().removeListener(_deviceChanged);
    super.dispose();
  }

  void _deviceChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final NuxDevice device = NuxDeviceControl.instance().device;
    List<String> items = Settings.output.split('\n');
    return SafeArea(
      child: ListView(
        children: [
          if (kDebugMode)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Text(items[index]);
                },
                itemCount: items.length,
              ),
            ),
          ListTileTheme(
            minLeadingWidth: 0,
            iconColor: Colors.white,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Keep Screen On"),
                  value: SharedPrefs()
                      .getValue(SettingsKeys.screenAlwaysOn, false),
                  onChanged: (val) {
                    setState(() {
                      Wakelock.toggle(enable: val);
                      SharedPrefs().setValue(SettingsKeys.screenAlwaysOn, val);
                    });
                  },
                ),
                ListTile(
                  title: const Text("Delay Time Unit"),
                  subtitle: Text(_timeUnit[SharedPrefs()
                      .getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index)]),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    var dialog = AlertDialogs.showOptionDialog(context,
                        confirmButton: "OK",
                        cancelButton: "Cancel",
                        title: "Delay Time Unit",
                        confirmColor: Theme.of(context).hintColor,
                        value: SharedPrefs().getValue(
                            SettingsKeys.timeUnit, TimeUnit.BPM.index),
                        options: _timeUnit, onConfirm: (changed, newValue) {
                      if (changed) {
                        setState(() {
                          SharedPrefs()
                              .setValue(SettingsKeys.timeUnit, newValue);
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
                  title: const Text("Device"),
                  subtitle: Text(device.productName),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    var dialog = AlertDialogs.showOptionDialog(context,
                        confirmButton: "OK",
                        cancelButton: "Cancel",
                        title: "Select Device",
                        confirmColor: Theme.of(context).hintColor,
                        value: NuxDeviceControl.instance().deviceIndex,
                        options: NuxDeviceControl.instance().deviceNameList,
                        onConfirm: (changed, newValue) {
                      if (changed) {
                        NuxDeviceControl.instance().deviceIndex = newValue;
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
                    title: const Text("Firmware Version"),
                    subtitle: Text(
                        device.getProductNameVersion(device.productVersion)),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      var dialog = AlertDialogs.showOptionDialog(context,
                          confirmButton: "OK",
                          cancelButton: "Cancel",
                          title: "Select Version",
                          confirmColor: Theme.of(context).hintColor,
                          value:
                              NuxDeviceControl.instance().deviceFirmwareVersion,
                          options:
                              NuxDeviceControl.instance().deviceVersionsList,
                          onConfirm: (changed, newValue) {
                        if (changed) {
                          NuxDeviceControl.instance().deviceFirmwareVersion =
                              newValue;
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
                    title: const Text("Set matching cabinets automatically"),
                    value:
                        SharedPrefs().getInt(SettingsKeys.changeCabs, 1) != 0,
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          SharedPrefs()
                              .setInt(SettingsKeys.changeCabs, value ? 1 : 0);
                        }
                      });
                    }),
                const Divider(),
                if (device.deviceControl.isConnected &&
                    device is Tuner &&
                    (device as Tuner).tunerAvailable)
                  ListTile(
                    leading: const Icon(MightierIcons.tuner),
                    title: const Text("Tuner"),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TunerPage(
                                device: device,
                              )));
                    },
                  ),
                device.getSettingsWidget(),
                ListTile(
                  title: const Text("Remote Control"),
                  subtitle:
                      const Text("Use a MIDI/HID device to control the amp"),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MidiControllers()));
                  },
                ),
              ],
            ),
          ),
          if (midiHandler.permissionGranted)
            StreamBuilder<MidiSetupStatus>(
                stream: midiHandler.status,
                builder: (BuildContext context, snapshot) {
                  return StreamBuilder<bool>(
                      builder: (BuildContext context, snapshot) {
                        var btOn = midiHandler.bleState == BleState.on;
                        if (!btOn) {
                          return const ListTile(
                            title: Text("Please, turn Bluetooth on!"),
                          );
                        }
                        bool scanning = midiHandler.isScanning;
                        bool connected =
                            NuxDeviceControl.instance().isConnected;

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
                                  onPressed: connected || scanning
                                      ? null
                                      : () {
                                          midiHandler.startScanning(true);
                                        },
                                  child: const Text("Scan"),
                                ),
                                ElevatedButton(
                                  onPressed: connected || !scanning
                                      ? null
                                      : () {
                                          midiHandler.stopScanning();
                                        },
                                  child: const Text("Stop Scanning"),
                                ),
                                ElevatedButton(
                                  onPressed: !connected
                                      ? null
                                      : () {
                                          midiHandler.disconnectDevice();
                                          setState(() {});
                                        },
                                  child: const Text("Disconnect"),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                      stream: midiHandler.isScanningStream);
                }),
          if (!midiHandler.permissionGranted)
            ListTile(
              title: const Text(
                "Please, grant location permission",
                style: TextStyle(color: Colors.orange),
              ),
              onTap: () async {
                AlertDialogs.showLocationPrompt(context, true, () async {
                  await Future.delayed(const Duration(milliseconds: 1000));
                  setState(() {});
                });
              },
            ),
          const Divider(),
          ListTile(
            title: const Text("Advanced Settings"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AdvancedSettings()));
            },
          ),
          ListTile(
            title: const Text("App Version"),
            trailing: Text(_version),
            onTap: () {
              devCounter++;
              if (devCounter == 7) {
                Settings.devMode = true;
                if (SharedPrefs().getInt(SettingsKeys.hiddenAmps, 0) == 0) {
                  SharedPrefs().setInt(SettingsKeys.hiddenAmps, 1);
                } else {
                  SharedPrefs().setInt(SettingsKeys.hiddenSources, 1);
                }
                setState(() {});
              }
            },
          ),
          if (Settings.devMode)
            ElevatedButton(
                onPressed: () => device.communication.fillTestData(),
                child: const Text("Fill test data")),
          if (Settings.devMode)
            ListTile(
                title: const Text("Debug Console"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DebugConsole()));
                }),
          if (Settings.devMode)
            ListTile(
                title: const Text("MIDI Commands Utility"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DeveloperPage()));
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
          // ),
        ],
      ),
    );
  }
}
