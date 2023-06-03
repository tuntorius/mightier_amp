import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/drumEditor.dart';
import 'package:mighty_plug_manager/UI/widgets/common/modeControlRegular.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';

import '../../../modules/tempo_trainer.dart';
import '../../widgets/thickRangeSlider.dart';
import '../../widgets/thickSlider.dart';

class TempoTrainerSheet extends StatefulWidget {
  final bool smallControls;
  const TempoTrainerSheet({Key? key, required this.smallControls})
      : super(key: key);

  @override
  State<TempoTrainerSheet> createState() => _TempoTrainerSheetState();
}

class _TempoTrainerSheetState extends State<TempoTrainerSheet>
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
    NuxDeviceControl.instance().addListener(_updateBpm);
  }

  @override
  void dispose() {
    NuxDeviceControl.instance().removeListener(_updateBpm);
    _animationController.dispose();
    super.dispose();
  }

  static const List<String> _dropDownValues = ['Beats', 'Seconds'];

  void _updateBpm() {
    if (NuxDeviceControl.instance().device.drumsEnabled !=
        _tempoTrainer.enable) {
      _tempoTrainer.enable = NuxDeviceControl.instance().device.drumsEnabled;
    }
    setState(() {});
  }

  Widget _progressPlayPauseButton(bool small) {
    double size = small ? 60 : 80;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
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
            onPressed: () async {
              NuxDeviceControl.instance().device.setDrumsEnabled(false);
              await Future.delayed(const Duration(milliseconds: 50));
              setState(() {
                _tempoTrainer.enable = !_tempoTrainer.enable;
              });
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.all(small ? 14 : 20),
            ),
            child: Icon(_tempoTrainer.enable ? Icons.stop : Icons.play_arrow),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var device = NuxDeviceControl.instance().device;
    return Column(children: [
      ThickRangeSlider(
          maxHeight: widget.smallControls ? 40 : null,
          min: device.drumsMinTempo,
          max: device.drumsMaxTempo,
          activeColor: Colors.blue,
          values: _tempoTrainer.tempoRange,
          onChanged: (range, skip) {
            _tempoTrainer.tempoRange = range;
            setState(() {});
          },
          label: 'Tempo Range',
          labelFormatter: (ranges) =>
              "${ranges.start.round()} - ${ranges.end.round()}"),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: const Text(
          "Increase Mode",
          style: DrumEditor.fontStyle,
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 40),
          child: ModeControlRegular(
              options: _dropDownValues,
              textStyle: DrumEditor.fontStyle,
              selected: _tempoTrainer.changeMode.index,
              onSelected: (index) {
                setState(() {
                  _tempoTrainer.changeMode = TempoChangeMode.values[index];
                });
              }),
        ),
      ),
      ThickSlider(
        min: 2,
        max: 100,
        maxHeight: widget.smallControls ? 40 : null,
        activeColor: Colors.blue,
        label: "Increase every",
        labelFormatter: (val) {
          return "${val.round()} ${_tempoTrainer.changeMode == TempoChangeMode.beat ? "beats" : "seconds"}";
        },
        value: _tempoTrainer.changeUnits.toDouble(),
        onChanged: (value, skip) {
          _tempoTrainer.changeUnits = value.round();
          setState(() {});
        },
      ),
      ThickSlider(
        min: 1,
        max: 20,
        maxHeight: widget.smallControls ? 40 : null,
        activeColor: Colors.blue,
        label: "Increase by",
        labelFormatter: (val) {
          return "${val.round()} bpm";
        },
        value: _tempoTrainer.tempoStep.toDouble(),
        onChanged: (value, skip) {
          _tempoTrainer.tempoStep = value.round();
          setState(() {});
        },
      ),
      _progressPlayPauseButton(widget.smallControls),
      Text(
        "${device.drumsTempo.round()} bpm",
        style: const TextStyle(fontSize: 18),
      )
    ]);
  }
}
