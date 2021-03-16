// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'artistAlbums.dart';

/*
class AudioPlayerInterface extends StatefulWidget {
  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayerInterface> {
  AudioPlayer player = AudioPlayer();
  int refreshTime = 1;
  String path = "";

  RangeValues range = new RangeValues(0, 10000);

  //Future<List<SongInfo>> songs;
  Future<List<ArtistInfo>> artists;

  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getArtists();
    editingController.addListener(() {
      setState(() {});
    });
  }

  void getArtists() {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    artists = audioQuery.getArtists();
  }

  void playAudio() async {
    player.dispose();
    player = AudioPlayer();

    setState(() {
      range = new RangeValues(0, 10000);
    });

    await Permission.storage.request().isGranted;
    path = ""; //await AudioPicker.pickAudio();

    await player.setFilePath(path);

    await player.setClip(
        start: Duration(milliseconds: range.start.round()),
        end: Duration(milliseconds: range.end.round()));
    await player.setLoopMode(LoopMode.one);
    //await player.play();

/*
    Duration start = Duration(milliseconds: startPoint),
        end = Duration(milliseconds: endPoint);

    await player.load(
      // Loop child 4 times
      ConcatenatingAudioSource(
        children: [
          // Play a regular media file
          ClippingAudioSource(
            child: ProgressiveAudioSource(Uri.parse(path)),
            start: Duration(milliseconds: 0),
            end: end,
          ),
          ClippingAudioSource(
            child: ProgressiveAudioSource(Uri.parse(path)),
            start: start,
            end: end,
          ),
          ClippingAudioSource(
            child: ProgressiveAudioSource(Uri.parse(path)),
            start: start,
            end: end,
          ),
          ClippingAudioSource(
            child: ProgressiveAudioSource(Uri.parse(path)),
            start: start,
            end: end,
          ),
        ],
      ),
    );
    await player.play();*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Music gallery")),
      body: Container(
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
              Expanded(
                child: FutureBuilder<List<ArtistInfo>>(
                  future: artists,
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
                        // TODO: Handle this case.
                        List<ArtistInfo> _artists;
                        var searchText = editingController.text.toLowerCase();
                        if (editingController.text.isNotEmpty) {
                          _artists = <ArtistInfo>[];
                          snapshot.data.forEach((item) {
                            if (item.name.toLowerCase().contains(searchText)) {
                              _artists.add(item);
                            }
                          });
                        } else
                          _artists = snapshot.data;

                        return ListView.builder(
                            itemCount: _artists.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  ArtistAlbums(
                                                      _artists[index].name)))
                                          .then((value) => {
                                                //check if value send from child page
                                                //and return it to the parent
                                                if (value != null)
                                                  Navigator.of(context)
                                                      .pop(value)
                                              });
                                      ;
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        "${_artists[index].name}",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )),
                              );
                            });
                        break;
                    }
                    return Text("Loading...");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/