// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
import 'package:tinycolor2/tinycolor2.dart';

class ThickSlider extends StatefulWidget {
  final Color activeColor;
  final String label;
  final double min, max;
  final double value;
  final ValueChanged<double>? onDragStart;
  final Function(double value, bool skip)? onChanged;
  final ValueChanged<double>? onDragEnd;
  final String Function(double) labelFormatter;
  final int skipEmitting;
  final bool enabled;
  final bool handleVerticalDrag;
  final Parameter? parameter;
  final double? maxHeight;
  final bool snapToCenter;

  const ThickSlider(
      {Key? key,
      required this.activeColor,
      required this.label,
      this.min = 0,
      this.max = 1,
      required this.value,
      this.snapToCenter = false,
      this.onDragStart,
      this.onChanged,
      this.onDragEnd,
      this.handleVerticalDrag = true,
      required this.labelFormatter,
      this.skipEmitting = 3,
      this.enabled = true,
      this.parameter,
      this.maxHeight})
      : super(key: key);

  @override
  State createState() => _ThickSliderState();
}

class _ThickSliderState extends State<ThickSlider> {
  double factor = 0.5; //normalized position in 0-1
  double pos = 0;
  int lastTapDown = 0;
  int emitCounter = 0;
  double scale = 1;

  Offset startDragPos = const Offset(0, 0);
  double width = 0;
  double height = 0;

  bool ownUpdate = false;

  // Returns a number between min and max, proportional to value, which must
  // be between 0.0 and 1.0.
  double _lerp(double value) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (widget.max - widget.min) + widget.min;
  }

  //same as above, only with custom min and max
  double _lerp2(double value, double min, double max) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (max - min) + min;
  }

  // Returns a number between 0.0 and 1.0, given a value between min and max.
  double _unlerp(double value) {
    assert(value <= widget.max);
    assert(value >= widget.min);
    return widget.max > widget.min
        ? (value - widget.min) / (widget.max - widget.min)
        : 0.0;
  }

  //lerp with an optional snap to center
  double _lerpSnap(double value) {
    if (widget.snapToCenter) {
      if (value >= 0.475 && value <= 0.525) return _lerp(0.5);
    }
    return _lerp(value);
  }

  //lerp with an optional snap to center with min & max
  double _lerpSnap2(double value, double min, double max) {
    if (widget.snapToCenter) {
      if (value >= 0.475 && value <= 0.525) return _lerp2(0.5, min, max);
    }
    return _lerp2(value, min, max);
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
    if (posAbs > height * 2) scale = 0.5;
    if (posAbs > height * 3) scale = 0.25;
    if (posAbs > height * 4.5) scale = 0.125;
    if (posAbs > height * 6) scale = 0.0625;
    if (!widget.enabled) return;

    addPercentage(delta.dx * scale, width);
    emitCounter++;

    bool skip = emitCounter % widget.skipEmitting != 0;
    widget.onChanged?.call(_lerpSnap(factor), skip);
    ownUpdate = true;
  }

  void dragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    scale = 1;
    //call the last factor value here
    widget.onChanged?.call(_lerpSnap(factor), false);
    widget.onDragEnd?.call(_lerpSnap(factor));
    ownUpdate = true;
    SemanticsService.announce(
        widget.labelFormatter(_lerpSnap(factor)), TextDirection.ltr);
  }

  void manualValueEnter() {
    String dialogValue = widget.value.toStringAsFixed(2);
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
            if (min > max) {
              var tmp = max;
              max = min;
              min = tmp;
            }
          }

          if (val < min || val > max) return false;
          return true;
        },
        validationErrorMessage: "Value not valid",
        confirmColor: Theme.of(context).hintColor,
        onConfirm: (value) {
          var val = double.parse(value);

          if (widget.parameter != null) {
            //unscale value back
            val = widget.parameter!.fromHumanInput(val);
          }
          factor = _unlerp(val);
          widget.onDragStart?.call(widget.value);
          widget.onChanged?.call(val, false);
          widget.onDragEnd?.call(val);
          ownUpdate = true;
        });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 50),
      child: Semantics(
        slider: true,
        label: widget.label,
        value: widget.labelFormatter(_lerpSnap(factor)),
        enabled: widget.enabled,
        excludeSemantics: true,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          width = constraints.maxWidth - 1;
          height = constraints.maxHeight;

          if (!ownUpdate) {
            factor = _unlerp(widget.value);
          }
          ownUpdate = false;
          pos = factor * width;

          return GestureDetector(
            dragStartBehavior: DragStartBehavior.start,
            onDoubleTap: manualValueEnter,
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
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: height * 0.75,
                    color: widget.enabled
                        ? TinyColor.fromColor(widget.activeColor)
                            .darken(15)
                            .color
                        : Colors.grey[800],
                    width: max(factor * width, 0),
                  ),
                  Positioned(
                      left: _lerpSnap2(factor, 10, width - 10) - 10,
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
                            widget.labelFormatter(_lerpSnap(factor)),
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
      ),
    );
  }
}
