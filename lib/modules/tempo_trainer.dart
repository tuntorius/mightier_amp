import 'dart:async';

import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';

import '../UI/widgets/thickRangeSlider.dart';
import '../bluetooth/devices/NuxDevice.dart';

enum TempoChangeMode { beat, time }

class TempoTrainer {
  static final TempoTrainer _tempoTrainer = TempoTrainer._();

  TempoTrainer._();

  NuxDevice get _device => NuxDeviceControl.instance().device;

  factory TempoTrainer.instance() {
    return _tempoTrainer;
  }

  Timer? _timer;

  SliderRangeValues tempoRange = SliderRangeValues(80, 200);
  int tempoStep = 5;
  TempoChangeMode changeMode = TempoChangeMode.beat;

  //this how much beats or seconds to the next change
  int changeUnits = 8;
  bool _enable = false;

  DateTime _expiryTime = DateTime.now();
  double _durationMs = 0;

  bool get enable => _enable;
  set enable(enable) {
    _enable = enable;
    _device.setDrumsEnabled(enable);
    NuxDeviceControl.instance().forceNotifyListeners();
    if (enable) {
      _startTrainer();
    } else {
      _timer?.cancel();
    }
  }

  void _startTrainer() {
    //reset tempo from beginning and setup timer
    _device.setDrumsTempo(tempoRange.start, true);
    _setupTimer();
  }

  void _setupTimer() {
    //setup for the next iteration of the trainer
    _durationMs = changeMode == TempoChangeMode.beat
        ? ((59.9 / _device.drumsTempo) * changeUnits.toDouble()) * 1000
        : changeUnits.toDouble() * 1000;
    _expiryTime =
        DateTime.now().add(Duration(milliseconds: _durationMs.round()));
    _timer = Timer(Duration(milliseconds: _durationMs.round()), _onTimerStep);
  }

  double getTimerCountdown() {
    if (!_enable) return 0;
    return _expiryTime.difference(DateTime.now()).inMilliseconds / _durationMs;
  }

  void _onTimerStep() {
    //increment to the next tempo value
    var tempo = _device.drumsTempo;
    tempo += tempoStep;
    if (tempo > tempoRange.end) tempo = tempoRange.end;

    _device.setDrumsTempo(tempo, true);
    NuxDeviceControl.instance().forceNotifyListeners();
    _setupTimer();
  }
}
