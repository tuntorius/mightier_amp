import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../bluetooth/devices/NuxDevice.dart';
import '../../../bluetooth/devices/utilities/DelayTapTimer.dart';
import 'drumEditor.dart';

class TapButtons extends StatelessWidget {
  final NuxDevice device;
  final Function(double) onTempoModified;
  final Function(double) onTempoChanged;

  const TapButtons(
      {super.key,
      required this.device,
      required this.onTempoModified,
      required this.onTempoChanged});

  void _onTapTempo() {
    DelayTapTimer.addClickTime();
    var bpm = DelayTapTimer.calculateBpm();
    if (bpm != false) {
      onTempoChanged(bpm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 60),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: ElevatedButton(
              onPressed: () => onTempoModified(-5),
              child:
                  const Text("-5", semanticsLabel: "Tempo -5", softWrap: false),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              width: 48,
              child: ElevatedButton(
                onPressed: () => onTempoModified(-1),
                child: const Text("-1",
                    semanticsLabel: "Tempo -1", softWrap: false),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: _onTapTempo,
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
                onPressed: () => onTempoModified(1),
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
              onPressed: () => onTempoModified(5),
              child: const Text(
                "+5",
                softWrap: false,
                semanticsLabel: "Tempo +5",
              ),
            ),
          )
        ],
      ),
    );
  }
}
