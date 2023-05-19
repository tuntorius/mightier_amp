// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'albumTracks.dart';

class ArtistAlbums extends StatelessWidget {
  final String artist;
  final int artistId;
  final OnAudioQuery audioQuery = OnAudioQuery();
  ArtistAlbums(this.artist, {Key? key, required this.artistId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    Future<List> album = audioQuery.queryWithFilters(
        artist, WithFiltersType.ALBUMS,
        args: AlbumsArgs.ARTIST);

    //Future<List<AlbumModel>> album =
    //    audioQuery.getAlbumsFromArtist(artist: artist);
    return Scaffold(
      appBar: AppBar(title: Text("$artist albums")),
      body: FutureBuilder<List<dynamic>>(
        future: album,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              break;
            case ConnectionState.active:
              break;
            case ConnectionState.done:
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    var albums = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: ListTile(
                          onTap: () async {
                            var result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => AlbumTracks(
                                        albums[index]["album"],
                                        albums[index]["album_id"],
                                        albums[index]["artist"] ?? "")));
                            if (result != null) {
                              Navigator.of(context).pop(result);
                            }
                          },
                          title: Text(
                            snapshot.data![index]["album"],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right)),
                    );
                  });
          }
          return const Text("Loading...");
        },
      ),
    );
  }
}
