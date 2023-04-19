import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/common/modeControlRegular.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';

import '../../modules/tempo_trainer.dart';
import 'common/numberPicker.dart';

class TempoTrainerBottomSheet extends StatefulWidget {
  const TempoTrainerBottomSheet({Key? key}) : super(key: key);

  @override
  State<TempoTrainerBottomSheet> createState() =>
      _TempoTrainerBottomSheetState();
}

class _TempoTrainerBottomSheetState extends State<TempoTrainerBottomSheet>
    with SingleTickerProviderStateMixin {
  final _tempoTrainer = TempoTrainer.instance();

  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..repeat();
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  static const List<String> _dropDownValues = ['Beats', 'Seconds'];

  void _updateBpm() {
    setState(() {});
  }

  Widget _progressPlayPauseButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (BuildContext context, Widget? child) {
              double fill = _tempoTrainer.getTimerCountdown();
              return CircularProgressIndicator(
                value: fill,
                strokeWidth: 10,
                //backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.green,
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _tempoTrainer.enable = !_tempoTrainer.enable;
            });
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(_tempoTrainer.enable ? Icons.stop : Icons.play_arrow),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var device = NuxDeviceControl.instance().device;
    _tempoTrainer.onTempoChanged = _updateBpm;
    return SizedBox(
      height: 400,
      child: Column(children: [
        ListTile(
          title: const Center(child: Text("Tempo Range")),
          subtitle: RangeSlider(
              min: device.drumsMinTempo,
              max: device.drumsMaxTempo,
              divisions: (device.drumsMaxTempo - device.drumsMinTempo).round(),
              labels: RangeLabels(
                  "${_tempoTrainer.tempoRange.start.round()} bpm",
                  "${_tempoTrainer.tempoRange.end.round()} bpm"),
              values: _tempoTrainer.tempoRange,
              onChanged: (range) {
                _tempoTrainer.tempoRange = range;
                setState(() {});
              }),
        ),
        ModeControlRegular(
            options: _dropDownValues,
            selected: _tempoTrainer.changeMode.index,
            onSelected: (index) {
              setState(() {
                _tempoTrainer.changeMode = TempoChangeMode.values[index];
              });
            }),
        ListTile(
          title: Text("Increase every"),
          subtitle: NumberPicker(
            textStyle: const TextStyle(color: Colors.grey),
            minValue: 2,
            maxValue: 100,
            value: _tempoTrainer.changeUnits,
            axis: Axis.horizontal,
            onChanged: (value) {
              _tempoTrainer.changeUnits = value.round();
              setState(() {});
            },
          ),
        ),
        /*ListTile(
            title: const Center(child: Text("Increase every")),
            subtitle: Slider(
              min: 2,
              max: 100,
              divisions: 99,
              label:
                  "${_tempoTrainer.changeUnits} ${_dropDownValues[_tempoTrainer.changeMode.index].toLowerCase()}",
              value: _tempoTrainer.changeUnits.toDouble(),
              onChanged: (value) {
                _tempoTrainer.changeUnits = value.round();
                setState(() {});
              },
              onChangeEnd: (value) {},
            )),*/
        ListTile(
          title: const Center(child: Text("Increase by")),
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
        _progressPlayPauseButton(),
        Text("${device.drumsTempo.round()} bpm")
      ]),
    );
  }
}
