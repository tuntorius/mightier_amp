import 'ValueFormatter.dart';
import 'dart:math';

double log10(num x) => log(x) / ln10;

class LowFrequencyFormatter extends ValueFormatter {
  @override
  InputType get inputType => InputType.SliderInput;

  @override
  int get min => 20;

  @override
  int get max => 300;

  @override
  int valueToMidi7Bit(double value) {
    return ((value - 20) / 280 * 100).floor();
  }

  @override
  double midi7BitToValue(int midi7bit) {
    return (midi7bit / 100) * 280 + 20;
  }

  @override
  String toLabel(double value) {
    return "${value.toStringAsFixed(0)} Hz";
  }
}

class HighFrequencyFormatter extends ValueFormatter {
  @override
  InputType get inputType => InputType.SliderInput;

  @override
  int get min => 0;

  @override
  int get max => 100;

  double _valueToFreq(double value) {
    final a = log10(5e3) + (log10(2e4) - log10(5e3)) * (value / 100);
    return pow(10, a).toDouble();
  }

  double _freqToValue(double freq) {
    double a = log10(freq);

    var value = (a - log10(5e3)) / (log10(2e4) - log10(5e3));
    return value * 100;
  }

  @override
  int valueToMidi7Bit(double value) {
    return value.round();
  }

  @override
  double midi7BitToValue(int midi7bit) {
    return midi7bit.toDouble();
  }

  @override
  String toLabel(double value) {
    return "${_valueToFreq(value).toStringAsFixed(0)} Hz";
  }

  @override
  double toHumanInput(double value) {
    return _valueToFreq(value);
  }

  @override
  double fromHumanInput(double value) {
    return _freqToValue(value);
  }
}
