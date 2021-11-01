import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/hotkeysSetup.dart';
import 'package:mighty_plug_manager/midi/ControllerConstants.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

class HotkeysMainPage extends StatelessWidget {
  final MidiController controller;
  const HotkeysMainPage({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setup"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Channel Hotkeys"),
            trailing: Icon(Icons.arrow_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HotkeysSetup(
                      controller: controller,
                      category: HotkeyCategory.Channels,
                    ))),
          ),
          ListTile(
            title: Text("Effect On/Off Hotkeys"),
            trailing: Icon(Icons.arrow_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HotkeysSetup(
                      controller: controller,
                      category: HotkeyCategory.EffectSlots,
                    ))),
          ),
          ListTile(
              title: Text("Parameter Hotkeys"),
              trailing: Icon(Icons.arrow_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HotkeysSetup(
                        controller: controller,
                        category: HotkeyCategory.EffectParameters,
                      ))))
        ],
      ),
    );
  }
}
