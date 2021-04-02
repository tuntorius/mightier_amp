import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/selectTrack.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/UI/widgets/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/audio/automationController.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'models/jamTrack.dart';
import 'models/setlist.dart';
import 'trackdata/trackData.dart';
import 'widgets/setlistPlayer.dart';

class SetlistPage extends StatefulWidget {
  final Setlist setlist;
  final bool readOnly;

  SetlistPage({required this.setlist, required this.readOnly});
  @override
  _SetlistPageState createState() => _SetlistPageState();
}

class _SetlistPageState extends State<SetlistPage> {
  //player state
  bool playerExpanded = false;
  int currentTrack = 0;
  final animationDuration = const Duration(milliseconds: 200);
  AutomationController? _automation;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _automation?.dispose();
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
        value.forEach((element) {
          widget.setlist.addTrack(element);
        });
      } else
        widget.setlist.addTrack(value);

      TrackData().saveSetlists();
      setState(() {});
    });
  }

  void openTrack(JamTrack track) {
    if (_automation != null) {
      _automation!.dispose();
    }

    _automation = AutomationController(track.automation);
    _automation?.setAudioFile(track.path, 500);

    _automation?.play();
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
                iconColor: Colors.white,
                child: IndexedStack(
                  index: widget.setlist.items.length > 0 ? 0 : 1,
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
                                  currentTrack = index;
                                  var track = widget
                                      .setlist.items[index].trackReference;
                                  if (track != null)
                                    openTrack(widget
                                        .setlist.items[index].trackReference!);
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    if (!widget.readOnly)
                                      ReorderableDragStartListener(
                                        child: InkWell(
                                          child: Container(
                                            width:
                                                AppThemeConfig.dragHandlesWidth,
                                            height: 48,
                                            child: Icon(
                                              Icons.drag_handle,
                                              color: Colors.grey,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        index: index,
                                      ),
                                    Expanded(
                                      child: ListTile(
                                        contentPadding: EdgeInsets.only(
                                            left: widget.readOnly ? 16 : 0,
                                            right: 16),
                                        title: Text(widget.setlist.items[index]
                                            .trackReference!.name),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          onReorder: (int oldIndex, int newIndex) {
                            if (oldIndex < newIndex) {
                              // removing the item at oldIndex will shorten the list by 1.
                              newIndex -= 1;
                            }
                            final element =
                                widget.setlist.items.removeAt(oldIndex);
                            widget.setlist.items.insert(newIndex, element);
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
                  onPressed: playerExpanded ? collapse : addTrack,
                  child: Icon(
                    Icons.add,
                    size: 28,
                  ),
                ),
              ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            //expand only
            if (playerExpanded) return;
            setState(() {
              playerExpanded = !playerExpanded;
            });
          },
          //AnimatedSwitcher
          child: SetlistPlayer(
            duration: animationDuration,
            setlist: widget.setlist,
            index: currentTrack,
            expanded: playerExpanded,
          ),
        ),
      ),
    );
  }
}
