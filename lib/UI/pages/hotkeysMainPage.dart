import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/hotkeysSetup.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/devices/features/tuner.dart';
import 'package:mighty_plug_manager/midi/ControllerConstants.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

import '../../bluetooth/devices/features/looper.dart';

class HotkeysMainPage extends StatelessWidget {
  final MidiController controller;
  const HotkeysMainPage({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Channel/Preset Hotkeys"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HotkeysSetup(
                      controller: controller,
                      category: HotkeyCategory.Channels,
                    ))),
          ),
          ListTile(
            title: const Text("Effect Hotkeys"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HotkeysSetup(
                      controller: controller,
                      category: HotkeyCategory.EffectSlots,
                    ))),
          ),
          ListTile(
              title: const Text("Parameter Hotkeys"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HotkeysSetup(
                        controller: controller,
                        category: HotkeyCategory.EffectParameters,
                      )))),
          ListTile(
              title: const Text("Drums Hotkeys"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HotkeysSetup(
                        controller: controller,
                        category: HotkeyCategory.Drums,
                      )))),
          if (NuxDeviceControl.instance().device is Looper)
            ListTile(
                title: const Text("Looper Hotkeys"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HotkeysSetup(
                          controller: controller,
                          category: HotkeyCategory.Looper,
                        )))),
          ListTile(
              title: const Text("JamTracks Hotkeys"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HotkeysSetup(
                        controller: controller,
                        category: HotkeyCategory.JamTracks,
                      )))),
          if (NuxDeviceControl.instance().device is Tuner)
            ListTile(
                title: const Text("Misc Hotkeys"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HotkeysSetup(
                          controller: controller,
                          category: HotkeyCategory.Misc,
                        )))),
        ],
      ),
    );
  }
}
