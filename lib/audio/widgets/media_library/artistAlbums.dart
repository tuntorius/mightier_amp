// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

import 'albumTracks.dart';

class ArtistAlbums extends StatelessWidget {
  final String artist;
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  ArtistAlbums(this.artist, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Future<List<AlbumInfo>> album =
        audioQuery.getAlbumsFromArtist(artist: artist);
    return Scaffold(
      appBar: AppBar(title: Text("$artist albums")),
      body: FutureBuilder<List<AlbumInfo>>(
        future: album,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              // TODO: Handle this case.
              break;
            case ConnectionState.waiting:
              // TODO: Handle this case.
              break;
            case ConnectionState.active:
              // TODO: Handle this case.
              break;
            case ConnectionState.done:
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: ListTile(
                          onTap: () async {
                            var result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => AlbumTracks(
                                        snapshot.data![index].title,
                                        snapshot.data![index].id,
                                        snapshot.data![index].artist)));
                            if (result != null)
                              Navigator.of(context).pop(result);
                          },
                          title: Text(
                            snapshot.data![index].title,
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
