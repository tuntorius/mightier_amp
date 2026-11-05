import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/UI/popups/selectTrack.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/UI/widgets/common/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/audio/setlist_player/setlistPlayerState.dart';
import '../UI/pages/jamTracks.dart';
import 'models/setlist.dart';
import 'trackdata/trackData.dart';

class SetlistPage extends StatefulWidget {
  final Setlist setlist;
  final bool readOnly;

  const SetlistPage({Key? key, required this.setlist, required this.readOnly})
      : super(key: key);
  @override
  State createState() => _SetlistPageState();
}

class _SetlistPageState extends State<SetlistPage> {
  final animationDuration = const Duration(milliseconds: 200);

  final SetlistPlayerState playerState = SetlistPlayerState.instance();

  bool _multiselectMode = false;
  Offset dragStart = const Offset(0, 0);
  Map<int, bool> selected = {};

  var popupSubmenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: 0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.highlight_remove_outlined,
          ),
          const SizedBox(width: 5),
          const Text("Remove"),
        ],
      ),
    )
  ];

  void menuActions(BuildContext context, int action, SetlistItem item) async {
    switch (action) {
      case 0:
        AlertDialogs.showConfirmDialog(context,
            title: "Confirm",
            description:
                "Are you sure you want to remove ${item.trackReference!.name}?",
            cancelButton: "Cancel",
            confirmButton: "Delete",
            confirmColor: Colors.red, onConfirm: (delete) {
          if (delete) {
            SetlistItem? currentSong = findPlayedTrack();
            widget.setlist.items.remove(item);
            reattachTrackIndex(currentSong);
            TrackData().saveSetlists().then((value) {
              setState(() {});
            });
          }
        });
        break;
    }
  }

  void addTrack() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          SelectTrackDialog().buildDialog(context),
    ).then((value) {
      if (value == null) return;
      if (value is List) {
        for (var element in value) {
          widget.setlist.addTrack(element);
        }
      } else {
        widget.setlist.addTrack(value);
      }

      TrackData().saveSetlists();
      setState(() {});
    });
  }

  void multiselectHandler(int index) {
    if (selected.isEmpty || !selected.containsKey(index)) {
      selected[index] = true;
      _multiselectMode = true;
    } else {
      selected.remove(index);
      if (selected.isEmpty) _multiselectMode = false;
    }
    setState(() {});
  }

  void deselectAll() {
    selected.clear();
    _multiselectMode = false;
    setState(() {});
  }

  SetlistItem? findPlayedTrack() {
    if (playerState.setlist == widget.setlist) {
      return widget.setlist.items[playerState.currentTrack];
    }
    return null;
  }

  void reattachTrackIndex(SetlistItem? currentSong) {
    if (currentSong != null) {
      var index = widget.setlist.items.indexOf(currentSong);
      if (index > -1) {
        playerState.currentTrack = index;
      } else {
        playerState.clear();
      }
    }
  }

  Widget? createTrailingWidget(BuildContext context, int index) {
    if (widget.readOnly) return null;
    if (_multiselectMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Icon(
          selected.containsKey(index)
              ? Icons.check_circle
              : Icons.brightness_1_outlined,
          color: selected.containsKey(index) ? null : Theme.of(context).disabledColor,
        ),
      );
    }

    return PopupMenuButton(
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Icon(Icons.more_vert),
      ),
      itemBuilder: (context) {
        return popupSubmenu;
      },
      onSelected: (pos) {
        menuActions(context, pos as int, widget.setlist.items[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return NestedWillPopScope(
      onWillPop: () async {
        if (_multiselectMode) {
          deselectAll();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            // Removed hardcoded background color to use Theme
            title: Text(widget.setlist.name)),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListTileTheme(
                // Use dynamic theme values instead of hardcoded ARGBs
                selectedTileColor: isDark ? const Color.fromARGB(255, 9, 51, 116) : Colors.blue[100],
                selectedColor: isDark ? Colors.white : Colors.blue[900],
                iconColor: Theme.of(context).iconTheme.color,
                child: IndexedStack(
                  index: widget.setlist.items.isNotEmpty ? 0 : 1,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Theme.of(context).canvasColor,
                      ),
                      child: ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          itemCount: widget.setlist.items.length,
                          itemBuilder: (context, index) {
                            return Container(
                              key: Key("$index"),
                              child: InkWell(
                                onTap: () {
                                  if (_multiselectMode) {
                                    multiselectHandler(index);
                                    return;
                                  }
                                  var track = widget
                                      .setlist.items[index].trackReference;
                                  if (track != null) {
                                    if (playerState.setlist != widget.setlist) {
                                      playerState.openSetlist(widget.setlist);
                                    }
                                    playerState.openTrack(index);
                                  }
                                  setState(() {});
                                },
                                onLongPress: widget.readOnly
                                    ? null
                                    : () => multiselectHandler(index),
                                child: Row(
                                  children: [
                                    if (!widget.readOnly && !_multiselectMode)
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: InkWell(
                                          child: SizedBox(
                                            width:
                                                AppThemeConfig.dragHandlesWidth,
                                            height: 48,
                                            child: Icon(
                                              Icons.drag_handle,
                                              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: ListTile(
                                        selected: _multiselectMode &&
                                            selected.containsKey(index),
                                        contentPadding: EdgeInsets.only(
                                            left: widget.readOnly ||
                                                    _multiselectMode
                                                ? 16
                                                : 0,
                                            right: 0),
                                        title: Text(widget.setlist.items[index]
                                            .trackReference!.name),
                                        trailing: createTrailingWidget(
                                            context, index),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          onReorder: (int oldIndex, int newIndex) {
                            var currentItem =
                                widget.setlist.items[playerState.currentTrack];
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final element =
                                widget.setlist.items.removeAt(oldIndex);
                            widget.setlist.items.insert(newIndex, element);

                            if (playerState.setlist == widget.setlist) {
                              playerState.currentTrack =
                                  widget.setlist.items.indexOf(currentItem);
                            }

                            TrackData().saveSetlists();
                          }),
                    ),
                    Center(
                      child: Text(
                        "No Tracks",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: widget.readOnly
            ? null
            : FloatingActionButton(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                onPressed: () {
                  if (_multiselectMode) {
                    AlertDialogs.showConfirmDialog(
                        JamTracks.jamtracksNavigator.currentContext!,
                        title: "Confirm",
                        description:
                            "Are you sure you want to remove ${selected.length} items?",
                        cancelButton: "Cancel",
                        confirmButton: "Delete",
                        confirmColor: Colors.red, onConfirm: (delete) async {
                      if (delete) {
                        SetlistItem? currentSong = findPlayedTrack();

                        for (int i = selected.length - 1; i >= 0; i--) {
                          var index = selected.keys.elementAt(i);
                          if (playerState.setlist == widget.setlist &&
                              playerState.currentTrack == index) {}
                          widget.setlist.items.removeAt(index);
                        }

                        reattachTrackIndex(currentSong);
                        await TrackData().saveSetlists();
                        deselectAll();
                      }
                    });
                    return;
                  }
                  addTrack();
                },
                child: Icon(
                  _multiselectMode ? Icons.delete : Icons.add,
                  size: 28,
                ),
              ),
      ),
    );
  }
}