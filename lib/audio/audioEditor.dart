// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import '../UI/popups/selectPreset.dart';
import '../bluetooth/devices/presets/Preset.dart';

import 'audioDecoder.dart';
import 'models/trackAutomation.dart';
import 'models/waveform_data.dart';
import 'widgets/painted_waveform.dart';

enum EditorState { play, insert }

class AudioEditor extends StatefulWidget {
  final String path;
  AudioEditor(this.path);
  @override
  _AudioEditorState createState() => _AudioEditorState();
}

class _AudioEditorState extends State<AudioEditor> {
  WaveformData wfData;
  AudioDecoder decoder;
  TrackAutomation automation;

  NuxDevice device;

  int currentSample = 0;
  bool pageLeft = false;
  int latency = SharedPrefs().getInt(SettingsKeys.latency, 0);

  //stuff for inserting
  EditorState state = EditorState.play;
  dynamic selectedPreset;

  @override
  void initState() {
    super.initState();

    device = NuxDeviceControl().device;

    decodeAudio();
    automation = TrackAutomation();
    automation.setAudioFile(widget.path, 100);

    //set latency only when playing over bluetooth
    if (BLEMidiHandler().connectedDevice != null)
      automation.setAudioLatency(latency);

    automation.positionStream.listen(playPositionUpdate);
    automation.playerStateStream.listen(playerStateUpdate);
    automation.eventStream.listen(eventUpdate);
  }

  Future decodeAudio() async {
    decoder = AudioDecoder();

    await decoder.open(widget.path);

    decoder.decode(() {
      wfData = WaveformData(maxValue: 1, data: decoder.samples);
    }, () {
      if (pageLeft) return false;
      wfData.setUpdate();
      setState(() {});
      return true;
    }, () {
      //final update
      wfData.setReady();
      setState(() {});
    });
  }

  int sampleToMs(int sample) {
    var percentage = sample / wfData.data.length;
    return (percentage * decoder.duration * 1000).round();
  }

  void playFrom(int sample) {
    automation.seek(Duration(milliseconds: sampleToMs(sample)));
    if (automation.playing == false) automation.play();
  }

  void playPositionUpdate(Duration position) {
    setState(() {
      var posMs = max(position.inMilliseconds - latency, 0);
      currentSample = (decoder.samples.length *
              (posMs / automation.duration.inMilliseconds))
          .floor();
    });
  }

  void playerStateUpdate(PlayerState state) {
    //just refresh state so the play button is correct
    //print(state);
    setState(() {});
  }

  void eventUpdate(AutomationEvent event) {
    print(event.presetName);
    device.presetFromJson(event.preset);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        pageLeft = true;
        await automation.dispose();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Song editor"),
        ),
        body: Container(
          child: Column(children: [
            // Text(
            //   "Editor",
            //   style: TextStyle(color: Colors.white, fontSize: 30),
            // ),
            Expanded(
                child: Stack(
              children: [
                PaintedWaveform(
                  sampleData: wfData,
                  currentSample: currentSample,
                  automation: automation,
                  onWaveformTap: (sample) {
                    switch (state) {
                      case EditorState.play:
                        playFrom(sample);
                        break;
                      case EditorState.insert:
                        setState(() {
                          state = EditorState.play;
                          automation.addEvent(
                              Duration(milliseconds: sampleToMs(sample)),
                              AutomationEventType.changePreset)
                            ..presetCategory = selectedPreset["category"]
                            ..presetName = selectedPreset["name"]
                            ..channel = Preset.nuxChannel(
                                selectedPreset["instrument"],
                                selectedPreset["channel"])
                            ..preset = selectedPreset;
                        });
                        break;
                    }
                  },
                ),
                if (state == EditorState.insert)
                  Container(
                      color: Colors.grey[700],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Tap here to insert preset change",
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
              ],
              alignment: Alignment.center,
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  onPressed: () {
                    automation.seek(Duration(milliseconds: 0));
                    setState(() {
                      currentSample = 0;
                    });
                  },
                  height: 70,
                  child: Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    automation.playPause();
                  },
                  height: 70,
                  child: Icon(
                    automation.playerState.playing == false ||
                            automation.playerState.processingState ==
                                ProcessingState.completed
                        ? Icons.play_arrow
                        : Icons.pause,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                PopupMenuButton(
                  padding: Theme.of(context).buttonTheme.padding,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<int>(
                        child: Text("Not implemented"),
                        value: 1,
                      )
                    ];
                  },
                  child: Stack(
                    //mainAxisSize: MainAxisSize.min,
                    alignment: Alignment.centerRight,
                    children: [
                      MaterialButton(
                        onPressed: null,
                        height: 70,
                        child: Icon(
                          Icons.repeat,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      // Icon(
                      //   Icons.repeat,
                      //   color: Colors.white,
                      //   size: 50,
                      // ),
                      Icon(Icons.arrow_drop_down, color: Colors.white)
                    ],
                  ),
                ),
              ],
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     if (state != EditorState.insert) {
            //       showDialog(
            //         context: context,
            //         builder: (BuildContext context) =>
            //             SelectPresetDialog().buildDialog(context),
            //       ).then((value) {
            //         if (value != null) {
            //           setState(() {
            //             state = EditorState.insert;
            //           });
            //           selectedPreset = value;
            //         }
            //       });
            //     } else
            //       setState(() {
            //         state = EditorState.play;
            //       });
            //   },
            //   child: Text("Set base preset"),
            // ),
            ElevatedButton(
              onPressed: () {
                if (state != EditorState.insert) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        SelectPresetDialog().buildDialog(context),
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        state = EditorState.insert;
                      });
                      selectedPreset = value;
                    }
                  });
                } else
                  setState(() {
                    state = EditorState.play;
                  });
              },
              child: Text("Insert preset change"),
            ),
            /*ElevatedButton(onPressed: () {}, child: Text("Do other stuff here"))*/
          ]),
        ),
      ),
    );
  }
}
