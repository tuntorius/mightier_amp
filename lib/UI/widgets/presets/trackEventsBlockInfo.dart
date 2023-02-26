import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/audio/setlist_player/setlistPlayerState.dart';

class TrackEventsBlockInfo extends StatelessWidget {
  final Widget child;
  final Function() onBypass;
  const TrackEventsBlockInfo(
      {super.key, required this.child, required this.onBypass});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        ClipRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              child: Container(
                color: Colors.black54,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                  "The parameters are driven by the currently playing Jam Track!"),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  SetlistPlayerState.instance()
                      .automation
                      ?.bypassPresetChanges();
                  onBypass();
                },
                child: const Text("Bypass"),
              )
            ],
          ),
        )
      ],
    );
  }
}
