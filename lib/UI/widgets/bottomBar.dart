// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/mightierIcons.dart';

class BottomBar extends StatefulWidget {
  final void Function(int) onTap;
  final int index;

  BottomBar({required this.index, required this.onTap});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: widget.index,
        onTap: (int _index) {
          widget.onTap(_index);
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
            icon: Icon(Icons.queue_music),
            label: "JamTracks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
          if (kDebugMode)
            BottomNavigationBarItem(
              icon: Icon(Icons.developer_mode),
              label: "Developer",
            )
        ]);
  }
}
