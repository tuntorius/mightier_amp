import 'package:mighty_plug_manager/bluetooth/devices/value_formatters/FrequencyFormatter.dart';
import 'package:mighty_plug_manager/bluetooth/devices/value_formatters/SwitchFormatters.dart';

import 'TempoFormatter.dart';
import 'DecibelFormatter.dart';

enum InputType { SliderInput, SwitchInput }

class ValueFormatters {
  static PercentageFormatter percentage = PercentageFormatter();
  static PercentageFormatterMPPro percentageMPPro = PercentageFormatterMPPro();
  static DecibelFormatterMP2 decibelMP2 = DecibelFormatterMP2();
  static DecibelFormatterMPPro decibelMPPro = DecibelFormatterMPPro();
  static DecibelFormatterEQ decibelEQ = DecibelFormatterEQ();
  static TempoFormatter tempo = TempoFormatter();
  static TempoFormatterPro tempoPro = TempoFormatterPro();
  static TempoFormatterProMod tempoProMod = TempoFormatterProMod();
  static TempoFormatterProAnalog tempoProAnalog = TempoFormatterProAnalog();
  static TempoFormatterProTapeEcho tempoProTapeEcho =
      TempoFormatterProTapeEcho();
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
  static TouchWahModeFormatter touchWahFormatter = TouchWahModeFormatter();
  static TouchWahModeFormatterLiteMk2 touchWahFormatterLiteMk2 =
      TouchWahModeFormatterLiteMk2();
  static TouchWahDirectionFormatterPro touchWahDirectionFormatterPro =
      TouchWahDirectionFormatterPro();

  // ── mighty-nam Extra FX ──────────────────────────────────────────────────
  static NamFxPercentageFormatter namFxPercentage = NamFxPercentageFormatter();
  static NamFxSemitoneFormatter namFxSemitone = NamFxSemitoneFormatter();
}

// ── mighty-nam Extra FX formatters ────────────────────────────────────────────

/// General 0–100 percentage formatter for mighty-nam Extra FX parameters.
///
/// The firmware payload is a raw 0–100 integer; [valueToMidi7Bit] and
/// [midi7BitToValue] are identity operations (no 0–127 rescaling).
class NamFxPercentageFormatter extends ValueFormatter {
  NamFxPercentageFormatter();

  @override
  InputType get inputType => InputType.SliderInput;

  /// Raw payload value: 0–100.
  @override
  int get max => 100;

  /// Identity — firmware stores 0–100 directly.
  @override
  int valueToMidi7Bit(double value) => value.round();

  @override
  double midi7BitToValue(int midi7bit) => midi7bit.toDouble();

  @override
  String toLabel(double value) => value.round().toString() + ' %';
}

/// Semitone formatter for the mighty-nam Pitch effect.
///
/// The firmware stores the pitch shift as an unsigned 0–24 integer where
/// 12 = 0 semitones (centre).  The app works in that same 0–24 space; the
/// label converts it back to a signed ±12 display value.
class NamFxSemitoneFormatter extends ValueFormatter {
  NamFxSemitoneFormatter();

  @override
  InputType get inputType => InputType.SliderInput;

  /// Firmware range: 0–24 (centre = 12 → 0 semitones).
  @override
  int get max => 24;

  /// Identity — firmware stores 0–24 directly.
  @override
  int valueToMidi7Bit(double value) => value.round();

  @override
  double midi7BitToValue(int midi7bit) => midi7bit.toDouble();

  @override
  String toLabel(double value) {
    final semitones = value.round() - 12;
    final sign = semitones > 0 ? '+' : '';
    return sign + semitones.toString() + ' st';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

abstract class ValueFormatter {
  InputType get inputType;
  int get min => 0;
  int get max => 100;

  int valueToMidi7Bit(double value);
  double midi7BitToValue(int midi7bit);
  String toLabel(double value);
  double toHumanInput(double value) {
    return value;
  }

  double fromHumanInput(double value) {
    return value;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Consolidated Percentage Formatters
// ─────────────────────────────────────────────────────────────────────────────

class PercentageFormatter extends ValueFormatter {
  @override
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
    return value.round().toString() + "%";
  }
}

class PercentageFormatterMPPro extends ValueFormatter {
  @override
  InputType get inputType => InputType.SliderInput;

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
    return value.round().toString() + "%";
  }
}