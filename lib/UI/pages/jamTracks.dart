// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:audio_picker/audio_picker.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/audio/audioEditor.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../audio/audioPlayer.dart';

class JamTracks extends StatefulWidget {
  @override
  _JamTracksState createState() => _JamTracksState();
}

class _JamTracksState extends State<JamTracks> {
  @override
  void initState() {
    super.initState();
  }

  void checkPermission() async {
    var status = await Permission.camera.status;
    print("Camera $status");
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
            case PermissionStatus.undetermined:
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
                  ElevatedButton(
                      onPressed: () async {
                        var path = await AudioPicker.pickAudio();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AudioEditor(path)));
                      },
                      child: Text("Try audio browse")),
                  Expanded(child: AudioPlayerInterface()),
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
