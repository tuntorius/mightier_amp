import 'package:audio_picker/audio_picker.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/UI/widgets/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/UI/widgets/searchTextField.dart';
import 'package:path/path.dart';
import 'audioEditor.dart';
import 'models/jamTrack.dart';
import 'trackdata/trackData.dart';

class TracksPage extends StatefulWidget {
  final bool selectorOnly;
  final Function(JamTrack)? onSelectedTrack;
  final Function(bool, Map<int, bool>)? multiSelectState;

  TracksPage(
      {this.selectorOnly = false, this.onSelectedTrack, this.multiSelectState});

  @override
  _TracksPageState createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
  //search (filter) stuff
  String filter = "";
  final TextEditingController searchCtrl = TextEditingController(text: "");

  //multiselection stuff
  bool _multiselectMode = false;

  bool get multiselectMode => _multiselectMode;
  set multiselectMode(value) {
    _multiselectMode = value;
    widget.multiSelectState?.call(_multiselectMode, selected);
  }

  Map<int, bool> selected = {};

  var popupSubmenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: 0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.edit,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Edit"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 1,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.drive_file_rename_outline,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Rename"),
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
          Text("Delete"),
        ],
      ),
    )
  ];

  void menuActions(BuildContext context, int action, JamTrack item) async {
    switch (action) {
      case 0: //edit
        editTrack(context, item);
        break;
      case 1: //rename
        renameTrack(context, item);
        break;
      case 2: //delete
        AlertDialogs.showConfirmDialog(context,
            title: "Confirm",
            description: "Are you sure you want to delete ${item.name}?",
            cancelButton: "Cancel",
            confirmButton: "Delete",
            confirmColor: Colors.red, onConfirm: (delete) {
          if (delete) {
            TrackData().removeTrack(item).then((value) => setState(() {}));
          }
        });
        break;
    }
  }

  String getProperTags(Map? tags, String filename) {
    String title = "", artist = "";
    if (tags != null) {
      if (tags.containsKey("artist")) artist = tags["artist"];
      if (tags.containsKey("title")) title = tags["title"];
    }

    if (artist.isNotEmpty || title.isNotEmpty) {
      return "$artist - $title";
    }

    String fn = basename(filename);
    if (fn.contains('.')) {
      return fn.substring(0, fn.lastIndexOf("."));
    }
    return fn;
  }

  @override
  void initState() {
    super.initState();

    searchCtrl.addListener(() {
      filter = searchCtrl.value.text.toLowerCase();
      setState(() {});
    });
  }

  void multiselectHandler(int index) {
    if (selected.length == 0 || !selected.containsKey(index)) {
      //fill it first if not created
      selected[index] = true;
      multiselectMode = true;
    } else {
      selected.remove(index);
      if (selected.length == 0) multiselectMode = false;
    }
    setState(() {});
  }

  void deselectAll() {
    selected.clear();
    multiselectMode = false;
    setState(() {});
  }

  void editTrack(BuildContext context, JamTrack track) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AudioEditor(track)))
        .then((value) {
      //save track data
      TrackData().saveTracks();
    });
  }

  void renameTrack(BuildContext context, JamTrack track) {
    AlertDialogs.showInputDialog(context,
        title: "Rename",
        description: "Enter category name:",
        cancelButton: "Cancel",
        confirmButton: "Rename",
        value: track.name,
        validation: (String newName) {
          return newName.isNotEmpty;
        },
        validationErrorMessage: "Name already taken!",
        confirmColor: Colors.blue,
        onConfirm: (newName) {
          track.name = newName;
          TrackData().saveTracks();
          setState(() {});
        });
  }

  Widget? createTrailingWidget(BuildContext context, int index) {
    if (multiselectMode)
      return Icon(
        selected.containsKey(index)
            ? Icons.check_circle
            : Icons.brightness_1_outlined,
        color: selected.containsKey(index) ? null : Colors.grey[800],
      );

    if (widget.selectorOnly) return null;
    return PopupMenuButton(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 12.0, right: 4, bottom: 10, top: 10),
        child: Icon(Icons.more_vert, color: Colors.grey),
      ),
      itemBuilder: (context) {
        return popupSubmenu;
      },
      onSelected: (pos) {
        menuActions(context, pos as int, TrackData().tracks[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () {
        if (multiselectMode) {
          deselectAll();
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Column(
        children: [
          if (TrackData().tracks.length > 0)
            SearchTextField(controller: searchCtrl),
          Expanded(
            child: ListTileTheme(
              selectedTileColor: Color.fromARGB(255, 9, 51, 116),
              selectedColor: Colors.white,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  IndexedStack(
                    index: TrackData().tracks.length == 0 ? 0 : 1,
                    children: [
                      Center(
                          child: Text("No Tracks",
                              style: Theme.of(context).textTheme.bodyText1)),
                      ListView.builder(
                        itemCount: TrackData().tracks.length,
                        itemBuilder: (context, index) {
                          if (filter != "" &&
                              !TrackData()
                                  .tracks[index]
                                  .name
                                  .toLowerCase()
                                  .contains(filter)) return const SizedBox();
                          return ListTile(
                            selected:
                                multiselectMode && selected.containsKey(index),
                            title: Text(TrackData().tracks[index].name),
                            onTap: () {
                              if (multiselectMode) {
                                multiselectHandler(index);
                                return;
                              }
                              if (widget.selectorOnly)
                                widget.onSelectedTrack
                                    ?.call(TrackData().tracks[index]);
                              else
                                editTrack(context, TrackData().tracks[index]);
                            },
                            onLongPress: () => multiselectHandler(index),
                            trailing: createTrailingWidget(context, index),
                          );
                        },
                      ),
                    ],
                  ),
                  if (!widget.selectorOnly)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FloatingActionButton(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          if (multiselectMode) {
                            //delete mode
                            AlertDialogs.showConfirmDialog(context,
                                title: "Confirm",
                                description:
                                    "Are you sure you want to delete ${selected.length} items?",
                                cancelButton: "Cancel",
                                confirmButton: "Delete",
                                confirmColor: Colors.red,
                                onConfirm: (delete) async {
                              if (delete) {
                                for (int i = 0; i < selected.length; i++) {
                                  var item = TrackData()
                                      .tracks[selected.keys.elementAt(i)];
                                  await TrackData().removeTrack(item);
                                }
                                setState(() {});
                              }
                            });
                            return;
                          }
                          //add track mode
                          var path = await AudioPicker.pickAudioMultiple();
                          final tagger = new Audiotagger();
                          for (int i = 0; i < path.length; i++) {
                            //audiotagger
                            Map? tags =
                                await tagger.readTagsAsMap(path: path[i]);

                            var name = getProperTags(tags, path[i]);
                            TrackData().addTrack(path[i], name);

                            //asd - clear filter and scroll to bottom
                            searchCtrl.text = "";
                            setState(() {});
                          }
                        },
                        child: Icon(
                          multiselectMode ? Icons.delete : Icons.add,
                          size: 28,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
