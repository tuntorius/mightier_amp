import '../../../UI/pages/settings.dart';
import '../../../platform/simpleSharedPrefs.dart';
import 'ValueFormatter.dart';

class TempoFormatter extends ValueFormatter {
  @override
  InputType get inputType => InputType.SliderInput;

  static const delayTimeMstable = [
    .07972789115646259,
    .16124716553287982,
    .5031292517006802,
    .7398412698412699,
    1.1972789115646258
  ];

  List<double> get delayMsTable => delayTimeMstable;

  double percentageToTime(double p) {
    double t = p / 25;
    int lo = t.floor();
    int hi = t.ceil();
    var hiF = t - lo;
    var loF = 1 - hiF;
    return (delayMsTable[lo] * loF + delayMsTable[hi] * hiF);
  }

  double percentageToBPM(double p) {
    return 60 / percentageToTime(p);
  }

  double bpmToPercentage(double b) {
    return timeToPercentage(60 / b);
  }

  double timeToPercentage(t) {
    return (t < delayMsTable[0]
        ? 0
        : t < delayMsTable[1]
            ? 25 * (t - delayMsTable[0]) / (delayMsTable[1] - delayMsTable[0])
            : t < delayMsTable[2]
                ? 25 *
                        (t - delayMsTable[1]) /
                        (delayMsTable[2] - delayMsTable[1]) +
                    25
                : t < delayMsTable[3]
                    ? 25 *
                            (t - delayMsTable[2]) /
                            (delayMsTable[3] - delayMsTable[2]) +
                        50
                    : t < delayMsTable[4]
                        ? 25 *
                                (t - delayMsTable[3]) /
                                (delayMsTable[4] - delayMsTable[3]) +
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
    if (unit == TimeUnit.BPM.index) {
      return "${percentageToBPM(value).toStringAsFixed(2)} BPM";
    }
    return "${percentageToTime(value).toStringAsFixed(2)} s";
  }

  @override
  double toHumanInput(double value) {
    var unit = TimeUnit.values[
        SharedPrefs().getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index)];

    if (unit == TimeUnit.BPM) return percentageToBPM(value);
    return percentageToTime(value);
  }

  @override
  double fromHumanInput(double value) {
    var unit = TimeUnit.values[
        SharedPrefs().getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index)];
    if (unit == TimeUnit.BPM) return bpmToPercentage(value);
    return timeToPercentage(value);
  }
}

//Tempo formatter for digital and Pan Delay
class TempoFormatterPro extends TempoFormatter {
  static const delayTimeMstable = [
    .07972789115646259,
    .16124716553287982,
    .5031292517006802,
    .7398412698412699,
    .9902292
  ];

  @override
  List<double> get delayMsTable => delayTimeMstable;

  @override
  int valueToMidi7Bit(double value) {
    return value.round();
  }

  @override
  double midi7BitToValue(int midi7bit) {
    return midi7bit.toDouble();
  }
}

class TempoFormatterProMod extends TempoFormatterPro {
  static const delayTimeMstable = [
    0.01825,
    0.198292,
    0.5982083,
    1.0399583,
    1.1918125
  ];

  @override
  List<double> get delayMsTable => delayTimeMstable;
}

class TempoFormatterProAnalog extends TempoFormatterPro {
  static const delayTimeMstable = [
    0.0402708333333333,
    0.1602916666666667,
    0.2803125,
    0.3307291666666667,
    0.4007708333333333
  ];

  @override
  List<double> get delayMsTable => delayTimeMstable;
}

class TempoFormatterProTapeEcho extends TempoFormatterPro {
  static const delayTimeMstable = [
    0.0533125,
    0.1883125,
    0.3980416666666667,
    0.4881458333333333,
    0.5459375
  ];

  @override
  List<double> get delayMsTable => delayTimeMstable;
}
