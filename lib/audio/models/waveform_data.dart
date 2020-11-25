// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class WaveformData {
  int maxValue;
  List<int> data;
  WaveformData({
    this.maxValue,
    this.data,
  });

  Path _overallPath;
  Path _cachedPath;
  int _oldFromFrame = -1, _oldToFrame = -1;
  bool _needsUpdate = false;

  bool _ready;
  bool _initialized = false;

  bool get needsUpdate => _needsUpdate;
  bool get ready => _ready;
  bool get initialized => _initialized;

  void setUpdate() {
    _needsUpdate = true;
    _initialized = true;
  }

  void setReady() {
    _ready = true;
  }

  // get the frame position at a specific percent of the waveform. Can use a 0-1 or 0-100 range.
  int frameIdxFromPercent(double percent) {
    if (percent == null) {
      return 0;
    }

    // if the scale is 0-1.0
    if (percent < 0.0) {
      percent = 0.0;
    } else if (percent > 100.0) {
      percent = 100.0;
    }

    if (percent > 0.0 && percent < 1.0) {
      return (data.length.toDouble() * percent).floor();
    }

    int idx = (data.length.toDouble() * (percent / 100)).floor();
    //is this safety or what
    // final maxIdx = (data.length.toDouble() * 0.98).floor();
    // if (idx > maxIdx) {
    //   idx = maxIdx;
    // }
    return idx;
  }

  //calculate X coordinate of line within the chosen samples
  double verticalLine(Size size, int sample, int fromFrame, int toFrame) {
    if (sample < 0) sample = 0;
    if (sample > data.length - 1) sample = data.length - 1;

    double percentage = (sample - fromFrame) / (toFrame - fromFrame);
    return size.width * percentage;
  }

  Path path(Size size, {int toFrame, int fromFrame = 0}) {
    if (toFrame == _oldToFrame && fromFrame == _oldFromFrame && !_needsUpdate)
      return _cachedPath;

    _needsUpdate = false;

    if (fromFrame < 0) fromFrame = 0;
    if (toFrame == null) toFrame = data.length - 1;
    if (toFrame < fromFrame + 50) toFrame = fromFrame + 50;
    if (toFrame > data.length - 1) toFrame = data.length - 1;

    if (toFrame == data.length - 1 && fromFrame == 0) {
      _oldFromFrame = fromFrame;
      _oldToFrame = toFrame;
      _cachedPath = _path(data, size);
      return _cachedPath;
    }

    // buffer so we can't start too far in the waveform, 90% max
    if (fromFrame > (data.length * 0.98).floor()) {
      debugPrint("from frame is too far at $fromFrame");
      fromFrame = ((data.length) * 0.98).floor();
    }

    _oldFromFrame = fromFrame;
    _oldToFrame = toFrame;

    _cachedPath = _path(data.sublist(fromFrame, toFrame), size);
    return _cachedPath;
  }

  Path _path(List<int> samples, Size size) {
    final upsample = 2;

    List<double> points = List<double>(size.width.ceil() * upsample + 1);
    points.fillRange(0, size.width.ceil() * upsample + 1, 0);
    final middle = size.height;
    //final int filter = (samples.length / size.width).floor();
    var i = 0.0;

    final t = size.width * upsample / samples.length;

    final path = Path();
    path.moveTo(0, middle);

    for (var _i = 0, _len = samples.length; _i < _len; _i += 1) {
      var d = samples[_i]; // / maxValue;
      var pos = (t * i).round();
      points[pos] += d.toDouble();

      i += 1;
    }

    var vmax = points.reduce(max);
    for (var _i = 0; _i < size.width * upsample; _i++) {
      path.lineTo(_i / upsample, middle - points[_i] / vmax * middle);
    }

    //maxPoints.forEach((o) => path.lineTo(o.dx, o.dy));
    // back to zero
    path.lineTo(size.width, middle);
    // draw the minimums backwards so we can fill the shape when done.
    //minPoints.reversed
    //    .forEach((o) => path.lineTo(o.dx, middle - (middle - o.dy)));

    //path.close();
    return path;
  }

  Path overallPath(Size size) {
    //TODO: have a separate flag as this can cause shared usage problems
    if (!_needsUpdate) return _overallPath;
    _overallPath = _path(data, size);
    return _overallPath;
  }
}
