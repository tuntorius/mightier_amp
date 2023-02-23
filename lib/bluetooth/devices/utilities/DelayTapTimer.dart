class DelayTapTimer {
  DelayTapTimer._();

  static const _timeout = 1800;
  static const _maxSamples = 20;
  static List<DateTime> timeArray = <DateTime>[];

  static addClickTime() {
    var now = DateTime.now();

    if (timeArray.isNotEmpty &&
        now.difference(timeArray.last).inMilliseconds > _timeout) {
      timeArray.clear();
    }

    timeArray.add(now);

    while (timeArray.length > _maxSamples) {
      timeArray.removeAt(0);
    }
  }

  static calculate() {
    if (timeArray.length < 2) return false;

    int sum = 0;
    //get the sum of all differences and calculate average
    for (int i = 0; i < timeArray.length - 1; i++) {
      sum += timeArray[i + 1].difference(timeArray[i]).inMilliseconds;
    }

    return sum / (timeArray.length - 1);
  }

  static calculateBpm() {
    var result = calculate();
    if (result != false) result = 60 / (result / 1000);
    return result;
  }
}
