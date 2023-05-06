import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../bluetooth/devices/NuxDevice.dart';
import '../../../bluetooth/devices/utilities/DelayTapTimer.dart';
import 'drumEditor.dart';

class TapButtons extends StatelessWidget {
  final NuxDevice device;
  final Function(double) onTempoModified;
  final Function(double) onTempoChanged;
  final Function() showTempoTrainer;
  const TapButtons(
      {super.key,
      required this.device,
      required this.onTempoModified,
      required this.onTempoChanged,
      required this.showTempoTrainer});

  void _onTapTempo() {
    DelayTapTimer.addClickTime();
    var bpm = DelayTapTimer.calculateBpm();
    if (bpm != false) {
      onTempoChanged(bpm);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool trainer = kDebugMode;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: trainer ? 120 : 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //TapOrHoldButton here
          //https://stackoverflow.com/questions/52128572/flutter-execute-method-so-long-the-button-pressed
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 48,
                  child: ElevatedButton(
                    onPressed:
                        device.drumsEnabled ? () => onTempoModified(-5) : null,
                    child: const Text("-5",
                        semanticsLabel: "Tempo -5", softWrap: false),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    width: 48,
                    child: ElevatedButton(
                      onPressed: device.drumsEnabled
                          ? () => onTempoModified(-1)
                          : null,
                      child: const Text("-1",
                          semanticsLabel: "Tempo -1", softWrap: false),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: device.drumsEnabled ? _onTapTempo : null,
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.resolveWith(
                        (states) {
                          return states.contains(MaterialState.pressed)
                              ? Colors.lightBlue[100]
                              : null;
                        },
                      ),
                    ),
                    child: const Text(
                      "Tap Tempo",
                      style: DrumEditor.fontStyle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    width: 48,
                    child: ElevatedButton(
                      onPressed:
                          device.drumsEnabled ? () => onTempoModified(1) : null,
                      child: const Text(
                        "+1",
                        softWrap: false,
                        semanticsLabel: "Tempo +1",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: ElevatedButton(
                    onPressed:
                        device.drumsEnabled ? () => onTempoModified(5) : null,
                    child: const Text(
                      "+5",
                      softWrap: false,
                      semanticsLabel: "Tempo +5",
                    ),
                  ),
                )
              ],
            ),
          ),
          if (trainer)
            const SizedBox(
              height: 6,
            ),
          if (trainer)
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: showTempoTrainer,
                child: const Text("Tempo Trainer", style: DrumEditor.fontStyle),
              ),
            )
        ],
      ),
    );
  }
}
