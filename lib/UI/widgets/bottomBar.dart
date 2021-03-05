// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  final void Function(int) onTap;
  final int index;

  BottomBar({this.index, this.onTap});

  @override
  _BottomBarState createState() => _BottomBarState(index);
}

class _BottomBarState extends State<BottomBar> {
  int index = 0;

  _BottomBarState(this.index);
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: index,
        onTap: (int _index) {
          index = _index;
          widget.onTap(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.equalizer),
            label: "Editor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Presets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: "Drums",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: "JamTracks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          )
        ]);
  }
}
