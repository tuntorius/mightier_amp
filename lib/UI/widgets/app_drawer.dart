import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/mightierIcons.dart';
import 'package:mighty_plug_manager/UI/widgets/NuxAppBar.dart';
import 'package:mighty_plug_manager/UI/widgets/VolumeDrawer.dart';

final _tiles = <TileModel>[
  const TileModel(0, 'Editor', MightierIcons.sliders),
  const TileModel(1, 'Presets', Icons.list),
  const TileModel(2, 'Drums', MightierIcons.drum),
  const TileModel(3, 'Jam Tracks', Icons.queue_music),
  const TileModel(4, 'Settings', Icons.settings),
];

class AppDrawer extends StatefulWidget {
  final void Function(int) onSwitchPageIndex;
  final int currentIndex;
  final int totalTabs;

  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onVolumeDragEnd;
  final double currentVolume;

  const AppDrawer({
    required this.onSwitchPageIndex,
    required this.currentIndex,
    required this.totalTabs,
    required this.onVolumeChanged,
    required this.onVolumeDragEnd,
    required this.currentVolume,
    Key? key,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isBottomDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const NuxAppBar(elevation: 0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _DrawerTile(
                      tileIndex: 0,
                      onSwitchPageIndex: widget.onSwitchPageIndex,
                      currentIndex: widget.currentIndex,
                    ),
                    _DrawerTile(
                      tileIndex: 1,
                      onSwitchPageIndex: widget.onSwitchPageIndex,
                      currentIndex: widget.currentIndex,
                    ),
                    _DrawerTile(
                      tileIndex: 2,
                      onSwitchPageIndex: widget.onSwitchPageIndex,
                      currentIndex: widget.currentIndex,
                    ),
                    _DrawerTile(
                      tileIndex: 3,
                      onSwitchPageIndex: widget.onSwitchPageIndex,
                      currentIndex: widget.currentIndex,
                    ),
                    _DrawerTile(
                      tileIndex: 4,
                      onSwitchPageIndex: widget.onSwitchPageIndex,
                      currentIndex: widget.currentIndex,
                    ),
                  ],
                ),
              ),
            ),
            BottomDrawer(
              isBottomDrawerOpen: isBottomDrawerOpen,
              onExpandChange: (val) => setState(() {
                isBottomDrawerOpen = val;
              }),
              child: VolumeSlider(
                currentVolume: widget.currentVolume,
                onVolumeChanged: widget.onVolumeChanged,
                onVolumeDragEnd: widget.onVolumeDragEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final int tileIndex;
  final int currentIndex;
  final void Function(int p1) onSwitchPageIndex;

  const _DrawerTile({
    Key? key,
    required this.onSwitchPageIndex,
    required this.currentIndex,
    required this.tileIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        tileIndex == currentIndex ? colorScheme.primary : colorScheme.secondary;

    return ListTile(
      title: Text(
        _tiles.elementAt(tileIndex).title,
        style: TextStyle(color: color),
        // textAlign: TextAlign.right,
      ),
      leading: Icon(
        _tiles.elementAt(tileIndex).icon,
      ),
      onTap: () => onSwitchPageIndex(tileIndex),
    );
  }
}

@immutable
class TileModel {
  final int index;
  final String title;
  final IconData icon;

  const TileModel(this.index, this.title, this.icon);
}
