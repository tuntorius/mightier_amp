import 'package:flutter/material.dart';

import '../setlist_player/setlistPlayerState.dart';
import 'setlistPlayer.dart';

class JamtracksView extends StatelessWidget {
  final Widget child;
  const JamtracksView({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SetlistPlayerState playerState = SetlistPlayerState.instance();
    final bool playerVisible = SetlistPlayerState.instance().setlist != null;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: playerVisible ? 56 : 0),
          child: child,
        ),
        if (playerVisible)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: playerState.expanded
                ? const SetlistPlayer()
                : const SetlistMiniPlayer(),
          )
      ],
    );
  }
}
