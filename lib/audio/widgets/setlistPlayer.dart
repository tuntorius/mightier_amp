import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:mighty_plug_manager/UI/widgets/thickSlider.dart';
import '../../UI/mightierIcons.dart';
import '../../UI/widgets/VolumeDrawer.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../../platform/platformUtils.dart';
import '../../platform/simpleSharedPrefs.dart';
import '../automationController.dart';
import '../setlist_player/setlistPlayerState.dart';
import 'speedPanel.dart';

class SetlistPlayer extends StatefulWidget {
  const SetlistPlayer({Key? key}) : super(key: key);

  @override
  State<SetlistPlayer> createState() => _SetlistPlayerState();
}

class _SetlistPlayerState extends State<SetlistPlayer> {
  final animationDuration = const Duration(milliseconds: 200);
  final SetlistPlayerState playerState = SetlistPlayerState.instance();
  StreamSubscription? _positionSub;

  @override
  void initState() {
    super.initState();
    playerState.addListener(_onPlayerStateChange);
    _positionSub = playerState.positionStream.listen(_onPlayerPosition);
    // Removed NuxDeviceControl listener to prevent BLE flood from blocking audio transport UI updates
  }

  @override
  void dispose() {
    super.dispose();
    playerState.removeListener(_onPlayerStateChange);
    _positionSub?.cancel();
  }

  void _onPlayerPosition(Duration position) {
    if (mounted) setState(() {});
  }

  void _onPlayerStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return createPlayerView(context);
  }

  Widget? createTitle() {
    return MarqueeText(
      text: TextSpan(
          text: playerState.setlist?.items[playerState.currentTrack]
                  .trackReference?.name ??
              "No Track",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      speed: 20,
    );
  }

  Widget createPlayerView(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(builder: (context, constraints) {
      double maxDur = playerState.getDuration().inMilliseconds.toDouble();
      double currentPos = playerState.currentPosition.inMilliseconds.toDouble();
      if (maxDur <= 0) maxDur = 1.0;
      if (currentPos > maxDur) currentPos = maxDur;

      return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          children: [
            ListTile(
              tileColor: isDark ? Colors.grey[850] : Colors.grey[200],
              leading: IconButton(
                iconSize: 32,
                color: Theme.of(context).iconTheme.color,
                onPressed: playerState.toggleExpanded,
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
              title: createTitle(),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: createFullTrackControls(constraints),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Text(playerState.getMMSS(playerState.currentPosition)),
                  Expanded(
                      child: SliderTheme(
                    data: SliderThemeData(
                        trackShape: SliderRepeatTrackShape(state: playerState)),
                    child: Slider(
                      value: currentPos,
                      max: maxDur,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            playerState.setPosition(value.round());
                          });
                        }
                      },
                      onChangeStart: (val) {
                        playerState.setPositionUpdateMode(true);
                      },
                      onChangeEnd: (val) {
                        playerState.setPosition(val.round());
                        playerState.setPositionUpdateMode(false);
                      },
                    ),
                  )),
                  Text(playerState.getMMSS(playerState.getDuration()))
                ],
              ),
            ),
            CheckboxListTile(
                title: const Text("Auto Advance"),
                value: playerState.autoAdvance,
                onChanged: (value) {
                  playerState.autoAdvance = value ?? true;
                  if (mounted) setState(() {});
                }),
            if (playerState.automation != null &&
                playerState.automation!.loopEnable &&
                playerState.automation!.abRepeatState != ABRepeatState.addedB)
              ListTile(
                title: Text("Loop ${createLoopLabel()}"),
                trailing: ElevatedButton(
                  child: const Text("Cancel Loop"),
                  onPressed: () {
                    playerState.automation?.forceLoopDisable();
                    if (mounted) setState(() {});
                  },
                ),
              ),
            SpeedPanel(
              compact: true,
              onSemitonesChanged: (val) {
                playerState.pitch = val;
                playerState.automation?.setPitch(val);
                if (mounted) setState(() {});
              },
              onSpeedChanged: (speed) {
                playerState.speed = speed;
                playerState.automation?.setSpeed(speed);
                if (mounted) setState(() {});
              },
              semitones: playerState.pitch,
              speed: playerState.speed,
            ),
            if (PlatformUtils.isAndroid)
              ThickSlider(
                activeColor: playerState.gain <= 0
                    ? Colors.blue
                    : playerState.gain < 12
                        ? Colors.amber
                        : Colors.red,
                label: "Track Gain",
                value: playerState.gain,
                min: -20,
                max: 20,
                snapToCenter: true,
                // FIX: Corrected raw string interpolation syntax error
                labelFormatter: (val) => val.toStringAsFixed(1) + " dB",
                onChanged: (value, skip) {
                  playerState.gain = value;
                  if (mounted) setState(() {});
                },
                onDragEnd: (value) {
                  SharedPrefs()
                      .setValue(SettingsKeys.trackGain, playerState.gain);
                },
              ),
            const VolumeSlider(label: "Amp Volume")
          ],
        ),
      );
    });
  }

  String createLoopLabel() {
    if (playerState.automation!.loopTimes == 0) return "∞";
    return "${playerState.automation!.currentLoop}/${playerState.automation!.loopTimes}";
  }

  IconData getABRepeatIcon() {
    switch (SetlistPlayerState.instance().abRepeat) {
      case ABRepeatState.off:
        return MightierIcons.repeat;
      case ABRepeatState.addedA:
        return MightierIcons.repeat_a;
      case ABRepeatState.addedB:
        return MightierIcons.repeat_ab;
    }
  }

  List<Widget> createFullTrackControls(BoxConstraints constraints) {
    var totalIconSize = constraints.maxWidth.floorToDouble() / 6;
    totalIconSize = math.min(totalIconSize, 70);
    var iconSize = totalIconSize - 14;
    var padding = const EdgeInsets.all(7);
    Color iconColor = Theme.of(context).iconTheme.color ?? Colors.white;

    return [
      IconButton(
        padding: padding,
        onPressed: playerState.previous,
        iconSize: iconSize,
        icon: Icon(Icons.skip_previous, color: iconColor),
      ),
      IconButton(
        padding: padding,
        onPressed: () {
          playerState.setPosition(
              (playerState.currentPosition + const Duration(seconds: -5))
                  .inMilliseconds);
        },
        iconSize: iconSize,
        icon: Icon(Icons.fast_rewind, color: iconColor),
      ),
      IconButton(
        padding: padding,
        onPressed: playerState.playPause,
        iconSize: iconSize,
        icon: Icon(
          playerState.state == PlayerState.play
              ? Icons.pause
              : Icons.play_arrow,
          color: iconColor,
        ),
      ),
      IconButton(
        padding: padding,
        onPressed: () {
          playerState.setPosition(
              (playerState.currentPosition + const Duration(seconds: 5))
                  .inMilliseconds);
        },
        iconSize: iconSize,
        icon: Icon(Icons.fast_forward, color: iconColor),
      ),
      IconButton(
        padding: padding,
        onPressed: playerState.next,
        iconSize: iconSize,
        icon: Icon(Icons.skip_next, color: iconColor),
      ),
      IconButton(
        padding: padding,
        onPressed: playerState.toggleABRepeat,
        iconSize: iconSize,
        icon: Icon(getABRepeatIcon(), color: iconColor),
      ),
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
      if (dur > 0 && points.length == 2 && state.automation!.useLoopPoints) {
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
    Offset? secondaryOffset,
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

    if (state.automation != null && loopEnabled && state.automation!.duration.inMicroseconds > 0) {
      var pos1 = (trackRect.right - trackRect.left) * p1 + trackRect.left;
      var pos2 = (trackRect.right - trackRect.left) * p2 + trackRect.left;
      var posPercentage = state.currentPosition.inMicroseconds /
          state.automation!.duration.inMicroseconds;

      var paint = repeatPaintOff;
      if (posPercentage >= p1 &&
          (state.automation!.loopTimes == 0 ||
              state.automation!.currentLoop < state.automation!.loopTimes)) {
        paint = repeatPaint;
      }
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

class SetlistMiniPlayer extends StatefulWidget {
  const SetlistMiniPlayer({Key? key}) : super(key: key);

  @override
  State<SetlistMiniPlayer> createState() => SetlistMiniPlayerState();
}

class SetlistMiniPlayerState extends State<SetlistMiniPlayer> {
  final SetlistPlayerState playerState = SetlistPlayerState.instance();
  StreamSubscription? _positionSub;

  @override
  void initState() {
    super.initState();
    playerState.addListener(_onPlayerStateChange);
    _positionSub = playerState.positionStream.listen(_opPlayerPosition);
  }

  @override
  void dispose() {
    super.dispose();
    playerState.removeListener(_onPlayerStateChange);
    _positionSub?.cancel();
  }

  void _opPlayerPosition(Duration position) {
    if (mounted) setState(() {});
  }

  void _onPlayerStateChange() {
    if (mounted) setState(() {});
  }

  Widget? createTitle() {
    return MarqueeText(
      text: TextSpan(
          text: playerState.setlist?.items[playerState.currentTrack]
                  .trackReference?.name ??
              "No Track",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      speed: 20,
    );
  }

  List<Widget> createMiniTrackControls() {
    Color iconColor = Theme.of(context).iconTheme.color ?? Colors.white;

    return [
      IconButton(
        onPressed: playerState.previous,
        icon: Icon(
          Icons.skip_previous,
          color: iconColor,
          size: 30,
        ),
      ),
      IconButton(
        onPressed: playerState.playPause,
        icon: Icon(
          playerState.state == PlayerState.play
              ? Icons.pause
              : Icons.play_arrow,
          color: iconColor,
          size: 30,
        ),
      ),
      IconButton(
        onPressed: playerState.next,
        icon: Icon(
          Icons.skip_next,
          color: iconColor,
          size: 30,
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      child: ListTile(
        onTap: playerState.toggleExpanded,
        leading: IconButton(
          iconSize: 32,
          color: Theme.of(context).iconTheme.color,
          onPressed: playerState.toggleExpanded,
          icon: const Icon(Icons.keyboard_arrow_up),
        ),
        minLeadingWidth: 0,
        title: createTitle(),
        trailing: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: createMiniTrackControls()),
      ),
    );
  }
}