// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/mightierIcons.dart';

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
            icon: Icon(MightierIcons.sliders),
            label: "Editor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Presets",
          ),
          BottomNavigationBarItem(
            icon: Icon(MightierIcons.drum),
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
