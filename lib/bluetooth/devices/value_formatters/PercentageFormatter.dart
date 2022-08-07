import 'ValueFormatter.dart';

class PercentageFormatter extends ValueFormatter {
  InputType get inputType => InputType.SliderInput;

  @override
  int valueToMidi7Bit(double value) {
    return (value / 100 * 127).floor();
  }

  @override
  double midi7BitToValue(int midi7bit) {
    return (midi7bit / 127.0) * 100;
  }

  @override
  String toLabel(double value) {
    return "${value.round()} %";
  }
}
