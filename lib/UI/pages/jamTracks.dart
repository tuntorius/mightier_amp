// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

//import 'package:audio_picker/audio_picker.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/audio/setlistsPage.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';
import 'package:mighty_plug_manager/audio/tracksPage.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

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

    cntrl.addListener(() {
      if (cntrl.index == 0) setState(() {});
    });

    PresetsStorage().waitLoading().then((value) {
      TrackData().waitLoading().then((value) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cntrl.dispose();
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

  Widget showSetlists(bool hasTracks) {
    if (hasTracks) return Setlists();
    return Stack(
      children: [
        Setlists(),
        TextButton(
          child: Center(child: Text("")),
          onPressed: () {
            cntrl.index = 1;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasTracks = TrackData().tracks.length > 0;

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
                    tabs: [Tab(text: "Setlists"), Tab(text: "Tracks")],
                    controller: cntrl,
                  ),
                  Expanded(
                    child: TabBarView(
                        controller: cntrl,
                        children: [showSetlists(hasTracks), TracksPage()]),
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
