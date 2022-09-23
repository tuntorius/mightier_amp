import 'ValueFormatter.dart';

abstract class SwitchFormatter extends ValueFormatter {
  String get labelTitle;

  InputType get inputType => InputType.SwitchInput;

  List<String> get labelValues;
  List<int> get midiValues;

  @override
  double midi7BitToValue(int midi7bit) {
    return midi7bit.toDouble();
  }

  @override
  String toLabel(double value) {
    // TODO: implement toLabel
    throw UnimplementedError();
  }

  @override
  int valueToMidi7Bit(double value) {
    return value.round();
  }
}

class BrightModeFormatter extends SwitchFormatter {
  @override
  // TODO: implement labelTitle
  String get labelTitle => "Bright:";

  @override
  List<String> get labelValues => ["Off", "On"];

  @override
  List<int> get midiValues => [0, 127];
}

class BoostModeFormatter extends SwitchFormatter {
  @override
  // TODO: implement labelTitle
  String get labelTitle => "Boost:";

  @override
  List<String> get labelValues => ["Off", "On"];

  @override
  List<int> get midiValues => [0, 127];
}

class VibeModeFormatter extends SwitchFormatter {
  @override
  // TODO: implement labelTitle
  String get labelTitle => "Mode:";

  @override
  List<String> get labelValues => ["Vibe", "Chorus"];

  @override
  List<int> get midiValues => [0, 127];
}

class ContourModeFormatter extends SwitchFormatter {
  @override
  // TODO: implement labelTitle
  String get labelTitle => "Contour:";

  @override
  List<String> get labelValues => ["Vintage", "Off", "Modern"];

  @override
  List<int> get midiValues => [0, 64, 127];
}

class SCFModeFormatter extends SwitchFormatter {
  @override
  // TODO: implement labelTitle
  String get labelTitle => "SCF";

  @override
  List<String> get labelValues => ["Chorus", "P.M.", "Flanger"];

  @override
  List<int> get midiValues => [0, 64, 127];
}
