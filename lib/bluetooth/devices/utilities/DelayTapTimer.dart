class DelayTapTimer {
  final timeout = 1500;
  final maxSamples = 20;
  List<DateTime> timeArray = <DateTime>[];

  addClickTime() {
    var now = DateTime.now();

    if (timeArray.isNotEmpty &&
        now.difference(timeArray.last).inMilliseconds > timeout) {
      timeArray.clear();
    }

    timeArray.add(now);

    while (timeArray.length > maxSamples) {
      timeArray.removeAt(0);
    }
  }

  calculate() {
    if (timeArray.length < 2) return false;

    int sum = 0;
    //get the sum of all differences and calculate average
    for (int i = 0; i < timeArray.length - 1; i++) {
      sum += timeArray[i + 1].difference(timeArray[i]).inMilliseconds;
    }

    return sum / (timeArray.length - 1);
  }
}
