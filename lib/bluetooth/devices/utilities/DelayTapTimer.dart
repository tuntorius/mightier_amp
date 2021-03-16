class DelayTapTimer {
  final timeout = 1500;
  List<DateTime> timeArray = <DateTime>[];

  addClickTime() {
    timeArray.add(DateTime.now());
    while (timeArray.length > 3) timeArray.removeAt(0);
  }

  calculate() {
    if (timeArray.length < 2) return false;
    var length = timeArray.length;
    var current = timeArray[length - 1].millisecondsSinceEpoch;
    var last = timeArray[length - 2].millisecondsSinceEpoch;
    //check for timeout and clear if it is

    if (length > 2 && (current - last >= this.timeout)) {
      while (timeArray.length > 1) timeArray.removeAt(0);

      return false;
    }

    if (length == 2) return current - last;

    var first = timeArray[length - 3].millisecondsSinceEpoch;
    return (current - first) / 2;
  }
}
