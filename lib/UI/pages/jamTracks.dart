// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

//import 'package:audio_picker/audio_picker.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:mighty_plug_manager/audio/audioEditor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dart_tags/dart_tags.dart';

class JamTrack {
  String name;
  String path;
}

class JamTracks extends StatefulWidget {
  @override
  _JamTracksState createState() => _JamTracksState();
}

class _JamTracksState extends State<JamTracks> with TickerProviderStateMixin {
  TabController cntrl;

  static List<JamTrack> files = <JamTrack>[];

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
  String getProperTags(List<Tag> tags, String filename) {
    String title, artist;
    for (int i = 0; i < tags.length; i++) {
      if (tags[i].version[0] == '2') {
        if (tags[i].tags["artist"] != null) artist = tags[i].tags["artist"];
        if (tags[i].tags["title"] != null) title = tags[i].tags["title"];
      } else {
        if (tags[i].tags["artist"] != null && artist == null)
          artist = tags[i].tags["artist"];
        if (tags[i].tags["title"] != null && artist == null)
          title = tags[i].tags["title"];
      }
    }
    if (artist != null || title != null) {
      return "$artist - $title";
    }

    return basenameWithoutExtension(filename);
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
                          ListView(
                            children: [
                              for (var i = 0; i < files.length; i++)
                                ListTile(
                                  title: Text(files[i].name),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AudioEditor(files[i].path)));
                                  },
                                )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: FloatingActionButton(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              onPressed: () async {
                                var path = await FilePicker.platform.pickFiles(
                                    type: FileType.audio,
                                    allowMultiple: true,
                                    withData: false,
                                    withReadStream: false);

                                for (int i = 0; i < path.names.length; i++) {
                                  var jt = JamTrack();
                                  jt.name = path.names[i];
                                  jt.path = path.paths[i];
                                  // var tp = TagProcessor();
                                  // var f = new File(jt.path);
                                  // var tags = await tp
                                  //     .getTagsFromByteArray(f.readAsBytes());
                                  // jt.name = getProperTags(tags, jt.name);
                                  files.add(jt);
                                }
                                setState(() {});
                              },
                              child: Text(
                                "+",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                      Text("Tab2")
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
