import 'package:audio_picker/audio_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/UI/widgets/fabMenu.dart';
import 'package:mighty_plug_manager/UI/widgets/common/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/UI/widgets/common/searchTextField.dart';
import 'package:mighty_plug_manager/audio/setlist_player/setlistPlayerState.dart';
import 'package:mighty_plug_manager/audio/widgets/media_library/media_browse.dart';
import 'package:path/path.dart';
import '../platform/platformUtils.dart';
import '../platform/simpleSharedPrefs.dart';
import 'audioEditor.dart';
import 'models/jamTrack.dart';
import 'online_sources/YoutubeSource.dart';
import 'online_sources/onlineTrack.dart';
import 'trackdata/trackData.dart';
import 'widgets/online_source/online_source.dart';
import 'widgets/online_source/search_screen.dart';

class TracksPage extends StatefulWidget {
  final bool selectorOnly;
  final Function(JamTrack)? onSelectedTrack;
  final Function(bool, Map<int, bool>)? multiSelectState;

  const TracksPage(
      {Key? key,
      this.selectorOnly = false,
      this.onSelectedTrack,
      this.multiSelectState})
      : super(key: key);

  @override
  State createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage>
    with SingleTickerProviderStateMixin {
  //search (filter) stuff
  String filter = "";
  final TextEditingController searchCtrl = TextEditingController(text: "");
  final scrollController = ScrollController();
  bool _showHiddenSources = false;

  //multiselection stuff
  bool _multiselectMode = false;

  //menu anim
  late Animation<double> _animation;
  late AnimationController _animationController;
  static List<SongModel>? songList;

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
          const Text("Edit"),
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
            SetlistPlayerState.instance().onTrackRemoved(item.uuid);
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
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    _showHiddenSources =
        SharedPrefs().getInt(SettingsKeys.hiddenSources, 0) != 0 || kDebugMode;
    querySongs();
  }

  void querySongs() async {
    if (songList != null) return;
    if (PlatformUtils.isAndroid) {
      final OnAudioQuery audioQuery = OnAudioQuery();
      songList = await audioQuery.querySongs();
    }
  }

  void multiselectHandler(int index) {
    if (selected.isEmpty || !selected.containsKey(index)) {
      //fill it first if not created
      selected[index] = true;
      multiselectMode = true;
    } else {
      selected.remove(index);
      if (selected.isEmpty) multiselectMode = false;
    }
    setState(() {});
  }

  void deselectAll() {
    selected.clear();
    multiselectMode = false;
    setState(() {});
  }

  void stopPlayer() {
    SetlistPlayerState.instance().stop();
  }

  void editTrack(BuildContext context, JamTrack track) {
    stopPlayer();
    Navigator.of(context, rootNavigator: true)
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
        confirmColor: Theme.of(context).hintColor,
        onConfirm: (newName) {
          track.name = newName;
          TrackData().saveTracks();
          setState(() {});
        });
  }

  Widget? createTrailingWidget(BuildContext context, int index) {
    if (multiselectMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: Icon(
          selected.containsKey(index)
              ? Icons.check_circle
              : Icons.brightness_1_outlined,
          color: selected.containsKey(index) ? null : Colors.grey[800],
        ),
      );
    }

    if (widget.selectorOnly) return null;
    return PopupMenuButton(
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: Icon(Icons.more_vert),
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
          SetlistPlayerState.instance().onTrackRemoved(item.uuid);
        }
        await TrackData().removeTracks(delTracks);
        deselectAll();
      }
    });
  }

  Future _processMediaList(List<String> urls) async {
    for (int i = 0; i < urls.length; i++) {
      await _processFileUrl(urls[i]);
      //clear filter and scroll to bottom
      searchCtrl.text = "";
      setState(() {});
    }
    if (urls.isNotEmpty) {
      TrackData().saveTracks();
      _scrollToNewSongs();
    }
  }

  void addFromFile() async {
    //add track mode
    var path = await AudioPicker.pickAudioMultiple();
    await _processMediaList(path);
  }

  void addFromIosFile() async {
    var path = await AudioPicker.pickAudioFiles();
    await _processMediaList(path);
  }

  Future _processFileUrl(String path) async {
    SongModel? libSong;

    if (PlatformUtils.isAndroid &&
        path.contains("com.android.providers.media")) {
      var spl = path.split("%3A");
      if (spl.length < 2) return;
      var id = int.tryParse(path.split("%3A")[1]);
      if (id != null) {
        for (var s = 0; s < (songList?.length ?? 0); s++) {
          if (songList![s].id == id) {
            libSong = songList![s];
            break;
          }
        }
      }
    } else {
      //find song in media library
      String file = basename(path);

      for (var s = 0; s < (songList?.length ?? 0); s++) {
        if (songList![s].uri?.contains(file) ?? false) {
          libSong = songList![s];
          break;
        }
      }
    }

    String artist = "";
    String title = "";
    String trackName = "";
    String url = "";
    if (libSong != null) {
      artist = libSong.artist != null ? "" : libSong.artist!;
      title = libSong.title;
      url = libSong.uri ?? "";
    } else {
      var meta = await AudioPicker.getMetadata(path);
      artist = meta["artist"]?.trim() ?? "";
      title = meta["title"]?.trim() ?? "";
      url = path;
    }

    trackName = artist.isEmpty || title.isEmpty ? artist + title : "$artist - $title";

    if (url.isEmpty) {
      url = path;
    }
    if (trackName.isEmpty) {
      trackName = Uri.decodeComponent(basenameWithoutExtension(path));
    }

    TrackData().addTrack(url, trackName, false);
  }

  void addFromMediaLibrary(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
            builder: (context) => const MediaLibraryBrowser()))
        .then((value) {
      if (value is List<SongModel>) {
        for (int i = 0; i < value.length; i++) {
          var name = value[i].artist != "<unknown>"
              ? "${value[i].artist} - ${value[i].title}"
              : value[i].title;
          TrackData().addTrack(value[i].uri ?? "", name, false);
        }
        TrackData().saveTracks();
        //clear filter and scroll to bottom
        searchCtrl.text = "";
        setState(() {});
        _scrollToNewSongs();
      }
    });
  }

  void addFromOnlineSource(BuildContext context) {
    stopPlayer();
    Navigator.of(context, rootNavigator: true)
        .push(
            MaterialPageRoute(builder: (context) => const OnlineSourceSearch()))
        .then((value) {
      if (value is List<OnlineTrack>) {
        for (int i = 0; i < value.length; i++) {
          var name = "${value[i].artist} - ${value[i].title}";
          TrackData().addTrack(value[i].url, name, false);
        }
        TrackData().saveTracks();
        //clear filter and scroll to bottom
        searchCtrl.text = "";
        setState(() {});
        _scrollToNewSongs();
      }
    });
  }

  void addFromYoutubeSource(BuildContext context) {
    stopPlayer();
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(
            builder: (context) => OnlineSearchScreen(source: YoutubeSource())))
        .then((value) {
      if (value is List<OnlineTrack>) {
        for (int i = 0; i < value.length; i++) {
          var name = "${value[i].artist} - ${value[i].title}";
          TrackData().addTrack(value[i].url, name, false);
        }
        TrackData().saveTracks();
        //clear filter and scroll to bottom
        searchCtrl.text = "";
        setState(() {});
        _scrollToNewSongs();
      }
    });
  }

  void _scrollToNewSongs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInCubic);
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
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            if (TrackData().tracks.isNotEmpty)
              SearchTextField(controller: searchCtrl),
            Expanded(
              child: ListTileTheme(
                selectedTileColor: const Color.fromARGB(255, 9, 51, 116),
                selectedColor: Colors.white,
                child: IndexedStack(
                  index: TrackData().tracks.isEmpty ? 0 : 1,
                  children: [
                    Center(
                        child: Text("No Tracks",
                            style: Theme.of(context).textTheme.bodyText1)),
                    ListView.builder(
                      controller: scrollController,
                      itemCount: TrackData().tracks.length,
                      padding: const EdgeInsets.only(bottom: 90),
                      itemBuilder: (context, index) {
                        if (filter != "" &&
                            !TrackData()
                                .tracks[index]
                                .name
                                .toLowerCase()
                                .contains(filter)) return const SizedBox();
                        return ListTile(
                          contentPadding: const EdgeInsets.only(left: 12),
                          selected:
                              multiselectMode && selected.containsKey(index),
                          title: Text(TrackData().tracks[index].name),
                          onTap: () {
                            if (multiselectMode) {
                              multiselectHandler(index);
                              return;
                            }
                            if (widget.selectorOnly) {
                              widget.onSelectedTrack
                                  ?.call(TrackData().tracks[index]);
                            } else {
                              editTrack(context, TrackData().tracks[index]);
                            }
                          },
                          onLongPress: () => multiselectHandler(index),
                          trailing: createTrailingWidget(context, index),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: (widget.selectorOnly)
            ? null
            : FloatingActionBubble(
                // Menu items
                items: _bubbles(context),

                // animation controller
                animation: _animation,

                // On pressed change animation state
                onPress: () {
                  if (multiselectMode) {
                    deleteSelected(context);
                  } else if (PlatformUtils.isIOS && !_showHiddenSources) {
                    addFromFile();
                  } else {
                    _animationController.isCompleted
                        ? _animationController.reverse()
                        : _animationController.forward();
                  }
                },

                // Floating Action button Icon color
                iconColor: Colors.white,

                // Flaoting Action button Icon
                iconData: multiselectMode ? Icons.delete : Icons.add,
                backGroundColor: Colors.blue,
              ),
      ),
    );
  }

  List<Bubble> _bubbles(BuildContext context) {
    return [
      // Floating action menu item
      if (_showHiddenSources)
        Bubble(
            title: "Youtube",
            iconColor: Colors.white,
            bubbleColor: Colors.red,
            icon: Icons.ondemand_video_outlined,
            titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              _animationController.reverse();
              addFromYoutubeSource(context);
            }),
      if (_showHiddenSources)
        Bubble(
          title: "Online Source",
          iconColor: Colors.white,
          bubbleColor: Colors.blue,
          icon: Icons.cloud,
          titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
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
        titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
        onPress: () {
          _animationController.reverse();
          if (PlatformUtils.isIOS) {
            addFromFile();
          } else {
            addFromMediaLibrary(context);
          }
        },
      ),
      //Floating action menu item
      Bubble(
        title: "File Browser",
        iconColor: Colors.white,
        bubbleColor: Colors.blue,
        icon: Icons.folder,
        titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
        onPress: () {
          _animationController.reverse();
          if (PlatformUtils.isAndroid) {
            addFromFile();
          } else if (PlatformUtils.isIOS) {
            addFromIosFile();
          }
        },
      ),
    ];
  }
}
