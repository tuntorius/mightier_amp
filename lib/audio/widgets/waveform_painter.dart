// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/audio/models/trackAutomation.dart';
import '../../bluetooth/devices/presets/Preset.dart';
import '../automationController.dart';
import '../models/waveform_data.dart';

class WaveformPainter extends CustomPainter {
  final WaveformData? data;
  final int startingFrame;
  final int endingFrame;
  final int currentSample;
  final bool overallWaveform;
  final AutomationController automation;
  final AutomationEventType? showType;
  late Paint painter;
  final Color color;
  final double strokeWidth;
  final Paint playbackPaint = Paint()
    ..color = Colors.grey[200]!
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  final List<Paint> channelPaints = <Paint>[];
  final Paint greyPaint = Paint();

  WaveformPainter(this.data,
      {this.strokeWidth = 1.0,
      this.startingFrame = 0,
      this.endingFrame = 1,
      this.currentSample = 0,
      required this.automation,
      required this.showType,
      this.overallWaveform = false,
      this.color = Colors.blue}) {
    painter = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    for (int i = 0; i < Preset.channelColors.length; i++) {
      var _paint = Paint()
        ..color = Preset.channelColors[i]
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      channelPaints.add(_paint);
    }

    greyPaint
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data == null || !data!.initialized) {
      return;
    }
    var _start = startingFrame, _end = endingFrame;

    if (!overallWaveform) {
      final path =
          data!.path(size, fromFrame: startingFrame, toFrame: endingFrame);

      if (path != null) canvas.drawPath(path, painter);
      if (currentSample >= startingFrame && currentSample <= endingFrame) {
        double dx =
            data!.verticalLine(size, currentSample, startingFrame, endingFrame);
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), playbackPaint);
      }
    } else {
      _start = 0;
      _end = data!.data.length;
      final path = data!.overallPath(size);
      if (path != null) canvas.drawPath(path, painter);
      double dx = data!.verticalLine(size, startingFrame, 0, data!.data.length);
      double dy = data!.verticalLine(size, endingFrame, 0, data!.data.length);

      //draw currently visible rectangle
      var rrect = Rect.fromLTRB(dx, 0, dy, size.height);
      canvas.drawRect(rrect, playbackPaint);

      //draw playback needle
      dx = data!.verticalLine(size, currentSample, 0, data!.data.length);
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), playbackPaint);
    }

    var msPerSample = data!.data.length / automation.duration.inMilliseconds;

    //draw events
    int realIndex = 0;
    for (int i = 0; i < automation.events.length; i++) {
      var element = automation.events[i];

      var paint = channelPaints[element.channel];
      if (element.type == AutomationEventType.preset &&
          element.getPresetUuid().isEmpty) paint = greyPaint;

      if (element.type != showType) continue;
      var dx = (((element.eventTime.inMilliseconds * msPerSample) - _start) /
              (_end - _start)) *
          size.width;
      if (dx < 0 || dx > size.width - 1) continue;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);

      //add labels
      if (!overallWaveform) {
        var paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
          ..pushStyle(
              ui.TextStyle(color: Preset.channelColors[element.channel]))
          ..addText(element.name);
        final ui.Paragraph paragraph = paragraphBuilder.build()
          ..layout(ui.ParagraphConstraints(width: size.width - 12.0 - 12.0));
        canvas.drawParagraph(paragraph, Offset(dx + 2, 6 + realIndex % 3 * 13));
      }
      realIndex++;
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    if (oldDelegate.data != data) {
      debugPrint("Redrawing");
      return true;
    }
    return false;
  }
}
