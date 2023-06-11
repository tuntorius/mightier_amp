import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';

import '../../bluetooth/NuxDeviceControl.dart';
import '../../platform/simpleSharedPrefs.dart';
import 'calibration.dart';

class AdvancedSettings extends StatefulWidget {
  const AdvancedSettings({super.key});

  @override
  State<AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Advanced Settings"),
        ),
        body: ListView(
          children: [
            ListTile(
              enabled: NuxDeviceControl().isConnected,
              title: const Text("Calibrate BT Audio Latency"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Calibration()));
              },
            ),
            CheckboxListTile(
                title: const Text(
                    "Enable hidden Mighty Plug Pro / Mighty Space amps"),
                value: SharedPrefs().getInt(SettingsKeys.hiddenAmps, 0) != 0,
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      SharedPrefs()
                          .setInt(SettingsKeys.hiddenAmps, value ? 1 : 0);
                      AlertDialogs.showInfoDialog(context,
                          title: "Restart Required!",
                          description:
                              "Please, restart Mightier Amp for the setting to take effect.",
                          confirmButton: "OK");
                    }
                  });
                }),
            CheckboxListTile(
                title: const Text("Hide non-applicable presets"),
                value: SharedPrefs()
                        .getInt(SettingsKeys.hideNotApplicablePresets, 0) !=
                    0,
                onChanged: (value) {
                  if (value != null) {
                    SharedPrefs().setInt(
                        SettingsKeys.hideNotApplicablePresets, value ? 1 : 0);
                  }
                  setState(() {});
                  NuxDeviceControl().forceNotifyListeners();
                }),
          ],
        ));
  }
}
