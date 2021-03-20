// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/audio/models/trackAutomation.dart';
import 'package:mighty_plug_manager/audio/models/waveform_data.dart';
import 'package:mighty_plug_manager/audio/widgets/waveform_painter.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/Preset.dart';

class PaintedWaveform extends StatefulWidget {
  final double dragHandlesheight = 56;
  final Function(int) onWaveformTap;
  final WaveformData sampleData;
  final int currentSample;
  final TrackAutomation automation;
  PaintedWaveform(
      {Key key,
      @required this.sampleData,
      this.onWaveformTap,
      this.currentSample,
      this.automation})
      : super(key: key);

  @override
  _PaintedWaveformState createState() => _PaintedWaveformState();
}

class _PaintedWaveformState extends State<PaintedWaveform> {
  int startPosition = 0;
  int endPosition = 0;

  double canvasSize = 0;

  Offset _startingFocalPoint;

  double _previousOffset = 0;
  double _offset = 0; // where the top left corner of the waveform is drawn

  double _previousScale;
  double _scale;
  bool isSingle = true;

  bool layoutBuilt = false;
  void initScaling() {
    endPosition = widget.sampleData.data.length - 1;

    //get initial scale. endPosition is essentialy waveform width
    _scale = canvasSize / endPosition;

    double fitted = endPosition * _scale;

    _offset = canvasSize - fitted;
    print(_scale);
    print(_offset);
    layoutBuilt = true;
  }

  void scroll(d) {
    var _fullScale = widget.sampleData.data.length / canvasSize;
    var _position = (d.localPosition.dx * _fullScale).round();
    var _extent = ((endPosition - startPosition) / 2).round();

    if (_position - _extent < 0) _position = _extent;
    if (_position + _extent > widget.sampleData.data.length - 1)
      _position = widget.sampleData.data.length - 1 - _extent;

    _offset = -_scale * startPosition;
    setState(() {
      startPosition = _position - _extent;
      endPosition = _position + _extent;
    });
  }

  void zoomViewOnTapUp(TapUpDetails e) {
    {
      int sample =
          ((e.localPosition.dx / canvasSize) * (endPosition - startPosition) +
                  startPosition)
              .floor();
      widget.onWaveformTap?.call(sample);
    }
  }

  void zoomViewScaleStart(ScaleStartDetails d) {
    _startingFocalPoint = d.focalPoint;
    _previousOffset = _offset;
    _previousScale = _scale;
  }

  void zoomViewScaleUpdate(ScaleUpdateDetails d) {
    if (d.scale == 1) {
      isSingle = true;
      //return;
    }

    isSingle = false;
    double newScale = _previousScale * d.scale;
    //if (newScale > 50 || newScale < 0.01) {
    //  return;
    //}

    // Ensure that item under the focal point stays in the same place despite zooming
    final double normalizedOffset =
        (_startingFocalPoint.dx - _previousOffset) / _previousScale;
    final double newOffset = d.focalPoint.dx - normalizedOffset * newScale;

    setState(() {
      var _oldScale = _scale;
      var _oldOffset = _offset;
      _scale = newScale;
      _offset = newOffset;

      //limit left boundary
      if (_offset > 0) {
        _offset = 0;
      }

      startPosition = -(_offset / _scale).round();

      //limit right boundary
      if (canvasSize / _scale + startPosition >
          widget.sampleData.data.length - 1) {
        _offset = _oldOffset;
        //i think we should not manipulate the scale
        //we should adjust the offset
        endPosition = widget.sampleData.data.length - 1;

        //calculate offset based on end position and new scale
        startPosition = endPosition - (canvasSize / _scale).round();

        _scale = _oldScale;

        if (startPosition < 0) startPosition = 0;
      } else
        endPosition = (startPosition + canvasSize / _scale).round();
    });
  }

  @override
  Widget build(context) {
    double msPerSample = 0;
    double time = 0;
    List<Widget> automationEventButtons = <Widget>[];

    if (layoutBuilt == true &&
        widget.automation.duration != null &&
        widget.sampleData != null) {
      msPerSample = widget.sampleData.data.length /
          widget.automation.duration.inMilliseconds;

      time = (widget.currentSample / msPerSample) / 1000;

      //create automation event handles (TODO: move them in separate widget)
      for (int i = 0; i < widget.automation.events.length; i++) {
        var element = widget.automation.events[i];
        Widget w = Positioned(
          left: (((element.eventTime.inMilliseconds * msPerSample) -
                          startPosition) /
                      (endPosition - startPosition)) *
                  canvasSize -
              widget.dragHandlesheight / 2,
          child: GestureDetector(
            onHorizontalDragUpdate: (d) {
              //get samples per pixel
              var samplesPerPixel =
                  ((endPosition - startPosition) / canvasSize);

              setState(() {
                element.eventTime += Duration(
                    milliseconds:
                        (d.delta.dx * (samplesPerPixel / msPerSample)).round());
              });
            },
            onHorizontalDragEnd: (d) {
              //update automation
              setState(() {
                widget.automation.sortEvents();
              });
            },
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Preset.channelColors[element.channel],
              child: Icon(Icons.circle),
              heroTag: "dragTag$i",
            ),
          ),
        );

        automationEventButtons.add(w);
      }
    }
    return Container(
      color: Colors.grey[900],
      child: LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          // adjust the shape based on parent's orientation/shape

          if (canvasSize == 0 &&
              widget.sampleData != null &&
              widget.sampleData.data != null) {
            canvasSize = constraints.maxWidth;
            initScaling();
          }

          return Container(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: scroll,
                    onHorizontalDragUpdate: scroll,
                    child: CustomPaint(
                      size: Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ),
                      foregroundPainter: WaveformPainter(
                        widget.sampleData,
                        endingFrame: endPosition,
                        startingFrame: startPosition,
                        currentSample: widget.currentSample,
                        automation: widget.automation,
                        overallWaveform: true,
                        color: Color(0xff3994DB),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: zoomViewOnTapUp,
                    onScaleStart: zoomViewScaleStart,
                    onScaleUpdate: zoomViewScaleUpdate,
                    child: CustomPaint(
                      size: Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ),
                      foregroundPainter: WaveformPainter(
                        widget.sampleData,
                        endingFrame: endPosition,
                        startingFrame: startPosition,
                        currentSample: widget.currentSample,
                        automation: widget.automation,
                        color: Color(0xff3994DB),
                      ),
                    ),
                  ),
                ),
                //container for event handles
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.black),
                  height: widget.dragHandlesheight,
                  child: Stack(
                    children: automationEventButtons,
                  ),
                ),
                //Text(time.floor().toString())
              ],
            ),
          );
        },
      ),
    );
  }
}
