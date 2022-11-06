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
  const PresetsPanel(
      {Key? key,
      required this.onSelectedPreset,
      required this.automation,
      required this.onDelete,
      required this.onEditEvent,
      required this.onDuplicateEvent})
      : super(key: key);

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
                  child: const Text("Insert Event"),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: automation.selectedEvent != null
                      ? () {
                          onDuplicateEvent(automation.selectedEvent!);
                        }
                      : null,
                  child: const Text("Duplicate"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: automation.selectedEvent == null
                      ? null
                      : () {
                          onEditEvent(automation.selectedEvent!);
                        },
                  child: const Text("Edit"),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: automation.selectedEvent == null
                      ? null
                      : () {
                          onDelete();
                        },
                  child: const Text("Delete"),
                ),
              )
            ],
          ),
          MaterialButton(
            color: automation.initialEvent.getPresetUuid() == ""
                ? Colors.orange[700]
                : Colors.blue,
            textColor: Colors.white,
            child: const Text("Edit Initial Parameters"),
            onPressed: () {
              onEditEvent(automation.initialEvent);
            },
          ),
        ],
      ),
    );
  }
}
