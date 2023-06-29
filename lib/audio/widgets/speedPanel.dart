import 'dart:math';

import 'package:flutter/material.dart';
import '../../UI/widgets/hold_to_repeat.dart';
import '../../platform/platformUtils.dart';

class SpeedPanel extends StatelessWidget {
  final double speed;
  final int semitones;
  final bool compact;
  final Function(double) onSpeedChanged;
  final Function(int) onSemitonesChanged;

  const SpeedPanel(
      {Key? key,
      required this.speed,
      required this.semitones,
      required this.onSpeedChanged,
      required this.onSemitonesChanged,
      this.compact = false})
      : super(key: key);

  void _modifySpeed(double amount) {
    var _speed = speed + amount;

    _speed = min(max(_speed, 0.1), 2.5);
    onSpeedChanged(_speed);
  }

  void _modifyPitch(int amount) {
    var _semitones = semitones + amount;
    _semitones = min(max(_semitones, -12), 12);
    onSemitonesChanged(_semitones);
  }

  Widget _speedControl() {
    return Row(
      children: [
        HoldToRepeat(
          onPressed: () => _modifySpeed(-0.02),
          child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.remove_circle_outlined)),
        ),
        InkWell(
          onTap: () => onSpeedChanged(1),
          child: SizedBox(
            width: 58,
            child: Column(
              children: [
                const Icon(Icons.speed),
                Text("${(speed * 100).round()}%")
              ],
            ),
          ),
        ),
        HoldToRepeat(
          onPressed: () => _modifySpeed(0.02),
          child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.add_circle_outlined)),
        ),
      ],
    );
  }

  Widget _pitchControl() {
    return Row(
      children: [
        IconButton(
            padding: const EdgeInsets.all(16),
            onPressed: () => _modifyPitch(-1),
            icon: const Icon(Icons.remove_circle_outlined)),
        InkWell(
          onTap: () => onSemitonesChanged(0),
          child: SizedBox(
            width: 58,
            child: Column(
              children: [
                const Icon(Icons.music_note),
                Text("${semitones > 0 ? "+" : ""}$semitones semi")
              ],
            ),
          ),
        ),
        IconButton(
            padding: const EdgeInsets.all(16),
            onPressed: () => _modifyPitch(1),
            icon: const Icon(Icons.add_circle_outlined)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (compact)
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: PlatformUtils.isIOS
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                _speedControl(),
                if (!PlatformUtils.isIOS) _pitchControl(),
              ]),
        if (!compact)
          ListTile(
            title: Text("Speed: ${(speed * 100).round()}%"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: () => _modifySpeed(-0.02),
                    child: const Text("-")),
                ElevatedButton(
                    onPressed: () => _modifySpeed(0.02), child: const Text("+"))
              ],
            ),
          ),
        if (!compact && !PlatformUtils.isIOS)
          ListTile(
            title:
                Text("Pitch: ${semitones > 0 ? "+" : ""}$semitones semitones"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: () => _modifyPitch(-1), child: const Text("-")),
                ElevatedButton(
                    onPressed: () => _modifyPitch(1), child: const Text("+"))
              ],
            ),
          ),
      ],
    );
  }
}
