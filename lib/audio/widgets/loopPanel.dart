import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/numberPicker.dart';
import '../automationController.dart';

class LoopPanel extends StatelessWidget {
  final AutomationController automation;
  final Function(bool?) onLoopEnable;
  final Function(bool) onUseLoopPoints;
  final Function(int) onLoopTimes;
  const LoopPanel({
    Key? key,
    required this.automation,
    required this.onLoopEnable,
    required this.onUseLoopPoints,
    required this.onLoopTimes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dense = false;
    var height = MediaQuery.of(context).size.height;
    if (height < 600) dense = true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /*ElevatedButton(
            onPressed: () {
              onAddLoop();
            },
            child: Text("Insert Loop Points"),
          ),
          const SizedBox(
            width: 8,
          ),*/

          CheckboxListTile(
              title: const Text("Enable Loop"),
              value: automation.loopEnable,
              dense: dense,
              onChanged: onLoopEnable),
          SwitchListTile(
              title: const Text("Use Loop Points"),
              value: automation.useLoopPoints,
              dense: dense,
              onChanged:
                  automation.loopEnable == false ? null : onUseLoopPoints),
          if (!dense)
            const SizedBox(
              height: 8,
            ),
          Center(
              child: Text(
            "Loop Times",
            style: TextStyle(
                fontSize: dense ? 12 : 16,
                color: automation.loopEnable ? Colors.white : Colors.grey[700]),
          )),
          AbsorbPointer(
            absorbing: !automation.loopEnable,
            child: NumberPicker(
              axis: Axis.horizontal,
              itemHeight: dense ? 50 : 70,
              minValue: 0,
              maxValue: 20,
              selectedTextStyle: TextStyle(
                  fontSize: 22,
                  color:
                      automation.loopEnable ? Colors.white : Colors.grey[700]),
              textStyle: TextStyle(
                  color:
                      automation.loopEnable ? Colors.grey : Colors.grey[800]),
              zeroSymbol: "∞",
              value: automation.loopTimes,
              onChanged: automation.loopEnable == false
                  ? null
                  : (value) {
                      onLoopTimes(value);
                    },
            ),
          )
          /*Row(
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
          ),*/
        ],
      ),
    );
  }
}
