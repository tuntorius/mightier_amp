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

  final Function(double value, bool skip) onVolumeChanged;
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
  bool isExpanded = false;
  bool isBottomDrawerOpen = false;
  bool expandChildren = false;

  void _onExpandChange(bool expand) {
    isExpanded = expand;
    if (isExpanded == false) expandChildren = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 5) {
          //open
          _onExpandChange(true);
        } else if (details.delta.dx < -5) {
          //close
          _onExpandChange(false);
        }
      },
      child: AnimatedContainer(
        onEnd: () {
          if (isExpanded) expandChildren = true;
          setState(() {});
        },
        duration: const Duration(milliseconds: 200),
        width: isExpanded ? 230 : 56,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NuxAppBar(
                elevation: 0,
                expanded: expandChildren,
                showExpandButton: true,
                onExpandStateChanged: _onExpandChange,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DrawerTile(
                        tileIndex: 0,
                        onSwitchPageIndex: widget.onSwitchPageIndex,
                        currentIndex: widget.currentIndex,
                        expanded: expandChildren,
                      ),
                      _DrawerTile(
                        tileIndex: 1,
                        onSwitchPageIndex: widget.onSwitchPageIndex,
                        currentIndex: widget.currentIndex,
                        expanded: expandChildren,
                      ),
                      _DrawerTile(
                        tileIndex: 2,
                        onSwitchPageIndex: widget.onSwitchPageIndex,
                        currentIndex: widget.currentIndex,
                        expanded: expandChildren,
                      ),
                      _DrawerTile(
                        tileIndex: 3,
                        onSwitchPageIndex: widget.onSwitchPageIndex,
                        currentIndex: widget.currentIndex,
                        expanded: expandChildren,
                      ),
                      _DrawerTile(
                        tileIndex: 4,
                        onSwitchPageIndex: widget.onSwitchPageIndex,
                        currentIndex: widget.currentIndex,
                        expanded: expandChildren,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
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
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final int tileIndex;
  final int currentIndex;
  final bool expanded;
  final void Function(int p1) onSwitchPageIndex;

  const _DrawerTile(
      {Key? key,
      required this.onSwitchPageIndex,
      required this.currentIndex,
      required this.tileIndex,
      required this.expanded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        tileIndex == currentIndex ? colorScheme.primary : colorScheme.secondary;
    if (expanded) {
      return ListTile(
        selected: tileIndex == currentIndex,
        title: Text(
          _tiles.elementAt(tileIndex).title,
          // textAlign: TextAlign.right,
        ),
        leading: Icon(
          _tiles.elementAt(tileIndex).icon,
        ),
        minLeadingWidth: 10,
        onTap: () => onSwitchPageIndex(tileIndex),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: IconButton(
            onPressed: () => onSwitchPageIndex(tileIndex),
            icon: Icon(
              _tiles.elementAt(tileIndex).icon,
              color: color,
            )),
      );
    }
  }
}

@immutable
class TileModel {
  final int index;
  final String title;
  final IconData icon;

  const TileModel(this.index, this.title, this.icon);
}
