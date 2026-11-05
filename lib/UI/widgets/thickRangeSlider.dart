// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:tinycolor2/tinycolor2.dart';

class SliderRangeValues {
  double start;
  double end;
  SliderRangeValues(this.start, this.end);

  SliderRangeValues operator *(double value) {
    return SliderRangeValues(start * value, end * value);
  }
}

class ThickRangeSlider extends StatefulWidget {
  final Color activeColor;
  final String label;
  final double min, max;
  final SliderRangeValues values;
  final ValueChanged<SliderRangeValues>? onDragStart;
  final Function(SliderRangeValues value, bool skip)? onChanged;
  final ValueChanged<SliderRangeValues>? onDragEnd;
  final String Function(SliderRangeValues) labelFormatter;
  final int skipEmitting;
  final bool enabled;
  final bool handleVerticalDrag;
  final double? maxHeight;

  const ThickRangeSlider(
      {Key? key,
      required this.activeColor,
      required this.label,
      this.min = 0,
      this.max = 1,
      required this.values,
      this.onDragStart,
      this.onChanged,
      this.onDragEnd,
      this.handleVerticalDrag = true,
      required this.labelFormatter,
      this.skipEmitting = 3,
      this.enabled = true,
      this.maxHeight})
      : super(key: key);

  @override
  State createState() => _ThickRangeSliderState();
}

class _ThickRangeSliderState extends State<ThickRangeSlider> {
  SliderRangeValues factor =
      SliderRangeValues(0.2, 0.8); 
  SliderRangeValues pos = SliderRangeValues(0, 1);
  int lastTapDown = 0;
  int emitCounter = 0;
  double scale = 1;

  Offset startDragPos = const Offset(0, 0);
  double width = 0;
  double height = 0;

  int handleIndex = 0;

  double _lerpSingle(double value) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (widget.max - widget.min) + widget.min;
  }

  SliderRangeValues _lerp(SliderRangeValues values) {
    return SliderRangeValues(
        _lerpSingle(values.start), _lerpSingle(values.end));
  }

  double _lerp2Single(double value, double min, double max) {
    assert(value >= 0.0);
    assert(value <= 1.0);
    return value * (max - min) + min;
  }

  SliderRangeValues _lerp2(SliderRangeValues values, double min, double max) {
    return SliderRangeValues(_lerp2Single(values.start, min, max),
        _lerp2Single(values.end, min, max));
  }

  double _unlerpSingle(double value) {
    assert(value <= widget.max);
    assert(value >= widget.min);
    return widget.max > widget.min
        ? (value - widget.min) / (widget.max - widget.min)
        : 0.0;
  }

  SliderRangeValues _unlerp(SliderRangeValues value) {
    return SliderRangeValues(
        _unlerpSingle(value.start), _unlerpSingle(value.end));
  }

  @override
  void initState() {
    super.initState();

    assert(widget.min < widget.max);
    assert(
        widget.values.start >= widget.min && widget.values.start <= widget.max);
    assert(widget.values.end >= widget.min && widget.values.end <= widget.max);
    assert(widget.values.start <= widget.values.end);
    assert(widget.skipEmitting > 0);
    factor = _unlerp(widget.values);
  }

  void addPercentage(value, width, int index) {
    if (index != 1) {
      pos.start += value;
      pos.start = max(min(pos.start, pos.end), 0);
      factor.start = pos.start / width;
    }
    if (index != 0) {
      pos.end += value;
      pos.end = max(min(pos.end, width), pos.start);
      factor.end = pos.end / width;
    }
  }

  void dragStart(DragStartDetails details) {
    startDragPos = details.localPosition;
    widget.onDragStart?.call(widget.values);

    var startFactor = startDragPos.dx / width;
    var midPoint = factor.start + (factor.end - factor.start) / 2;
    handleIndex = startFactor < midPoint ? 0 : 1;
    return;
  }

  void dragUpdate(DragUpdateDetails details) {
    Offset delta = details.localPosition - startDragPos;
    startDragPos = details.localPosition;

    scale = 1;
    var posAbs = (details.localPosition.dy - height / 2.0).abs();
    if (posAbs > height * 1.5) scale = 0.5;
    if (posAbs > height * 2.5) scale = 0.25;
    if (posAbs > height * 4) scale = 0.125;
    if (posAbs > height * 5.5) scale = 0.0625;
    if (!widget.enabled) return;
    addPercentage(delta.dx * scale, width, handleIndex);
    emitCounter++;
    bool skip = emitCounter % widget.skipEmitting != 0;
    widget.onChanged?.call(_lerp(factor), skip);
  }

  void dragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    scale = 1;
    widget.onChanged?.call(_lerp(factor), false);
    widget.onDragEnd?.call(_lerp(factor));
    SemanticsService.announce(
        widget.labelFormatter(_lerp(factor)), TextDirection.ltr);
  }

  void manualValueEnter() {
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 50),
      child: Semantics(
        slider: true,
        label: widget.label,
        value: widget.labelFormatter(_lerp(factor)),
        enabled: widget.enabled,
        excludeSemantics: true,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          width = constraints.maxWidth - 1;
          height = constraints.maxHeight;
          factor = _unlerp(widget.values);
          pos = factor * width;
          SliderRangeValues positionValues = _lerp2(factor, 0, width);
          SliderRangeValues positionHandles = _lerp2(factor, 10, width - 10);

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
                  Positioned(
                    left: positionValues.start,
                    right: width - positionValues.end,
                    child: Container(
                      height: height * 0.75,
                      color: widget.enabled
                          ? TinyColor.fromColor(widget.activeColor)
                              .darken(15)
                              .color
                          : Theme.of(context).disabledColor, 
                    ),
                  ),
                  Positioned(
                      left: positionHandles.start - 10,
                      width: 20,
                      height: height * 0.9,
                      child: Container(
                          color: widget.enabled
                              ? widget.activeColor
                              : Theme.of(context).disabledColor,
                          width: 20)),
                  Positioned(
                      left: positionHandles.end - 10,
                      width: 20,
                      height: height * 0.9,
                      child: Container(
                          color: widget.enabled
                              ? widget.activeColor
                              : Theme.of(context).disabledColor,
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
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).hintColor,
                                fontSize: 20),
                          ),
                          Text(
                            widget.labelFormatter(_lerp(factor)),
                            style: TextStyle(
                                color: widget.enabled
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).hintColor,
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