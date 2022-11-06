// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)
//
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

import 'artistAlbums.dart';

class MediaLibraryBrowser extends StatefulWidget {
  @override
  _MediaLibraryBrowserState createState() => _MediaLibraryBrowserState();
}

class _MediaLibraryBrowserState extends State<MediaLibraryBrowser> {
  final StreamController<String> _refreshController =
      StreamController<String>();

  //Future<List<SongInfo>> songs;
  static List<ArtistInfo> artists = [];

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
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    if (artists.isEmpty || refresh) artists = await audioQuery.getArtists();
    print("Artists ready");
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
                      List<ArtistInfo> _artists;
                      var searchText = editingController.text.toLowerCase();
                      if (editingController.text.isNotEmpty) {
                        _artists = <ArtistInfo>[];
                        artists.forEach((item) {
                          if (item.name.toLowerCase().contains(searchText)) {
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
                                                      _artists[index].name)));
                                      if (result != null) {
                                        Navigator.of(context).pop(result);
                                      }
                                    },
                                    title: Text(
                                      _artists[index].name,
                                    ),
                                    trailing:
                                        const Icon(Icons.keyboard_arrow_right)),
                              );
                            }),
                      );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
