// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
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
  final OnAudioQuery audioQuery = OnAudioQuery();
  late Future<List<SongModel>> songs;
  late List<SongModel> songList;
  bool _multiselectMode = false;
  Map<int, bool> selected = {};

  @override
  void initState() {
    super.initState();
    songs = audioQuery.queryAudiosFrom(AudiosFromType.ALBUM_ID, widget.albumId);
  }

  void multiselectHandler(int index) {
    if (selected.isEmpty || !selected.containsKey(index)) {
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
        color: selected.containsKey(index) ? null : Theme.of(context).disabledColor,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return NestedWillPopScope(
      onWillPop: () {
        if (_multiselectMode) {
          deselectAll();
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(title: Text("${widget.albumName} tracks")),
        body: FutureBuilder<List<SongModel>>(
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
                  selectedTileColor: isDark ? const Color.fromARGB(255, 9, 51, 116) : Colors.blue[100],
                  selectedColor: Theme.of(context).colorScheme.onSurface,
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
                                Navigator.of(context)
                                    .pop([snapshot.data![index]]);
                              },
                              onLongPress: () => multiselectHandler(index),
                              title: Text(
                                snapshot.data![index].title,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
                  List<SongModel> sel = [];
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