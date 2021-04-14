import 'package:flutter/material.dart';
import 'package:marquee_text/marquee_text.dart';
import '../setlistPage.dart';

class SetlistPlayer extends StatelessWidget {
  final SetlistPlayerState state;
  final bool expanded;
  final Duration duration;
  SetlistPlayer(
      {required this.state, required this.expanded, required this.duration});

  @override
  Widget build(BuildContext context) {
    double height = 90;
    if (expanded) height = MediaQuery.of(context).size.height - 400;

    bool hasTracks = state.setlist.items.length > 0;
    bool stopped = state.state == PlayerState.idle;
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
          Container(height: 50, child: Center(child: createTitle())),
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
              })
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

  List<Widget> createFullTrackControls() {
    return [
      /*MaterialButton(
        onPressed: () {},
        minWidth: 0,
        height: 60,
        child: Icon(
          Icons.shuffle,
          color: Colors.white,
          size: 30,
        ),
      ),*/
      MaterialButton(
        onPressed: () {
          state.previous();
        },
        minWidth: 0,
        height: 100,
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
        height: 100,
        child: Icon(
          state.state == PlayerState.play ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 90,
        ),
      ),
      MaterialButton(
        onPressed: () {
          state.next();
        },
        minWidth: 0,
        height: 100,
        child: Icon(
          Icons.skip_next,
          color: Colors.white,
          size: 70,
        ),
      ),
      /*MaterialButton(
        onPressed: () {},
        minWidth: 0,
        height: 60,
        child: Icon(
          Icons.repeat,
          color: Colors.white,
          size: 30,
        ),
      )*/
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
        onPressed: () {},
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
