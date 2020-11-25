// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
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
            case PermissionStatus.undetermined:
              return Center(
                child: RaisedButton(
                  child: Text("Grant storage permission"),
                  onPressed: () {
                    Permission.storage.request();
                  },
                ),
              );
              break;
            case PermissionStatus.granted:
              return Container(child: Center(child: AudioPlayerInterface()));
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
