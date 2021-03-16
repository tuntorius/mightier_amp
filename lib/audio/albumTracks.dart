// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

/*
import 'package:flutter/material.dart';

class AlbumTracks extends StatelessWidget {
  final String albumId;
  final String albumName;
  final String artist;
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  AlbumTracks({this.albumId, this.albumName, this.artist});
  @override
  Widget build(BuildContext context) {
    Future<List<SongInfo>> songs =
        audioQuery.getSongsFromArtistAlbum(albumId: albumId, artist: artist);
    return Scaffold(
      appBar: AppBar(title: Text("$albumName tracks")),
      body: FutureBuilder<List<SongInfo>>(
        future: songs,
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
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: ElevatedButton(
                          //color: Colors.grey[700],
                          onPressed: () {
                            //pop with selected song
                            Navigator.of(context).pop(snapshot.data[index]);
/*
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AudioEditor(
                                    snapshot.data[index].filePath)));*/
                          },
                          child: Text(
                            snapshot.data[index].title,
                            style: TextStyle(color: Colors.white),
                          )),
                    );
                  });
              break;
          }
          return Text("Loading...");
        },
      ),
    );
  }
}
*/