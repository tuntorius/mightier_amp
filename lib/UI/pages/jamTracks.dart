// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

//import 'package:audio_picker/audio_picker.dart';
import 'dart:io';

import 'package:audio_picker/audio_picker.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';
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

  @override
  void initState() {
    super.initState();
    cntrl = TabController(length: 2, vsync: this);
  }

  void checkPermission() async {
    var status = await Permission.camera.status;
    print("Camera $status");
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
              break;
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AudioEditor(
                                          TrackData().tracks[index].path)));
                                },
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
                      Text("TODO")
                    ]),
                  ),
                ],
              );
              break;
            default:
              return Text("Permission declined");

              break;
          }
        }
        return Text("Unknown status");
      },
    );
  }
}
