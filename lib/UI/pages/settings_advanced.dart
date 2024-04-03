import 'package:flutter/material.dart';

import '../../bluetooth/NuxDeviceControl.dart';
import '../../platform/platformUtils.dart';
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
            if (PlatformUtils.isAndroid)
              CheckboxListTile(
                  title: const Text("Use legacy waveform decoder"),
                  subtitle: const Text(
                      "Enable this if you experience crashes when editing tracks"),
                  value:
                      SharedPrefs().getInt(SettingsKeys.legacyDecoder, 0) != 0,
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        SharedPrefs()
                            .setInt(SettingsKeys.legacyDecoder, value ? 1 : 0);
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
