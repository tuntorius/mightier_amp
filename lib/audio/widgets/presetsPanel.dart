import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/selectPreset.dart';

import '../audioEditor.dart';

class PresetsPanel extends StatelessWidget {
  final EditorState state;
  final Function(Map<String, dynamic>) onSelectedPreset;

  PresetsPanel({this.state, this.onSelectedPreset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            if (state != EditorState.insert) {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    SelectPresetDialog().buildDialog(context),
              ).then((value) {
                if (value != null) {
                  onSelectedPreset(value);
                }
              });
            } else
              onSelectedPreset(null);
          },
          child: Container(
            width: 150,
            height: 40,
            alignment: Alignment.center,
            child:
                Text(state != EditorState.insert ? "Insert Event" : "Cancel"),
          ),
        ),
      ],
    );
  }
}
