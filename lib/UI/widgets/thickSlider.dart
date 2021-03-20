// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class ThickSlider extends StatefulWidget {
  final Color activeColor;
  final String label;
  final double min, max;
  final double value;
  final ValueChanged<double>? onChanged;
  final String Function(double) labelFormatter;
  final int skipEmitting;

  ThickSlider(
      {required this.activeColor,
      required this.label,
      this.min = 0,
      this.max = 1,
      required this.value,
      this.onChanged,
      required this.labelFormatter,
      this.skipEmitting = 3});

  @override
  _ThickSliderState createState() => _ThickSliderState();
}

class _ThickSliderState extends State<ThickSlider> {
  double factor = 0.5; //normalized position in 0-1
  double pos = 0;
  int lastTapDown = 0;
  int emitCounter = 0;
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
    assert(widget.value != null);
    assert(widget.min != null);
    assert(widget.max != null);
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double width = constraints.maxWidth - 1;

      factor = _unlerp(widget.value);
      pos = factor * width;

      return GestureDetector(
        onTapDown: (details) {
          var now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastTapDown < 300) {
            setPercentage(details.localPosition.dx, width);
            widget.onChanged?.call(_lerp(factor));
          }
          lastTapDown = now;
        },
        onHorizontalDragUpdate: (detail) {
          addPercentage(detail.delta.dx, width);
          emitCounter++;
          if (emitCounter % widget.skipEmitting == 0) {
            widget.onChanged?.call(_lerp(factor));
          }
        },
        onHorizontalDragEnd: (detail) {
          //call the last factor value here
          widget.onChanged?.call(_lerp(factor));
        },
        child: Container(
          color: Colors.transparent,
          height: 50,
          child: Stack(
            children: [
              Container(
                height: 30,
                color: TinyColor(widget.activeColor).darken(15).color,
                width: factor * width,
              ),
              Positioned(
                  left: _lerp2(factor, 10, width - 10) - 10,
                  width: 20,
                  height: 40,
                  child: Container(color: widget.activeColor, width: 20)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        widget.labelFormatter(_lerp(factor)),
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )
                    ]),
              ),
            ],
            alignment: Alignment.centerLeft,
          ),
        ),
      );
    });
  }
}
