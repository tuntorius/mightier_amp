// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

//import 'package:audio_picker/audio_picker.dart';
import 'package:audio_picker/audio_picker.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/audio/models/jamTrack.dart';
import 'package:mighty_plug_manager/audio/setlists.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:path/path.dart';
import 'package:mighty_plug_manager/audio/audioEditor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audiotagger/audiotagger.dart';

class JamTracks extends StatefulWidget {
  @override
  _JamTracksState createState() => _JamTracksState();
}

class _JamTracksState extends State<JamTracks> with TickerProviderStateMixin {
  late TabController cntrl;

  var popupSubmenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: 0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.grey[400],
          ),
          SizedBox(width: 5),
          Text("Delete"),
        ],
      ),
    )
  ];

  @override
  void initState() {
    super.initState();
    cntrl = TabController(length: 2, vsync: this);

    Stopwatch stopwatch = new Stopwatch()..start();
    PresetsStorage().waitLoading().then((value) {
      print('preload executed in ${stopwatch.elapsed}');
      TrackData().waitLoading().then((value) {
        print('load executed in ${stopwatch.elapsed}');
        setState(() {});
      });
    });
  }

  void checkPermission() async {
    var status = await Permission.camera.status;
    print("Camera $status");
  }

  void menuActions(BuildContext context, int action, JamTrack item) async {
    switch (action) {
      case 0: //delete
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

  //try to get best version of tags (mp3 only)
  //if not - use filename but strip the extension
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
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
      future: Permission.storage.status,
      builder:
          (BuildContext context, AsyncSnapshot<PermissionStatus> snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.data) {
            case PermissionStatus.denied:
              return Center(
                child: ElevatedButton(
                  child: Text("Grant storage permission"),
                  onPressed: () async {
                    await Permission.storage.request();
                    setState(() {});
                  },
                ),
              );
            case PermissionStatus.granted:
              return Column(
                children: [
                  TabBar(
                    tabs: [Tab(text: "Tracks"), Tab(text: "Setlists")],
                    controller: cntrl,
                  ),
                  Expanded(
                    child: TabBarView(controller: cntrl, children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ListView.builder(
                            itemCount: TrackData().tracks.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(TrackData().tracks[index].name),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => AudioEditor(
                                              TrackData().tracks[index])))
                                      .then((value) {
                                    //save track data
                                    TrackData().saveTracks();
                                  });
                                },
                                trailing: PopupMenuButton(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
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
                                        TrackData().tracks[index]);
                                  },
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: FloatingActionButton(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              onPressed: () async {
                                var path =
                                    await AudioPicker.pickAudioMultiple();
                                print(path);
                                final tagger = new Audiotagger();
                                for (int i = 0; i < path.length; i++) {
                                  var name = basenameWithoutExtension(path[i]);

                                  //audiotagger
                                  Map? tags =
                                      await tagger.readTagsAsMap(path: path[i]);

                                  name = getProperTags(tags, name);
                                  TrackData().addTrack(path[i], name);

                                  setState(() {});
                                }
                              },
                              child: Icon(
                                Icons.add,
                                size: 28,
                                //style: TextStyle(fontSize: 28),
                              ),
                            ),
                          )
                        ],
                      ),
                      Setlists()
                    ]),
                  ),
                ],
              );
            default:
              return Text("Permission declined");
          }
        }
        return Text("Unknown status");
      },
    );
  }
}
