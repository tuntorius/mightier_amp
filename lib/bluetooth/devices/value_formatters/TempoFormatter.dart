import '../../../UI/pages/settings.dart';
import '../../../platform/simpleSharedPrefs.dart';
import 'ValueFormatter.dart';

class TempoFormatter extends ValueFormatter {
  InputType get inputType => InputType.SliderInput;

  static const delayTimeMstable = [
    .07972789115646259,
    .16124716553287982,
    .5031292517006802,
    .7398412698412699,
    1.1972789115646258
  ];

  double percentageToTime(double p) {
    double t = p / 25;
    int lo = t.floor();
    int hi = t.ceil();
    var hiF = t - lo;
    var loF = 1 - hiF;
    return (delayTimeMstable[lo] * loF + delayTimeMstable[hi] * hiF);
  }

  double percentageToBPM(double p) {
    return 60 / percentageToTime(p);
  }

  double bpmToPercentage(double b) {
    return timeToPercentage(60 / b);
  }

  double timeToPercentage(t) {
    return (t < delayTimeMstable[0]
        ? 0
        : t < delayTimeMstable[1]
            ? 25 *
                (t - delayTimeMstable[0]) /
                (delayTimeMstable[1] - delayTimeMstable[0])
            : t < delayTimeMstable[2]
                ? 25 *
                        (t - delayTimeMstable[1]) /
                        (delayTimeMstable[2] - delayTimeMstable[1]) +
                    25
                : t < delayTimeMstable[3]
                    ? 25 *
                            (t - delayTimeMstable[2]) /
                            (delayTimeMstable[3] - delayTimeMstable[2]) +
                        50
                    : t < delayTimeMstable[4]
                        ? 25 *
                                (t - delayTimeMstable[3]) /
                                (delayTimeMstable[4] - delayTimeMstable[3]) +
                            75
                        : 100);
  }

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
    var unit =
        SharedPrefs().getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index);
    if (unit == TimeUnit.BPM.index)
      return "${percentageToBPM(value).toStringAsFixed(2)} BPM";
    return "${percentageToTime(value).toStringAsFixed(2)} s";
  }

  @override
  double toHumanInput(double _value) {
    var unit = TimeUnit.values[
        SharedPrefs().getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index)];

    if (unit == TimeUnit.BPM) return percentageToBPM(_value);
    return percentageToTime(_value);
  }

  @override
  double fromHumanInput(double _value) {
    var unit = TimeUnit.values[
        SharedPrefs().getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index)];
    if (unit == TimeUnit.BPM) return bpmToPercentage(_value);
    return timeToPercentage(_value);
  }
}
