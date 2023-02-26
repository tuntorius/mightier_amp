import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';

import '../../modules/tempo_trainer.dart';

class TempoTrainerBottomSheet extends StatefulWidget {
  const TempoTrainerBottomSheet({Key? key}) : super(key: key);

  @override
  State<TempoTrainerBottomSheet> createState() =>
      _TempoTrainerBottomSheetState();
}

class _TempoTrainerBottomSheetState extends State<TempoTrainerBottomSheet> {
  final _tempoTrainer = TempoTrainer.instance();

  void _updateBpm() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var device = NuxDeviceControl.instance().device;
    _tempoTrainer.onTempoChanged = _updateBpm;
    return SizedBox(
      height: 400,
      child: Column(children: [
        SwitchListTile(
          value: _tempoTrainer.enable,
          onChanged: (value) {
            _tempoTrainer.enable = value;
            setState(() {});
          },
          title: const Text("Enable"),
        ),
        RangeSlider(
            min: device.drumsMinTempo,
            max: device.drumsMaxTempo,
            divisions: (device.drumsMaxTempo - device.drumsMinTempo).round(),
            labels: RangeLabels("${_tempoTrainer.tempoRange.start.round()} bpm",
                "${_tempoTrainer.tempoRange.end.round()} bpm"),
            values: _tempoTrainer.tempoRange,
            onChanged: (range) {
              _tempoTrainer.tempoRange = range;
              setState(() {});
            }),
        const Text("<MODE CONTROL>"),
        ListTile(
            title: const Text("Increase every"),
            subtitle: Slider(
              min: 1,
              max: 100,
              divisions: 99,
              label: "${_tempoTrainer.changeUnits} bars",
              value: _tempoTrainer.changeUnits.toDouble(),
              onChanged: (value) {
                _tempoTrainer.changeUnits = value.round();
                setState(() {});
              },
              onChangeEnd: (value) {},
            )),
        ListTile(
          title: const Text("Increase by"),
          subtitle: Slider(
              min: 1,
              max: 20,
              divisions: 19,
              label: "${_tempoTrainer.tempoStep.round()} bpm",
              value: _tempoTrainer.tempoStep,
              onChanged: (value) {
                _tempoTrainer.tempoStep = value;
                setState(() {});
              }),
        ),
        Text("${device.drumsTempo.round()} bpm")
      ]),
    );
  }
}
