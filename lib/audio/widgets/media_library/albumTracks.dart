// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:mighty_plug_manager/UI/widgets/common/nestedWillPopScope.dart';

class AlbumTracks extends StatefulWidget {
  final String albumName;
  final String albumId;
  final String artist;

  const AlbumTracks(this.albumName, this.albumId, this.artist, {Key? key})
      : super(key: key);

  @override
  State createState() => _AlbumTracksState();
}

class _AlbumTracksState extends State<AlbumTracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  late Future<List<SongInfo>> songs;
  late List<SongInfo> songList;
  bool _multiselectMode = false;
  Map<int, bool> selected = {};

  @override
  void initState() {
    super.initState();
    songs = audioQuery.getSongsFromArtistAlbum(
        albumId: widget.albumId, artist: widget.artist);
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
    if (_multiselectMode) {
      return Icon(
        selected.containsKey(index)
            ? Icons.check_circle
            : Icons.brightness_1_outlined,
        color: selected.containsKey(index) ? null : Colors.grey[800],
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () {
        //collapse player if extended

        if (_multiselectMode) {
          deselectAll();
          return Future.value(false);
        }

        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(title: Text("${widget.albumName} tracks")),
        body: FutureBuilder<List<SongInfo>>(
          future: songs,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                break;
              case ConnectionState.waiting:
                break;
              case ConnectionState.active:
                break;
              case ConnectionState.done:
                songList = snapshot.data!;
                return ListTileTheme(
                  selectedTileColor: const Color.fromARGB(255, 9, 51, 116),
                  selectedColor: Colors.white,
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: ListTile(
                              selected: _multiselectMode &&
                                  selected.containsKey(index),
                              onTap: () {
                                if (_multiselectMode) {
                                  multiselectHandler(index);
                                  return;
                                }
                                //return list of 1 track
                                Navigator.of(context)
                                    .pop([snapshot.data![index]]);
                              },
                              onLongPress: () => multiselectHandler(index),
                              title: Text(
                                snapshot.data![index].title,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: createTrailingWidget(context, index)),
                        );
                      }),
                );
            }
            return const Text("Loading...");
          },
        ),
        floatingActionButton: _multiselectMode && selected.isNotEmpty
            ? FloatingActionButton(
                onPressed: () {
                  List<SongInfo> sel = [];
                  for (int i = 0; i < selected.length; i++) {
                    var index = selected.keys.elementAt(i);
                    if (selected[index] == true) {
                      sel.add(songList[index]);
                    }
                  }
                  Navigator.of(context).pop(sel);
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
