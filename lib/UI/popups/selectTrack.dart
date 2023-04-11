// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/audio/models/jamTrack.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';
import 'package:mighty_plug_manager/audio/tracksPage.dart';

class SelectTrackDialog {
  bool _multiselect = false;
  Map<int, bool> _selected = {};

  Widget buildDialog(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        contentPadding: const EdgeInsets.only(bottom: 20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                icon: Icon(
                  Icons.adaptive.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop()),
            Expanded(
                child: _multiselect
                    ? Text("${_selected.length} selected")
                    : const Text('Select Track')),
            if (_multiselect)
              ElevatedButton(
                child: const Text("Add"),
                onPressed: () {
                  List<JamTrack> tracks = [];
                  for (int i = 0; i < _selected.length; i++) {
                    tracks.add(TrackData().tracks[_selected.keys.elementAt(i)]);
                  }
                  Navigator.of(context).pop(tracks);
                },
              )
          ],
        ),
        content: TracksPage(
          selectorOnly: true,
          onSelectedTrack: (track) {
            Navigator.of(context).pop(track);
          },
          multiSelectState: (bool state, Map<int, bool> selected) {
            _multiselect = state;
            _selected = selected;
            setState(() {});
          },
        ),
      );
    });
  }
}
