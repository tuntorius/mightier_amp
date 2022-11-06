import 'dart:math';

import 'package:flutter/material.dart';

class SpeedPanel extends StatelessWidget {
  final double speed;
  final int semitones;
  final Function(double) onSpeedChanged;
  final Function(int) onSemitonesChanged;

  const SpeedPanel(
      {Key? key,
      required this.speed,
      required this.semitones,
      required this.onSpeedChanged,
      required this.onSemitonesChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text("Speed: ${(speed * 100).round()}%"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (speed <= 0.2) return;
                    var _speed = speed - 0.02;
                    _speed = max(_speed, 0.01);
                    onSpeedChanged(_speed);
                  },
                  child: const Text("-")),
              ElevatedButton(
                  onPressed: () {
                    if (speed > 3) return;
                    var _speed = speed + 0.02;
                    onSpeedChanged(_speed);
                  },
                  child: const Text("+"))
            ],
          ),
        ),
        ListTile(
          title: Text("Pitch: ${semitones > 0 ? "+" : ""}$semitones semitones"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (semitones == -12) return;
                    var _semitones = semitones - 1;
                    onSemitonesChanged(_semitones);
                  },
                  child: const Text("-")),
              ElevatedButton(
                  onPressed: () {
                    if (semitones == 12) return;
                    var _semitones = semitones + 1;
                    onSemitonesChanged(_semitones);
                  },
                  child: const Text("+"))
            ],
          ),
        ),
      ],
    );
  }
}
