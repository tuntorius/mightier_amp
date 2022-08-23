// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/mightierIcons.dart';

class BottomBar extends StatefulWidget {
  final void Function(int) onTap;
  final int index;

  const BottomBar({
    Key? key,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.index,
      onTap: widget.onTap,
      items: const [
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
      ],
    );
  }
}
