import 'package:flutter/material.dart';
import 'package:marquee_text/marquee_text.dart';
import '../setlistPage.dart';
import 'speedPanel.dart';

class SetlistPlayer extends StatelessWidget {
  final SetlistPlayerState state;
  final bool expanded;
  final Duration duration;
  SetlistPlayer(
      {required this.state, required this.expanded, required this.duration});

  @override
  Widget build(BuildContext context) {
    double height = 90;
    if (expanded) height = 420;

    return AnimatedContainer(
        duration: duration,
        height: height,
        color: Colors.grey[800],
        child: AnimatedSwitcher(
          duration: duration,
          child: createPlayerView(context, expanded),
        ));
  }

  Widget? createTitle() {
    //if (state.state != PlayerState.idle)
    return MarqueeText(
      text: state.setlist.items[state.currentTrack].trackReference!.name,
      speed: 20,
      // blankSpace: 40.0,
      // velocity: 30.0,
      // pauseAfterRound: const Duration(seconds: 3),
      // startAfter: const Duration(seconds: 3),
    );
    //return null;
  }

  Widget createPlayerView(BuildContext context, bool expanded) {
    if (expanded)
      return ListView(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Icon(Icons.keyboard_arrow_down),
          Container(height: 30, child: Center(child: createTitle())),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: createFullTrackControls(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Text(state.getMMSS(state.currentPosition)),
                Expanded(
                    child: SliderTheme(
                  data: SliderThemeData(
                      trackShape: SliderRepeatTrackShape(state: state)),
                  child: Slider(
                    value: state.currentPosition.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      state.setPosition(value.round());
                    },
                    max: state.getDuration().inMilliseconds.toDouble(),
                    onChangeStart: (val) {
                      //state.setPositionUpdateMode(true);
                    },
                    onChangeEnd: (val) {
                      //state.currentPosition = Duration(milliseconds: val.round());
                      //state.setPositionUpdateMode(false);
                    },
                  ),
                )),
                Text(state.getMMSS(state.getDuration()))
              ],
            ),
          ),
          /*ListTile(
            title: Text("Current preset: aoufh"),
          ),*/
          CheckboxListTile(
              title: Text("Auto Advance"),
              value: state.autoAdvance,
              onChanged: (value) {
                state.autoAdvance = value ?? true;
              }),
          if (state.automation != null && state.automation!.loopEnable)
            ListTile(
              title: Text("Loop ${createLoopLabel()}"),
              trailing: ElevatedButton(
                child: Text("Cancel Loop"),
                onPressed: () {
                  state.automation?.forceLoopDisable();
                },
              ),
            ),
          SpeedPanel(
            onSemitonesChanged: (val) {
              state.pitch = val;
              state.automation?.setPitch(val);
            },
            onSpeedChanged: (speed) {
              state.speed = speed;
              state.automation?.setSpeed(speed);
            },
            semitones: state.pitch,
            speed: state.speed,
          )
        ],
      );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.keyboard_arrow_up),
        ListTile(
          title: createTitle(),
          trailing: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: createMiniTrackControls()),
        ),
      ],
    );
  }

  String createLoopLabel() {
    if (state.automation!.loopTimes == 0) return "∞";
    return "${state.automation!.currentLoop}/${state.automation!.loopTimes}";
  }

  List<Widget> createFullTrackControls() {
    return [
      MaterialButton(
        onPressed: () {
          state.previous();
        },
        minWidth: 0,
        height: 80,
        child: Icon(
          Icons.skip_previous,
          color: Colors.white,
          size: 70,
        ),
      ),
      MaterialButton(
        onPressed: () {
          state.playPause();
        },
        minWidth: 0,
        height: 80,
        child: Icon(
          state.state == PlayerState.play ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 80,
        ),
      ),
      MaterialButton(
        onPressed: state.next,
        minWidth: 0,
        height: 80,
        child: Icon(
          Icons.skip_next,
          color: Colors.white,
          size: 70,
        ),
      ),
    ];
  }

  List<Widget> createMiniTrackControls() {
    return [
      MaterialButton(
        onPressed: () {
          state.playPause();
        },
        height: 100,
        minWidth: 0,
        child: Icon(
          state.state == PlayerState.play ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
      MaterialButton(
        onPressed: state.next,
        //height: 70,
        minWidth: 0,
        child: Icon(
          Icons.skip_next,
          color: Colors.white,
          size: 40,
        ),
      )
    ];
  }
}

class SliderRepeatTrackShape extends RoundedRectSliderTrackShape {
  final SetlistPlayerState state;
  double p1 = 0, p2 = 0;
  bool loopEnabled = false;
  final Paint repeatPaintOff = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.grey[700]!
    ..strokeWidth = 2;
  final Paint repeatPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.green
    ..strokeWidth = 2;
  SliderRepeatTrackShape({required this.state}) {
    if (state.automation != null && state.automation!.loopEnable == true) {
      loopEnabled = true;
      var points = state.automation!.getLoopPoints();
      var dur = state.automation!.duration.inMicroseconds;
      if (points.length == 2 && state.automation!.useLoopPoints) {
        p1 = points[0].eventTime.inMicroseconds / dur;
        p2 = points[1].eventTime.inMicroseconds / dur;
      } else if (!state.automation!.useLoopPoints) {
        p1 = 0;
        p2 = 1;
      }
    }
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    if (state.automation != null && loopEnabled) {
      var pos1 = (trackRect.right - trackRect.left) * p1 + trackRect.left;
      var pos2 = (trackRect.right - trackRect.left) * p2 + trackRect.left;
      var posPercentage = state.currentPosition.inMicroseconds /
          state.automation!.duration.inMicroseconds;

      var paint = repeatPaintOff;
      if (posPercentage >= p1 &&
          (state.automation!.loopTimes == 0 ||
              state.automation!.currentLoop < state.automation!.loopTimes))
        paint = repeatPaint;
      context.canvas.drawRect(
          Rect.fromLTRB(
            pos1,
            (textDirection == TextDirection.ltr)
                ? trackRect.top - additionalActiveTrackHeight * 4
                : trackRect.top,
            pos2,
            (textDirection == TextDirection.ltr)
                ? trackRect.bottom + additionalActiveTrackHeight * 4
                : trackRect.bottom,
          ),
          paint);
    }
    super.paint(context, offset,
        parentBox: parentBox,
        sliderTheme: sliderTheme,
        enableAnimation: enableAnimation,
        textDirection: textDirection,
        thumbCenter: thumbCenter);
  }
}
