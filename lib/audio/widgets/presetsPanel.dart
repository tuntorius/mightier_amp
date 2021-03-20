import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/selectPreset.dart';

import '../audioEditor.dart';

class PresetsPanel extends StatelessWidget {
  final EditorState state;
  final Function(Map<String, dynamic>) onSelectedPreset;

  PresetsPanel({this.state, this.onSelectedPreset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
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
            child:
                Text(state != EditorState.insert ? "Insert Event" : "Cancel"),
          ),
          ElevatedButton(
            child: Text("Duplicate Selected"),
            onPressed: () {},
          ),
          ElevatedButton(
            child: Text("Edit Selected"),
            onPressed: () {},
          ),
          ElevatedButton(
            child: Text("Delete Selected"),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
