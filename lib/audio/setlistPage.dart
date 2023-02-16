import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/UI/popups/selectTrack.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/UI/widgets/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/audio/setlist_player/setlistPlayerState.dart';
import 'models/setlist.dart';
import 'trackdata/trackData.dart';

class SetlistPage extends StatefulWidget {
  final Setlist setlist;
  final bool readOnly;
  final Function()? onBack;

  const SetlistPage(
      {Key? key, required this.setlist, required this.readOnly, this.onBack})
      : super(key: key);
  @override
  State createState() => _SetlistPageState();
}

class _SetlistPageState extends State<SetlistPage> {
  final animationDuration = const Duration(milliseconds: 200);

  final SetlistPlayerState playerState = SetlistPlayerState.instance();

  //multiselection stuff
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
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Remove"),
        ],
      ),
    )
  ];

  void menuActions(BuildContext context, int action, SetlistItem item) async {
    switch (action) {
      case 0: //delete
        AlertDialogs.showConfirmDialog(context,
            title: "Confirm",
            description:
                "Are you sure you want to remove ${item.trackReference!.name}?",
            cancelButton: "Cancel",
            confirmButton: "Delete",
            confirmColor: Colors.red, onConfirm: (delete) {
          if (delete) {
            widget.setlist.items.remove(item);
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
      //fill it first if not created
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

  Widget? createTrailingWidget(BuildContext context, int index) {
    if (widget.readOnly) return null;
    if (_multiselectMode) {
      return Icon(
        selected.containsKey(index)
            ? Icons.check_circle
            : Icons.brightness_1_outlined,
        color: selected.containsKey(index) ? null : Colors.grey[800],
      );
    }

    return PopupMenuButton(
      child: const Padding(
        padding: EdgeInsets.only(left: 12.0, right: 4, bottom: 10, top: 10),
        child: Icon(Icons.more_vert, color: Colors.grey),
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
    return NestedWillPopScope(
      onWillPop: () async {
        print("setlistPage will pop scope");
        if (_multiselectMode) {
          deselectAll();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.adaptive.arrow_back),
                onPressed: widget.onBack,
              ),
              title: Text(widget.setlist.name),
            ),
            Expanded(
              child: ListTileTheme(
                selectedTileColor: const Color.fromARGB(255, 9, 51, 116),
                selectedColor: Colors.white,
                iconColor: Colors.white,
                child: IndexedStack(
                  index: widget.setlist.items.isNotEmpty ? 0 : 1,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.grey[700],
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
                                            child: const Icon(
                                              Icons.drag_handle,
                                              color: Colors.grey,
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
                                            right: 16),
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
                              // removing the item at oldIndex will shorten the list by 1.
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
                        style: Theme.of(context).textTheme.bodyText1,
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
                    //delete mode
                    AlertDialogs.showConfirmDialog(context,
                        title: "Confirm",
                        description:
                            "Are you sure you want to remove ${selected.length} items?",
                        cancelButton: "Cancel",
                        confirmButton: "Delete",
                        confirmColor: Colors.red, onConfirm: (delete) async {
                      if (delete) {
                        for (int i = selected.length - 1; i >= 0; i--) {
                          widget.setlist.items
                              .removeAt(selected.keys.elementAt(i));
                        }
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
