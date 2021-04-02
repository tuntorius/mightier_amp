import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/selectPreset.dart';
import '../automationController.dart';

class LoopPanel extends StatelessWidget {
  final AutomationController automation;
  final Function() onAddLoop;
  final Function onDeleteLoop;
  LoopPanel({
    required this.automation,
    required this.onAddLoop,
    required this.onDeleteLoop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              onAddLoop();
            },
            child: Text("Insert Loop Points"),
          ),
          const SizedBox(
            width: 8,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: Text("Edit"),
                  onPressed: automation.selectedEvent == null
                      ? null
                      : () {
                          //onEditEvent(automation.selectedEvent!);
                        },
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  child: Text("Delete"),
                  onPressed: automation.selectedEvent == null
                      ? null
                      : () {
                          //onDelete();
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
              //onEditEvent(automation.initialEvent);
            },
          ),
        ],
      ),
    );
  }
}
