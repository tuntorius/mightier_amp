// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/settings.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:tinycolor2/tinycolor2.dart';

class ThickSlider extends StatefulWidget {
  final Color activeColor;
  final String label;
  final double min, max;
  final double value;
  final ValueChanged<double>? onDragStart;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onDragEnd;
  final String Function(double) labelFormatter;
  final int skipEmitting;
  final bool enabled;
  final bool handleVerticalDrag;
  final bool tempoValue;

  const ThickSlider(
      {Key? key,
      required this.activeColor,
      required this.label,
      this.min = 0,
      this.max = 1,
      required this.value,
      this.onDragStart,
      this.onChanged,
      this.onDragEnd,
      this.handleVerticalDrag = true,
      required this.labelFormatter,
      this.skipEmitting = 3,
      this.enabled = true,
      this.tempoValue = false})
      : super(key: key);

  @override
  _ThickSliderState createState() => _ThickSliderState();
}

class _ThickSliderState extends State<ThickSlider> {
  double factor = 0.5; //normalized position in 0-1
  double pos = 0;
  int lastTapDown = 0;
  int emitCounter = 0;
  double scale = 1;

  Offset startDragPos = Offset(0, 0);
  double width = 0;
  double height = 0;

  // Returns a number between min and max, proportional to value, which must
  // be between 0.0 and 1.0.
  double _lerp(double value) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (widget.max - widget.min) + widget.min;
  }

  //same as above, only with custom min and max
  double _lerp2(double value, double _min, double _max) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (_max - _min) + _min;
  }

  // Returns a number between 0.0 and 1.0, given a value between min and max.
  double _unlerp(double value) {
    assert(value <= widget.max);
    assert(value >= widget.min);
    return widget.max > widget.min
        ? (value - widget.min) / (widget.max - widget.min)
        : 0.0;
  }

  @override
  void initState() {
    super.initState();

    //range check
    assert(widget.min < widget.max);
    assert(widget.value >= widget.min && widget.value <= widget.max);
    assert(widget.skipEmitting > 0);
    //normalize value to 0-1
    factor = _unlerp(widget.value);
  }

  void setPercentage(value, width) {
    pos = max(min(value, width), 0);
    factor = pos / width;
  }

  void addPercentage(value, width) {
    pos += value;
    pos = max(min(pos, width), 0);
    factor = pos / width;
  }

  void dragStart(DragStartDetails details) {
    startDragPos = details.localPosition;
    widget.onDragStart?.call(widget.value);
  }

  void dragUpdate(DragUpdateDetails details) {
    Offset delta = details.localPosition - startDragPos;
    startDragPos = details.localPosition;

    scale = 1;
    var posAbs = (details.localPosition.dy - height / 2.0).abs();
    if (posAbs > height) scale = 0.5;
    if (posAbs > height * 2.5) scale = 0.25;
    if (posAbs > height * 4) scale = 0.125;
    if (posAbs > height * 5.5) scale = 0.0625;
    if (!widget.enabled) return;
    addPercentage(delta.dx * scale, width);
    emitCounter++;
    if (emitCounter % widget.skipEmitting == 0) {
      widget.onChanged?.call(_lerp(factor));
    }
  }

  void dragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    scale = 1;
    //call the last factor value here
    widget.onChanged?.call(_lerp(factor));
    widget.onDragEnd?.call(_lerp(factor));
  }

  void manualValueEnter() {
    var unit = TimeUnit.values[
        SharedPrefs().getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index)];

    String dialogValue = _lerp(factor).toStringAsFixed(2);
    if (widget.tempoValue) {
      if (unit == TimeUnit.BPM)
        dialogValue =
            Parameter.percentageToBPM(_lerp(factor)).toStringAsFixed(2);
      else if (unit == TimeUnit.Seconds)
        dialogValue =
            Parameter.percentageToTime(_lerp(factor)).toStringAsFixed(2);
    }

    AlertDialogs.showInputDialog(context,
        title: "Enter Value",
        description: "Enter new value for ${widget.label}",
        cancelButton: "Cancel",
        confirmButton: "Set",
        selectAll: true,
        keyboardType: TextInputType.number,
        value: dialogValue,
        validation: (value) {
          double? val = double.tryParse(value);
          if (val == null) return false;

          double min = 0, max = 0;

          //Check for range
          if (!widget.tempoValue) {
            min = widget.min;
            max = widget.max;
          } else {
            if (unit == TimeUnit.BPM) {
              min = Parameter.percentageToBPM(100);
              max = Parameter.percentageToBPM(0);
            } else if (unit == TimeUnit.Seconds) {
              min = Parameter.percentageToTime(0);
              max = Parameter.percentageToTime(100);
            }
          }

          if (val < min || val > max) return false;
          return true;
        },
        validationErrorMessage: "Value not valid",
        confirmColor: Colors.blue,
        onConfirm: (value) {
          var val = double.parse(value);

          if (widget.tempoValue) {
            //unscale value back
            if (unit == TimeUnit.BPM)
              val = Parameter.bpmToPercentage(val);
            else if (unit == TimeUnit.Seconds)
              val = Parameter.timeToPercentage(val);
          }

          widget.onDragStart?.call(widget.value);
          widget.onChanged?.call(val);
          widget.onDragEnd?.call(val);
        });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 50),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        width = constraints.maxWidth - 1;
        height = constraints.maxHeight;
        factor = _unlerp(widget.value);
        pos = factor * width;

        return GestureDetector(
          dragStartBehavior: DragStartBehavior.start,

          onDoubleTap: manualValueEnter,
          //onLongPress: manualValueEnter,
          onTapDown: (details) {
            if (!widget.enabled) return;

            //double tap
            // var now = DateTime.now().millisecondsSinceEpoch;
            // if (now - lastTapDown < 300) {
            //   setPercentage(details.localPosition.dx, width);
            //   widget.onChanged?.call(_lerp(factor));
            // }
            // lastTapDown = now;
          },
          onVerticalDragStart: widget.handleVerticalDrag ? dragStart : null,
          onVerticalDragUpdate: widget.handleVerticalDrag ? dragUpdate : null,
          onVerticalDragEnd: widget.handleVerticalDrag ? dragEnd : null,
          onHorizontalDragStart: dragStart,
          onHorizontalDragUpdate: dragUpdate,
          onHorizontalDragEnd: dragEnd,
          child: Container(
            color: Colors.transparent,
            height: height,
            child: Stack(
              children: [
                Container(
                  height: height * 0.75,
                  color: widget.enabled
                      ? TinyColor(widget.activeColor).darken(15).color
                      : Colors.grey[800],
                  width: max(factor * width, 0),
                ),
                Positioned(
                    left: _lerp2(factor, 10, width - 10) - 10,
                    width: 20,
                    height: height * 0.9,
                    child: Container(
                        color: widget.enabled
                            ? widget.activeColor
                            : Colors.grey[700],
                        width: 20)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                              color: widget.enabled
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontSize: 20),
                        ),
                        Text(
                          widget.labelFormatter(_lerp(factor)),
                          style: TextStyle(
                              color: widget.enabled
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontSize: 20),
                        )
                      ]),
                ),
                Center(child: Text(scale < 1 ? "x$scale" : ""))
              ],
              alignment: Alignment.centerLeft,
            ),
          ),
        );
      }),
    );
  }
}
