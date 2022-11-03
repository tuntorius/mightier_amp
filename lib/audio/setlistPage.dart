import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/UI/popups/selectTrack.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/UI/widgets/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/audio/automationController.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'models/setlist.dart';
import 'trackdata/trackData.dart';
import 'widgets/setlistPlayer.dart';

enum PlayerState { idle, play, pause }

class SetlistPlayerState extends ChangeNotifier {
  PlayerState state = PlayerState.idle;
  Setlist setlist;
  int currentTrack = 0;
  Duration currentPosition = const Duration(seconds: 0);
  bool _autoAdvance = true;
  bool _inPositionUpdateMode = false;

  int _pitch = 1;
  double _speed = 1;

  int get pitch => _pitch;
  set pitch(val) {
    _pitch = val;
    notifyListeners();
  }

  double get speed => _speed;
  set speed(val) {
    _speed = val;
    notifyListeners();
  }

  AutomationController? get automation => _automation;

  bool get autoAdvance => _autoAdvance;
  set autoAdvance(bool val) {
    _autoAdvance = val;
    notifyListeners();
  }

  AutomationController? _automation;

  SetlistPlayerState({required this.setlist}) {
    if (setlist.items.isNotEmpty) openTrack(0);
  }

  Future openTrack(int index) async {
    currentTrack = index;
    var track = setlist.items[index].trackReference;
    if (track != null) {
      _automation = AutomationController(track, track.automation);
      await _automation?.setAudioFile(track.path, 2000);
      _automation?.setTrackCompleteEvent(_onTrackComplete);
      _automation?.positionStream.listen(_onPosition);
      pitch = _automation?.pitch ?? 1;
      speed = _automation?.speed ?? 1;
    }
  }

  Future play() async {
    await _automation?.play();
    state = PlayerState.play;
    notifyListeners();
  }

  Future playPause() async {
    if (_automation == null) await openTrack(currentTrack);
    await _automation?.playPause();
    if (_automation!.player.playerState.playing == false) {
      state = PlayerState.pause;
    } else {
      state = PlayerState.play;
    }
    debugPrint(state.toString());
    notifyListeners();
  }

  void previous() async {
    if (_automation == null) return;
    if (currentTrack == 0 || _automation!.player.position.inSeconds > 2) {
      _automation!.rewind();
    } else if (currentTrack > 0) {
      await closeTrack();
      currentTrack--;
      await openTrack(currentTrack);
      if (state == PlayerState.play) await play();
    }

    notifyListeners();
  }

  void next() async {
    if (currentTrack < setlist.items.length - 1) {
      await closeTrack();
      currentTrack++;
      await openTrack(currentTrack);
      if (state == PlayerState.play) await play();
      notifyListeners();
    }
  }

  Future? closeTrack() {
    return _automation?.dispose();
  }

  void _onPosition(Duration pos) {
    if (!_inPositionUpdateMode) currentPosition = pos;
    notifyListeners();
  }

  String getMMSS(Duration d) {
    var m = d.inMinutes.toString().padLeft(2, "0");
    var s = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$m:$s";
  }

  Duration getDuration() {
    return _automation?.duration ?? const Duration(seconds: 0);
  }

  void setPosition(int positionMS) {
    currentPosition = Duration(milliseconds: positionMS);
    _automation?.seek(currentPosition);
    notifyListeners();
  }

  void setPositionUpdateMode(bool enabled) {
    _inPositionUpdateMode = enabled;
    if (!enabled) _automation?.seek(currentPosition);
  }

  void _onTrackComplete() async {
    await closeTrack();
    currentPosition = const Duration(milliseconds: 0);
    if (currentTrack < setlist.items.length - 1) {
      currentTrack++;
      await openTrack(currentTrack);
      if (_autoAdvance) {
        await play();
        state = PlayerState.play;
      } else {
        state = PlayerState.pause;
      }
    } else {
      await openTrack(currentTrack);
      currentTrack = 0;
      state = PlayerState.pause;
    }
    notifyListeners();
  }
}

class SetlistPage extends StatefulWidget {
  final Setlist setlist;
  final bool readOnly;

  const SetlistPage({required this.setlist, required this.readOnly});
  @override
  State createState() => _SetlistPageState();
}

class _SetlistPageState extends State<SetlistPage> {
  static const int expandThreshold = 20;
  bool playerExpanded = false;
  final animationDuration = const Duration(milliseconds: 200);

  late SetlistPlayerState playerState;

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

  @override
  void initState() {
    super.initState();

    playerState = SetlistPlayerState(setlist: widget.setlist);
    playerState.addListener(onPlayerStateChange);
  }

  @override
  void dispose() {
    super.dispose();
    playerState.closeTrack();
    playerState.removeListener(onPlayerStateChange);
  }

  void onPlayerStateChange() {
    setState(() {});
  }

  void collapse() {
    setState(() {
      playerExpanded = false;
    });
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

  void openTrack(int setlistIndex) async {
    await playerState.closeTrack();

    await playerState.openTrack(setlistIndex);

    await playerState.play();
    setState(() {});
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
      onWillPop: () {
        //collapse player if extended
        if (playerExpanded) {
          collapse();
          return Future.value(false);
        }

        if (_multiselectMode) {
          deselectAll();
          return Future.value(false);
        }

        NuxDeviceControl.instance().resetToChannelDefaults();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.setlist.name),
        ),
        body: AnimatedOpacity(
          duration: animationDuration,
          opacity: playerExpanded ? 0.2 : 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ListTileTheme(
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
                                  playerState.currentTrack = index;
                                  var track = widget
                                      .setlist.items[index].trackReference;
                                  if (track != null) openTrack(index);
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
                            var currentItem = playerState
                                .setlist.items[playerState.currentTrack];
                            if (oldIndex < newIndex) {
                              // removing the item at oldIndex will shorten the list by 1.
                              newIndex -= 1;
                            }
                            final element =
                                widget.setlist.items.removeAt(oldIndex);
                            widget.setlist.items.insert(newIndex, element);

                            playerState.currentTrack =
                                playerState.setlist.items.indexOf(currentItem);

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
              if (playerExpanded)
                GestureDetector(
                  onTap: collapse,
                )
            ],
          ),
        ),
        floatingActionButton: widget.readOnly
            ? null
            : AnimatedOpacity(
                duration: animationDuration,
                opacity: playerExpanded ? 0.0 : 1.0,
                child: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  onPressed: playerExpanded
                      ? collapse
                      : () {
                          if (_multiselectMode) {
                            //delete mode
                            AlertDialogs.showConfirmDialog(context,
                                title: "Confirm",
                                description:
                                    "Are you sure you want to remove ${selected.length} items?",
                                cancelButton: "Cancel",
                                confirmButton: "Delete",
                                confirmColor: Colors.red,
                                onConfirm: (delete) async {
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
        bottomNavigationBar: widget.setlist.items.isEmpty
            ? null
            : GestureDetector(
                onVerticalDragStart: (details) {
                  dragStart = details.globalPosition;
                },
                onVerticalDragUpdate: (details) {
                  Offset delta = details.globalPosition - dragStart;
                  if (delta.dy < -expandThreshold && !playerExpanded) {
                    setState(() {
                      playerExpanded = true;
                    });
                  } else if (delta.dy > expandThreshold && playerExpanded) {
                    setState(() {
                      playerExpanded = false;
                    });
                  }
                },
                onTap: () {
                  //expand only
                  if (playerExpanded) return;
                  setState(() {
                    playerExpanded = !playerExpanded;
                  });
                },
                //AnimatedSwitcher
                child: SetlistPlayer(
                  state: playerState,
                  duration: animationDuration,
                  expanded: playerExpanded,
                ),
              ),
      ),
    );
  }
}
