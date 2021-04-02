// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../widgets/presets/presetList.dart';

class SelectPresetDialog {
  Widget buildDialog(BuildContext context,
      {required bool noneOption, String? customProduct}) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop()),
          Text('Select preset'),
        ],
      ),
      content: PresetList(
          simplified: true,
          noneOption: noneOption,
          customProductId: customProduct,
          onTap: (preset) {
            Navigator.of(context).pop(preset);
          }),
    );
  }
}
