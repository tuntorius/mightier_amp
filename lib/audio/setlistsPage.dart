import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';

import 'models/setlist.dart';
import 'setlistPage.dart';

class Setlists extends StatefulWidget {
  const Setlists({Key? key}) : super(key: key);

  @override
  State createState() => _SetlistsState();
}

class _SetlistsState extends State<Setlists> {
  Offset _position = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
  }

  void createSetlist() {
    AlertDialogs.showInputDialog(context,
        title: "New Setlist",
        description: "Create new setlist",
        cancelButton: "Cancel",
        confirmButton: "Create",
        value: "New Setlist",
        validation: (name) {
          if (TrackData().findSetlist(name) != null) return false;
          return true;
        },
        validationErrorMessage: "A setlist with this name already exists",
        confirmColor: Theme.of(context).hintColor,
        onConfirm: (name) {
          TrackData().addSetlist(name);

          setState(() {});
        });
  }

  var popupSubmenu = <PopupMenuEntry>[
    // PopupMenuItem(
    //   value: 0,
    //   child: Row(
    //     children: <Widget>[
    //       Icon(
    //         Icons.view,
    //         color: AppThemeConfig.contextMenuIconColor,
    //       ),
    //       const SizedBox(width: 5),
    //       Text("Open"),
    //     ],
    //   ),
    // ),
    PopupMenuItem(
      value: 1,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.drive_file_rename_outline,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Rename"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 2,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.delete,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Delete"),
        ],
      ),
    )
  ];

  void showContextMenu(
      BuildContext context, dynamic item, List<PopupMenuEntry> menu) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    //open menu
    var rect = RelativeRect.fromRect(
        _position & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size);
    showMenu(
      position: rect,
      items: menu,
      context: context,
    ).then((value) {
      if (value != null) menuActions(context, value, item);
    });
  }

  void menuActions(BuildContext context, int action, Setlist item) async {
    switch (action) {
      // case 0: //edit
      //   editTrack(context, item);
      //   break;
      case 1: //rename
        renameSetlist(context, item);
        break;
      case 2: //delete
        AlertDialogs.showConfirmDialog(context,
            title: "Confirm",
            description: "Are you sure you want to delete ${item.name}?",
            cancelButton: "Cancel",
            confirmButton: "Delete",
            confirmColor: Colors.red, onConfirm: (delete) {
          if (delete) {
            TrackData().removeSetlist(item).then((value) => setState(() {}));
          }
        });
        break;
    }
  }

  void renameSetlist(BuildContext context, Setlist setlist) {
    AlertDialogs.showInputDialog(context,
        title: "Rename",
        description: "Enter setlist name:",
        cancelButton: "Cancel",
        confirmButton: "Rename",
        value: setlist.name,
        validation: (String newName) {
          if (TrackData().findSetlist(newName) != null) return false;
          return true;
        },
        validationErrorMessage: "Name already taken!",
        confirmColor: Theme.of(context).hintColor,
        onConfirm: (newName) {
          setlist.name = newName;
          TrackData().saveSetlists();
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    var setlists = TrackData().setlists;
    if (TrackData().tracks.isEmpty) {
      return const Center(child: Text("Add some tracks first!"));
    }
    return ListTileTheme(
      iconColor: Colors.white,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.only(
                    left: AppThemeConfig.dragHandlesWidth, right: 16),
                title: Text(TrackData().allTracks.name),
                subtitle: Text("${TrackData().allTracks.items.length} tracks"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SetlistPage(
                            setlist: TrackData().allTracks,
                            readOnly: true,
                          )));
                },
              ),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.grey[700],
                    //shadowColor: Colors.grey,
                  ),
                  child: ReorderableListView.builder(
                      itemCount: setlists.length,
                      itemBuilder: (context, index) {
                        return Container(
                          key: Key("$index"),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SetlistPage(
                                        setlist: setlists[index],
                                        readOnly: false,
                                      )));
                            },
                            onTapDown: (details) {
                              _position = details.globalPosition;
                            },
                            onLongPress: () {
                              showContextMenu(
                                  context, setlists[index], popupSubmenu);
                            },
                            child: Row(
                              children: [
                                ReorderableDragStartListener(
                                  index: index,
                                  child: InkWell(
                                    child: SizedBox(
                                      width: AppThemeConfig.dragHandlesWidth,
                                      height: 64,
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
                                    contentPadding:
                                        const EdgeInsets.only(right: 16),
                                    title: Text(setlists[index].name),
                                    subtitle: Text(
                                        "${setlists[index].items.length} tracks"),
                                    trailing: PopupMenuButton(
                                      child: const Padding(
                                        padding: EdgeInsets.only(
                                            left: 12.0,
                                            right: 4,
                                            bottom: 10,
                                            top: 10),
                                        child: Icon(Icons.more_vert,
                                            color: Colors.grey),
                                      ),
                                      itemBuilder: (context) {
                                        return popupSubmenu;
                                      },
                                      onSelected: (pos) {
                                        menuActions(context, pos as int,
                                            setlists[index]);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      buildDefaultDragHandles: false,
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) {
                          // removing the item at oldIndex will shorten the list by 1.
                          newIndex -= 1;
                        }
                        final element = setlists.removeAt(oldIndex);
                        setlists.insert(newIndex, element);
                        TrackData().saveSetlists();
                      }),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onPressed: () {
                createSetlist();
              },
              child: const Icon(
                Icons.add,
                size: 28,
              ),
            ),
          )
        ],
      ),
    );
  }
}
