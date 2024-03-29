import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/drumEditor.dart';
import 'package:mighty_plug_manager/UI/widgets/common/modeControlRegular.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';

import '../../../modules/tempo_trainer.dart';
import '../../widgets/thickRangeSlider.dart';
import '../../widgets/thickSlider.dart';

class TempoTrainerSheet extends StatefulWidget {
  final bool smallControls;
  final bool overtakeDrums;
  final bool enabled;
  const TempoTrainerSheet(
      {Key? key,
      required this.smallControls,
      required this.overtakeDrums,
      this.enabled = true})
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
    if (widget.overtakeDrums &&
        NuxDeviceControl.instance().device.drumsEnabled !=
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
            onPressed: !widget.enabled || !NuxDeviceControl().isConnected
                ? null
                : () async {
                    NuxDeviceControl.instance().device.setDrumsEnabled(false);
                    await Future.delayed(const Duration(milliseconds: 50));
                    setState(() {
                      _tempoTrainer.enable = !_tempoTrainer.enable;
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _tempoTrainer.enable ? Colors.orange : Colors.green,
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
          enabled: widget.enabled,
          activeColor: Colors.blue,
          values: _tempoTrainer.tempoRange,
          onChanged: (range, skip) {
            _tempoTrainer.tempoRange = range;
            setState(() {});
          },
          onDragEnd: (value) {
            _tempoTrainer.saveConfig();
          },
          label: 'Tempo Range',
          labelFormatter: (ranges) =>
              "${ranges.start.round()} - ${ranges.end.round()}"),
      ListTile(
        enabled: widget.enabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: const FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.none,
          child: Text(
            "Mode",
            style: TextStyle(fontSize: 20),
          ),
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 40),
          child: ModeControlRegular(
              options: _dropDownValues,
              textStyle: DrumEditor.fontStyle,
              selected: _tempoTrainer.changeMode.index,
              onSelected: !widget.enabled
                  ? null
                  : (index) {
                      setState(() {
                        _tempoTrainer.changeMode =
                            TempoChangeMode.values[index];
                        _tempoTrainer.saveConfig();
                      });
                    }),
        ),
      ),
      ThickSlider(
          min: 2,
          max: 100,
          enabled: widget.enabled,
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
          onDragEnd: (value) {
            _tempoTrainer.saveConfig();
          }),
      ThickSlider(
          min: 1,
          max: 20,
          enabled: widget.enabled,
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
          onDragEnd: (value) {
            _tempoTrainer.saveConfig();
          }),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(child: SizedBox.shrink()),
          _progressPlayPauseButton(widget.smallControls),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                _tempoTrainer.enable ? "${device.drumsTempo.round()} bpm" : "",
                style: DrumEditor.fontStyle.copyWith(
                    color: widget.enabled ? Colors.white : Colors.grey[600]),
              ),
            ),
          )
        ],
      ),
    ]);
  }
}
