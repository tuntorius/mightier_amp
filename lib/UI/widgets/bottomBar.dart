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
            icon: Icon(Icons.music_note),
            label: "Presets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: "Drums",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: "Jam Tracks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          )
        ]);
  }
}
