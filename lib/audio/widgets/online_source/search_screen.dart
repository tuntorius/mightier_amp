// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)
//

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mighty_plug_manager/UI/widgets/common/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/audio/online_sources/onlineSource.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mighty_plug_manager/audio/online_sources/onlineTrack.dart';

class OnlineSearchScreen extends StatefulWidget {
  final OnlineSource source;

  const OnlineSearchScreen({Key? key, required this.source}) : super(key: key);

  @override
  State createState() => _OnlineSearchScreenState();
}

class _OnlineSearchScreenState extends State<OnlineSearchScreen> {
  List<OnlineTrack> tracks = [];
  bool loading = false;

  TextEditingController editingController = TextEditingController();

  AudioPlayer? player;
  int? playedTrack;

  //multiselection
  bool _multiselectMode = false;
  Map<int, bool> selected = {};

  @override
  void initState() {
    super.initState();

    editingController.addListener(() {
      setState(() {});
    });
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

  void onSubmit() async {
    setState(() {
      loading = true;
    });
    tracks = await widget.source.getSearchResults(editingController.text);
    setState(() {
      loading = false;
    });
  }

  void closeTrack() {
    player?.dispose();
    player = null;
    playedTrack = null;
    setState(() {});
  }

  void previewPlay(int index) async {
    if (playedTrack != null && index == playedTrack) {
      // player?.pause();
      // setState(() {});
      return;
    }
    await player?.dispose();

    if (tracks[index].url == "") {
      tracks[index].url = await widget.source.getPreviewUrl(tracks[index]);
    }

    var as = ProgressiveAudioSource(Uri.parse(tracks[index].url));
    player = AudioPlayer();
    await player?.setAudioSource(as);
    player?.play();
    player?.positionStream.listen((event) {
      setState(() {});
    });
    print("index $index");
    playedTrack = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () {
        if (_multiselectMode) {
          deselectAll();
          return Future.value(false);
        }

        closeTrack();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.source.name)),
        body: ListTileTheme(
          minLeadingWidth: 0,
          selectedTileColor: const Color.fromARGB(255, 9, 51, 116),
          selectedColor: Colors.white,
          child: Column(
            children: [
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                    autofocus: true,
                    controller: editingController,
                    onSubmitted: (value) => onSubmit(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Search",
                      prefixIcon: Icon(Icons.search),
                    )),
                suggestionsCallback: (pattern) async {
                  return await widget.source.getSuggestions(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.toString()),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (suggestion) async {
                  editingController.text = suggestion.toString();
                  onSubmit();
                },
              ),
              Expanded(
                child: IndexedStack(
                  alignment: Alignment.center,
                  index: loading == true ? 0 : 1,
                  children: [
                    const CircularProgressIndicator.adaptive(),
                    ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                            selected:
                                _multiselectMode && selected.containsKey(index),
                            onTap: () async {
                              if (_multiselectMode) {
                                multiselectHandler(index);
                                return;
                              }
                              //return list of 1 track
                              tracks[index].url = await widget.source
                                  .getTrackUri(tracks[index]);
                              closeTrack();
                              Navigator.of(context).pop([tracks[index]]);
                            },
                            onLongPress: () => multiselectHandler(index),
                            leading: ColoredBox(
                              color: Colors.red,
                              child: IconButton(
                                icon: Icon(
                                  index == playedTrack
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 30,
                                ),
                                onPressed: () => previewPlay(index),
                              ),
                            ),
                            title: Text(tracks[index].artist),
                            subtitle: Text(tracks[index].title),
                            trailing: createTrailingWidget(context, index));
                      },
                      itemCount: tracks.length,
                    ),
                  ],
                ),
              ),
              if (player != null)
                ListTile(
                  title: Slider(
                    max: player?.duration?.inSeconds.toDouble() ?? 1,
                    value: player?.position.inSeconds.toDouble() ?? 0,
                    onChanged: (value) {
                      player?.seek(Duration(seconds: value.round()));
                      setState(() {});
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: closeTrack,
                  ),
                )
            ],
          ),
        ),
        floatingActionButton: _multiselectMode && selected.isNotEmpty
            ? FloatingActionButton(
                onPressed: () async {
                  List<OnlineTrack> sel = [];
                  for (int i = 0; i < selected.length; i++) {
                    var index = selected.keys.elementAt(i);
                    if (selected[index] == true) {
                      tracks[index].url =
                          await widget.source.getTrackUri(tracks[index]);
                      sel.add(tracks[index]);
                    }
                  }
                  closeTrack();
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
