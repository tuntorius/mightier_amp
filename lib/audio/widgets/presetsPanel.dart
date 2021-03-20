import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/selectPreset.dart';

import '../audioEditor.dart';

class PresetsPanel extends StatelessWidget {
  final EditorState state;
  final Function(Map<String, dynamic>?) onSelectedPreset;
  final Function onDelete;
  PresetsPanel(
      {required this.state,
      required this.onSelectedPreset,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
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
                  child: Text(
                      state != EditorState.insert ? "Insert Event" : "Cancel"),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  child: Text("Duplicate"),
                  onPressed: null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: Text("Edit"),
                  onPressed: null,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  child: Text("Delete"),
                  onPressed: () {
                    onDelete();
                  },
                ),
              )
            ],
          ),
          ElevatedButton(
            child: Text("Set Initial Parameters"),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
