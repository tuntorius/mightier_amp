import 'package:flutter/material.dart';
import '../widgets/presets/presetList.dart';

class SelectPresetDialog {
  Widget buildDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[700],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop()),
          Text(
            'Select preset',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: Container(
        height: 300,
        child: PresetList(onTap: (preset) {
          Navigator.of(context).pop(preset);
        }),
      ),
    );
  }
}
