import 'dart:async';

import 'package:flutter/material.dart';
import 'package:marquee_text/marquee_text.dart';
import '../../UI/widgets/VolumeDrawer.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/value_formatters/ValueFormatter.dart';
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

  final device = NuxDeviceControl.instance().device;
  double get currentVolume => device.fakeMasterVolume
      ? NuxDeviceControl.instance().masterVolume
      : device.presets[device.selectedChannel].volume;
  ValueFormatter get volFormatter => device.fakeMasterVolume
      ? ValueFormatters.percentage
      : device.decibelFormatter!;

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
    setState(() {});
  }

  void _onPlayerStateChange() {
    setState(() {});
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
              "No Track"),
      speed: 20,
    );
  }

  Widget createPlayerView(BuildContext context) {
    return ListView(
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ListTile(
          leading: IconButton(
            iconSize: 32,
            onPressed: playerState.toggleExpanded,
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
          title: createTitle(),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: createFullTrackControls(),
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
                  value: playerState.currentPosition.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    playerState.setPosition(value.round());
                  },
                  max: playerState.getDuration().inMilliseconds.toDouble(),
                  onChangeStart: (val) {
                    //state.setPositionUpdateMode(true);
                  },
                  onChangeEnd: (val) {
                    //state.currentPosition = Duration(milliseconds: val.round());
                    //state.setPositionUpdateMode(false);
                  },
                ),
              )),
              Text(playerState.getMMSS(playerState.getDuration()))
            ],
          ),
        ),
        /*ListTile(
            title: Text("Current preset: aoufh"),
          ),*/
        CheckboxListTile(
            title: const Text("Auto Advance"),
            value: playerState.autoAdvance,
            onChanged: (value) {
              playerState.autoAdvance = value ?? true;
              setState(() {});
            }),
        if (playerState.automation != null &&
            playerState.automation!.loopEnable)
          ListTile(
            title: Text("Loop ${createLoopLabel()}"),
            trailing: ElevatedButton(
              child: const Text("Cancel Loop"),
              onPressed: () {
                playerState.automation?.forceLoopDisable();

                setState(() {});
              },
            ),
          ),
        SpeedPanel(
          onSemitonesChanged: (val) {
            playerState.pitch = val;
            playerState.automation?.setPitch(val);
            setState(() {});
          },
          onSpeedChanged: (speed) {
            playerState.speed = speed;
            playerState.automation?.setSpeed(speed);
            setState(() {});
          },
          semitones: playerState.pitch,
          speed: playerState.speed,
        ),
        VolumeSlider(
          label: "Amp Volume",
          currentVolume: currentVolume,
          onVolumeChanged: () {
            setState(() {});
          },
          volumeFormatter: volFormatter,
        )
      ],
    );
  }

  String createLoopLabel() {
    if (playerState.automation!.loopTimes == 0) return "∞";
    return "${playerState.automation!.currentLoop}/${playerState.automation!.loopTimes}";
  }

  List<Widget> createFullTrackControls() {
    var totalIconSize = MediaQuery.of(context).size.width.floorToDouble() / 5;
    var iconSize = totalIconSize - 14;
    var padding = const EdgeInsets.all(7);
    return [
      IconButton(
        padding: padding,
        onPressed: () {
          playerState.previous();
        },
        iconSize: iconSize,
        icon: const Icon(
          Icons.skip_previous,
          color: Colors.white,
        ),
      ),
      IconButton(
        padding: padding,
        onPressed: () {
          playerState.setPosition(
              (playerState.currentPosition + const Duration(seconds: -5))
                  .inMilliseconds);
        },
        iconSize: iconSize,
        icon: const Icon(
          Icons.fast_rewind,
          color: Colors.white,
        ),
      ),
      IconButton(
        padding: padding,
        onPressed: () {
          playerState.playPause();
        },
        iconSize: iconSize,
        icon: Icon(
          playerState.state == PlayerState.play
              ? Icons.pause
              : Icons.play_arrow,
          color: Colors.white,
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
        icon: const Icon(
          Icons.fast_forward,
          color: Colors.white,
        ),
      ),
      IconButton(
        padding: padding,
        onPressed: playerState.next,
        iconSize: iconSize,
        icon: const Icon(
          Icons.skip_next,
          color: Colors.white,
        ),
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
    setState(() {});
  }

  void _onPlayerStateChange() {
    setState(() {});
  }

  Widget? createTitle() {
    return MarqueeText(
      text: TextSpan(
          text: playerState.setlist?.items[playerState.currentTrack]
                  .trackReference?.name ??
              "No Track"),
      speed: 20,
    );
  }

  List<Widget> createMiniTrackControls() {
    return [
      IconButton(
        onPressed: playerState.playPause,
        icon: Icon(
          playerState.state == PlayerState.play
              ? Icons.pause
              : Icons.play_arrow,
          color: Colors.white,
          size: 30,
        ),
      ),
      IconButton(
        onPressed: playerState.next,
        icon: const Icon(
          Icons.skip_next,
          color: Colors.white,
          size: 30,
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[850],
      //height: 60,
      child: ListTile(
        onTap: playerState.toggleExpanded,
        leading: IconButton(
          iconSize: 32,
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
