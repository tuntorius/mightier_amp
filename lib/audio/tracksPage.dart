import 'package:audio_picker/audio_picker.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:path/path.dart';
import 'audioEditor.dart';
import 'models/jamTrack.dart';
import 'trackdata/trackData.dart';

class TracksPage extends StatefulWidget {
  @override
  _TracksPageState createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
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
    return Stack(
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
                        builder: (context) =>
                            AudioEditor(TrackData().tracks[index])))
                    .then((value) {
                  //save track data
                  TrackData().saveTracks();
                });
              },
              trailing: PopupMenuButton(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 4, bottom: 10, top: 10),
                  child: Icon(Icons.more_vert, color: Colors.grey),
                ),
                itemBuilder: (context) {
                  return popupSubmenu;
                },
                onSelected: (pos) {
                  menuActions(context, pos as int, TrackData().tracks[index]);
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
              var path = await AudioPicker.pickAudioMultiple();
              print(path);
              final tagger = new Audiotagger();
              for (int i = 0; i < path.length; i++) {
                //audiotagger
                Map? tags = await tagger.readTagsAsMap(path: path[i]);

                var name = getProperTags(tags, path[i]);
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
    );
  }
}
