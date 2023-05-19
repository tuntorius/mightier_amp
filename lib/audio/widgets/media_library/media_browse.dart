// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)
//
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'artistAlbums.dart';

class MediaLibraryBrowser extends StatefulWidget {
  const MediaLibraryBrowser({super.key});

  @override
  _MediaLibraryBrowserState createState() => _MediaLibraryBrowserState();
}

class _MediaLibraryBrowserState extends State<MediaLibraryBrowser> {
  final StreamController<String> _refreshController =
      StreamController<String>();

  //Future<List<SongInfo>> songs;
  static List<ArtistModel> artists = [];

  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getArtists(refresh: false);
    editingController.addListener(() {
      setState(() {});
    });
  }

  Future<void> getArtists({bool refresh = true}) async {
    final OnAudioQuery audioQuery = OnAudioQuery();
    if (artists.isEmpty || refresh) artists = await audioQuery.queryArtists();
    _refreshController.add("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Media Library")),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: editingController,
              decoration: const InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
            Expanded(
              child: StreamBuilder<String>(
                stream: _refreshController.stream,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      break;
                    case ConnectionState.waiting:
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      List<ArtistModel> _artists;
                      var searchText = editingController.text.toLowerCase();
                      if (editingController.text.isNotEmpty) {
                        _artists = <ArtistModel>[];
                        artists.forEach((item) {
                          if (item.artist.toLowerCase().contains(searchText)) {
                            _artists.add(item);
                          }
                        });
                      } else {
                        _artists = artists;
                      }

                      return RefreshIndicator(
                        onRefresh: getArtists,
                        child: ListView.builder(
                            itemCount: _artists.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: ListTile(
                                    onTap: () async {
                                      var result = await Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  ArtistAlbums(
                                                      _artists[index].artist,
                                                      artistId:
                                                          _artists[index].id)));
                                      if (result != null) {
                                        Navigator.of(context).pop(result);
                                      }
                                    },
                                    title: Text(
                                      _artists[index].artist,
                                    ),
                                    trailing:
                                        const Icon(Icons.keyboard_arrow_right)),
                              );
                            }),
                      );
                  }
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
