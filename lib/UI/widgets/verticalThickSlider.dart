// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
import 'package:tinycolor2/tinycolor2.dart';

class VerticalThickSlider extends StatefulWidget {
  final Color activeColor;
  final String label;
  final double min, max;
  final double value;
  final double width;
  final ValueChanged<double>? onDragStart;
  final Function(double value, bool skip)? onChanged;
  final ValueChanged<double>? onDragEnd;
  final String Function(double) labelFormatter;
  final int skipEmitting;
  final bool enabled;
  final bool handleHorizontalDrag;
  final Parameter? parameter;

  const VerticalThickSlider(
      {Key? key,
      required this.activeColor,
      required this.label,
      this.min = 0,
      this.max = 1,
      this.width = 50,
      required this.value,
      this.onDragStart,
      this.onChanged,
      this.onDragEnd,
      this.handleHorizontalDrag = true,
      required this.labelFormatter,
      this.skipEmitting = 3,
      this.enabled = true,
      this.parameter})
      : super(key: key);

  @override
  State createState() => _VerticalThickSliderState();
}

class _VerticalThickSliderState extends State<VerticalThickSlider> {
  double factor = 0.5; //normalized position in 0-1
  double pos = 0;
  int lastTapDown = 0;
  int emitCounter = 0;
  double scale = 1;

  Offset startDragPos = const Offset(0, 0);
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
    assert(widget.skipEmitting >= 0);
    //normalize value to 0-1
    factor = _unlerp(widget.value);
  }

  void setPercentage(value, height) {
    pos = max(min(value, height), 0);
    factor = pos / height;
  }

  void addPercentage(value, height) {
    pos += value;
    pos = max(min(pos, height), 0);
    factor = pos / height;
  }

  void dragStart(DragStartDetails details) {
    startDragPos = details.localPosition;
    widget.onDragStart?.call(widget.value);
  }

  void dragUpdate(DragUpdateDetails details) {
    Offset delta = details.localPosition - startDragPos;
    startDragPos = details.localPosition;

    scale = 1;
    var posAbs = (details.localPosition.dx - width / 2.0).abs();
    if (posAbs > width) scale = 0.5;
    if (posAbs > width * 2.5) scale = 0.25;
    if (posAbs > width * 4) scale = 0.125;
    if (posAbs > width * 5.5) scale = 0.0625;
    if (!widget.enabled) return;
    addPercentage(-delta.dy * scale, height);
    emitCounter++;

    bool skip =
        widget.skipEmitting == 0 || emitCounter % widget.skipEmitting != 0;

    widget.onChanged?.call(_lerp(factor), skip);
  }

  void dragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    scale = 1;
    //call the last factor value here
    widget.onChanged?.call(_lerp(factor), false);
    widget.onDragEnd?.call(_lerp(factor));
  }

  void manualValueEnter() {
    String dialogValue = _lerp(factor).toStringAsFixed(2);
    if (widget.parameter != null) {
      dialogValue = widget.parameter!.toHumanInput().toStringAsFixed(2);
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
          if (widget.parameter == null) {
            min = widget.min;
            max = widget.max;
          } else {
            min = widget.parameter!.formatter.toHumanInput(widget.min);
            max = widget.parameter!.formatter.toHumanInput(widget.max);
          }

          if (val < min || val > max) return false;
          return true;
        },
        validationErrorMessage: "Value not valid",
        confirmColor: Colors.blue,
        onConfirm: (value) {
          var val = double.parse(value);

          if (widget.parameter != null) {
            //unscale value back
            val = widget.parameter!.fromHumanInput(val);
          }

          widget.onDragStart?.call(widget.value);
          widget.onChanged?.call(val, false);
          widget.onDragEnd?.call(val);
        });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.width),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        width = constraints.maxWidth - 1;
        height = constraints.maxHeight;
        factor = _unlerp(widget.value);
        pos = factor * height;

        return GestureDetector(
          dragStartBehavior: DragStartBehavior.start,
          onDoubleTap: manualValueEnter,
          onTapDown: (details) {
            if (!widget.enabled) return;
          },
          onHorizontalDragStart: widget.handleHorizontalDrag ? dragStart : null,
          onHorizontalDragUpdate:
              widget.handleHorizontalDrag ? dragUpdate : null,
          onHorizontalDragEnd: widget.handleHorizontalDrag ? dragEnd : null,
          onVerticalDragStart: dragStart,
          onVerticalDragUpdate: dragUpdate,
          onVerticalDragEnd: dragEnd,
          child: Container(
            color: Colors.transparent,
            height: height,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: max(factor * height, 0),
                  color: widget.enabled
                      ? TinyColor(widget.activeColor).darken(15).color
                      : Colors.grey[800],
                  width: width * 0.5,
                ),
                Positioned(
                    bottom: _lerp2(factor, 10, height - 10) - 10,
                    height: 20,
                    width: width * 0.9,
                    child: Container(
                        color: widget.enabled
                            ? widget.activeColor
                            : Colors.grey[700],
                        height: 20)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.labelFormatter(_lerp(factor)),
                          style: TextStyle(
                              color: widget.enabled
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontSize: 20),
                        ),
                        Text(
                          widget.label,
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
            ),
          ),
        );
      }),
    );
  }
}
