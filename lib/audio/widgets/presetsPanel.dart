import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/selectPreset.dart';
import 'package:mighty_plug_manager/audio/models/trackAutomation.dart';
import '../automationController.dart';

class PresetsPanel extends StatelessWidget {
  final AutomationController automation;
  final Function(Map<String, dynamic>) onSelectedPreset;
  final Function(AutomationEvent) onDuplicateEvent;
  final Function(AutomationEvent) onEditEvent;
  final Function onDelete;
  PresetsPanel(
      {required this.onSelectedPreset,
      required this.automation,
      required this.onDelete,
      required this.onEditEvent,
      required this.onDuplicateEvent});

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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => SelectPresetDialog()
                          .buildDialog(context, noneOption: false),
                    ).then((value) {
                      if (value != null) {
                        onSelectedPreset(value);
                      }
                    });
                  },
                  child: Text("Insert Event"),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  child: Text("Duplicate"),
                  onPressed: automation.selectedEvent != null
                      ? () {
                          onDuplicateEvent(automation.selectedEvent!);
                        }
                      : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: Text("Edit"),
                  onPressed: automation.selectedEvent == null
                      ? null
                      : () {
                          onEditEvent(automation.selectedEvent!);
                        },
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  child: Text("Delete"),
                  onPressed: automation.selectedEvent == null
                      ? null
                      : () {
                          onDelete();
                        },
                ),
              )
            ],
          ),
          MaterialButton(
            color: automation.initialEvent.getPresetUuid() == ""
                ? Colors.orange[700]
                : Colors.blue,
            textColor: Colors.white,
            child: Text("Edit Initial Parameters"),
            onPressed: () {
              onEditEvent(automation.initialEvent);
            },
          ),
        ],
      ),
    );
  }
}
