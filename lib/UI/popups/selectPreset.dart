// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../widgets/presets/preset_list/presetList.dart';

class SelectPresetDialog {
  Widget buildDialog(BuildContext context, {required bool noneOption}) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
              icon: Icon(
                Icons.adaptive.arrow_back,
                color: Colors.white,
              ),
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop()),
          const Text('Select preset'),
        ],
      ),
      actions: [],
      content: Scaffold(
        body: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              if (noneOption)
                ListTile(
                  title: const Center(child: Text("None")),
                  onTap: () =>
                      Navigator.of(context, rootNavigator: true).pop(false),
                ),
              PresetList(
                  simplified: true,
                  onTap: (preset) {
                    Navigator.of(context, rootNavigator: true).pop(preset);
                  }),
            ]),
      ),
    );
  }
}
