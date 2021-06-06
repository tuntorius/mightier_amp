import 'package:audio_picker/audio_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/UI/widgets/fabMenu.dart';
import 'package:mighty_plug_manager/UI/widgets/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/UI/widgets/searchTextField.dart';
import 'package:mighty_plug_manager/audio/widgets/media_library/media_browse.dart';
import 'package:path/path.dart';
import 'audioEditor.dart';
import 'models/jamTrack.dart';
import 'online_sources/onlineTrack.dart';
import 'trackdata/trackData.dart';
import 'widgets/online_source/online_source.dart';

class TracksPage extends StatefulWidget {
  final bool selectorOnly;
  final Function(JamTrack)? onSelectedTrack;
  final Function(bool, Map<int, bool>)? multiSelectState;

  TracksPage(
      {this.selectorOnly = false, this.onSelectedTrack, this.multiSelectState});

  @override
  _TracksPageState createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage>
    with SingleTickerProviderStateMixin {
  //search (filter) stuff
  String filter = "";
  final TextEditingController searchCtrl = TextEditingController(text: "");
  final scrollController = ScrollController();

  //multiselection stuff
  bool _multiselectMode = false;

  //menu anim
  late Animation<double> _animation;
  late AnimationController _animationController;
  static List<SongInfo>? songList;

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

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    querySongs();
  }

  void querySongs() async {
    if (songList != null) return;
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    songList = await audioQuery.getSongs();
    print(songList?.length);
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
        description: "Enter track name:",
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

  void deleteSelected(BuildContext context) {
    AlertDialogs.showConfirmDialog(context,
        title: "Confirm",
        description:
            "Are you sure you want to delete ${selected.length} items?",
        cancelButton: "Cancel",
        confirmButton: "Delete",
        confirmColor: Colors.red, onConfirm: (delete) async {
      if (delete) {
        List<JamTrack> delTracks = [];
        for (int i = 0; i < selected.length; i++) {
          var item = TrackData().tracks[selected.keys.elementAt(i)];
          delTracks.add(item);
        }
        await TrackData().removeTracks(delTracks);
        deselectAll();
      }
    });
  }

  void addFromFile() async {
    //add track mode
    var path = await AudioPicker.pickAudioMultiple();

    for (int i = 0; i < path.length; i++) {
      SongInfo? libSong;

      if (path[i].contains("com.android.providers.media")) {
        var spl = path[i].split("%3A");
        if (spl.length < 2) continue;
        var id = path[i].split("%3A")[1];
        for (var s = 0; s < (songList?.length ?? 0); s++) {
          if (songList![s].id == id) {
            libSong = songList![s];
            break;
          }
        }
      } else {
        //find song in media library
        String file = basename(path[i]);

        for (var s = 0; s < (songList?.length ?? 0); s++) {
          if (songList![s].filePath.contains(file)) {
            libSong = songList![s];
            break;
          }
        }
      }

      if (libSong != null) {
        var name = libSong.artist != "<unknown>"
            ? "${libSong.artist} - ${libSong.title}"
            : libSong.title;

        TrackData().addTrack(libSong.uri, name);
      }
      //clear filter and scroll to bottom
      searchCtrl.text = "";
      setState(() {});
    }
    _scollToNewSongs();
  }

  void addFromMediaLibrary(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MediaLibraryBrowser()))
        .then((value) {
      if (value is List<SongInfo>) {
        for (int i = 0; i < value.length; i++) {
          var name = value[i].artist != "<unknown>"
              ? "${value[i].artist} - ${value[i].title}"
              : value[i].title;
          TrackData().addTrack(value[i].uri, name);
        }
        //clear filter and scroll to bottom
        searchCtrl.text = "";
        setState(() {});
        _scollToNewSongs();
      }
    });
  }

  void addFromOnlineSource(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => OnlineSourceSearch()))
        .then((value) {
      if (value is List<OnlineTrack>) {
        for (int i = 0; i < value.length; i++) {
          var name = "${value[i].artist} - ${value[i].title}";
          TrackData().addTrack(value[i].url, name);
        }
        //clear filter and scroll to bottom
        searchCtrl.text = "";
        setState(() {});
        _scollToNewSongs();
      }
    });
  }

  void _scollToNewSongs() async {
    await Future.delayed(Duration(milliseconds: 300));
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeInCubic);
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
      child: Stack(
        children: [
          Column(
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
                                  style:
                                      Theme.of(context).textTheme.bodyText1)),
                          ListView.builder(
                            controller: scrollController,
                            itemCount: TrackData().tracks.length,
                            itemBuilder: (context, index) {
                              if (filter != "" &&
                                  !TrackData()
                                      .tracks[index]
                                      .name
                                      .toLowerCase()
                                      .contains(filter))
                                return const SizedBox();
                              return ListTile(
                                selected: multiselectMode &&
                                    selected.containsKey(index),
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
                                    editTrack(
                                        context, TrackData().tracks[index]);
                                },
                                onLongPress: () => multiselectHandler(index),
                                trailing: createTrailingWidget(context, index),
                              );
                            },
                          ),
                        ],
                      ),
                      if (!widget.selectorOnly)
                        FloatingActionBubble(
                          // Menu items
                          items: [
                            // Floating action menu item
                            if (kDebugMode)
                              Bubble(
                                title: "Online Source",
                                iconColor: Colors.white,
                                bubbleColor: Colors.blue,
                                icon: Icons.cloud,
                                titleStyle: TextStyle(
                                    fontSize: 16, color: Colors.white),
                                onPress: () {
                                  _animationController.reverse();
                                  addFromOnlineSource(context);
                                },
                              ),
                            Bubble(
                              title: "Media Library",
                              iconColor: Colors.white,
                              bubbleColor: Colors.blue,
                              icon: Icons.library_music,
                              titleStyle:
                                  TextStyle(fontSize: 16, color: Colors.white),
                              onPress: () {
                                _animationController.reverse();
                                addFromMediaLibrary(context);
                              },
                            ),
                            //Floating action menu item
                            Bubble(
                              title: "File Browser",
                              iconColor: Colors.white,
                              bubbleColor: Colors.blue,
                              icon: Icons.folder,
                              titleStyle:
                                  TextStyle(fontSize: 16, color: Colors.white),
                              onPress: () {
                                _animationController.reverse();
                                addFromFile();
                              },
                            ),
                          ],

                          // animation controller
                          animation: _animation,

                          // On pressed change animation state
                          onPress: () {
                            if (multiselectMode) {
                              deleteSelected(context);
                            } else
                              _animationController.isCompleted
                                  ? _animationController.reverse()
                                  : _animationController.forward();
                          },

                          // Floating Action button Icon color
                          iconColor: Colors.white,

                          // Flaoting Action button Icon
                          iconData: multiselectMode ? Icons.delete : Icons.add,
                          backGroundColor: Colors.blue,
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
