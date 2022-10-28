import 'package:mighty_plug_manager/bluetooth/devices/value_formatters/FrequencyFormatter.dart';
import 'package:mighty_plug_manager/bluetooth/devices/value_formatters/SwitchFormatters.dart';

import 'TempoFormatter.dart';
import 'decibelFormatter.dart';
import 'PercentageFormatter.dart';

enum InputType { SliderInput, SwitchInput }

class ValueFormatters {
  static PercentageFormatter percentage = PercentageFormatter();
  static PercentageFormatterMPPro percentageMPPro = PercentageFormatterMPPro();
  static DecibelFormatterMP2 decibelMP2 = DecibelFormatterMP2();
  static DecibelFormatterMPPro decibelMPPro = DecibelFormatterMPPro();
  static DecibelFormatterEQ decibelEQ = DecibelFormatterEQ();
  static TempoFormatter tempo = TempoFormatter();
  static BrightModeFormatter brightMode = BrightModeFormatter();
  static BrightModeFormatterMPPro brightModePro = BrightModeFormatterMPPro();
  static BoostModeFormatter boostMode = BoostModeFormatter();
  static BoostModeFormatterMPPro boostModePro = BoostModeFormatterMPPro();
  static VibeModeFormatter vibeMode = VibeModeFormatter();
  static VibeModeFormatterPro vibeModePro = VibeModeFormatterPro();
  static ContourModeFormatter contourMode = ContourModeFormatter();
  static SCFModeFormatter scfMode = SCFModeFormatter();
  static LowFrequencyFormatter lowFreqFormatter = LowFrequencyFormatter();
  static HighFrequencyFormatter highFreqFormatter = HighFrequencyFormatter();
}

abstract class ValueFormatter {
  InputType get inputType;
  int get min => 0;
  int get max => 100;

  int valueToMidi7Bit(double value);
  double midi7BitToValue(int midi7bit);
  String toLabel(double value);
  double toHumanInput(double _value) {
    return _value;
  }

  double fromHumanInput(double _value) {
    return _value;
  }
}
