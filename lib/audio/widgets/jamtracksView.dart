import 'package:flutter/material.dart';

import '../setlist_player/setlistPlayerState.dart';
import 'setlistPlayer.dart';

class JamtracksView extends StatelessWidget {
  final Widget child;
  const JamtracksView({Key? key, required this.child}) : super(key: key);

  Widget _musicPlayerPanel() {
    return const SetlistPlayer();
  }

  Widget _setlistPanel() {
    return Column(
      children: [
        Expanded(child: child),
        const SetlistMiniPlayer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final SetlistPlayerState playerState = SetlistPlayerState.instance();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: playerState.expanded ? _musicPlayerPanel() : _setlistPanel(),
    );
  }
}
