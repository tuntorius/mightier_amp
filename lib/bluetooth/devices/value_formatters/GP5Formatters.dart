// This code is licensed under MIT license (see LICENSE.md for details)

import 'SwitchFormatters.dart';
import 'ValueFormatter.dart';

//Value formatters for Valeton GP5 devices
//The GP5 sends parameter values as float32, the same values that are
//stored in the parameter (0-100, Hz, ms, etc)

class GP5FloatFormatter extends ValueFormatter {
  final double minVal;
  final double maxVal;
  final int decimals;
  final String suffix;
  GP5FloatFormatter(this.minVal, this.maxVal,
      {this.decimals = 0, this.suffix = ""});

  @override
  InputType get inputType => InputType.SliderInput;

  @override
  int get min => minVal.floor();
  @override
  int get max => maxVal.ceil();

  @override
  int valueToMidi7Bit(double value) {
    final v = ((value - minVal) / (maxVal - minVal)) * 127;
    return v.round().clamp(0, 127);
  }

  @override
  double midi7BitToValue(int midi7bit) {
    return minVal + (midi7bit / 127.0) * (maxVal - minVal);
  }

  @override
  String toLabel(double value) {
    return decimals > 0
        ? "${value.toStringAsFixed(decimals)}$suffix"
        : "${value.round()}$suffix";
  }
}

class GP5SwitchFormatter extends SwitchFormatter {
  final String _title;
  final List<String> _labels;

  GP5SwitchFormatter(this._title, this._labels);

  @override
  String get labelTitle => _title;

  @override
  List<String> get labelValues => _labels;

  @override
  List<int> get midiValues => [0, 1];

  @override
  String toLabel(double value) {
    var index = value.round();
    if (index >= 0 && index < _labels.length) return _labels[index];
    return _labels.last;
  }
}