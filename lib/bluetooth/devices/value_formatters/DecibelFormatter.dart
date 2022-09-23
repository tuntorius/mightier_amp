import 'ValueFormatter.dart';

class DecibelFormatterMP2 extends ValueFormatter {
  InputType get inputType => InputType.SliderInput;

  @override
  int get min => -6;

  @override
  int get max => 6;

  @override
  int valueToMidi7Bit(double value) {
    return ((value + 6) / 12 * 127).floor();
  }

  @override
  double midi7BitToValue(int midi7bit) {
    return (midi7bit / 127) * 12 - 6;
  }

  @override
  String toLabel(double value) {
    return "${value.toStringAsFixed(1)} db";
  }
}

class DecibelFormatterMPPro extends ValueFormatter {
  InputType get inputType => InputType.SliderInput;

  @override
  int get min => -12;

  @override
  int get max => 12;

  @override
  int valueToMidi7Bit(double value) {
    return ((value + 12) / 24 * 127).floor();
  }

  @override
  double midi7BitToValue(int midi7bit) {
    return (midi7bit / 127) * 24 - 12;
  }

  @override
  String toLabel(double value) {
    return "${value.toStringAsFixed(1)} db";
  }
}

class DecibelFormatterEQ extends ValueFormatter {
  InputType get inputType => InputType.SliderInput;

  @override
  int get min => -15;

  @override
  int get max => 15;

  @override
  int valueToMidi7Bit(double value) {
    return ((value + 15) / 30 * 127).floor();
  }

  @override
  double midi7BitToValue(int midi7bit) {
    return (midi7bit / 127) * 30 - 15;
  }

  @override
  String toLabel(double value) {
    return "${value.toStringAsFixed(1)} db";
  }
}
