// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mighty_plug_manager/audio/automationController.dart';
import 'package:mighty_plug_manager/audio/widgets/presetsPanel.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

import 'audioDecoder.dart';
import 'models/jamTrack.dart';
import 'models/trackAutomation.dart';
import 'models/waveform_data.dart';
import 'widgets/eventEditor.dart';
import 'widgets/painted_waveform.dart';
import 'widgets/speedPanel.dart';

enum EditorState { play, insert, duplicateInsert }

class AudioEditor extends StatefulWidget {
  final JamTrack track;
  AudioEditor(this.track);
  @override
  _AudioEditorState createState() => _AudioEditorState();
}

class _AudioEditorState extends State<AudioEditor> {
  WaveformData? wfData;
  AudioDecoder decoder = AudioDecoder();
  late AutomationController automation;

  final controller = PageController(
    initialPage: 0,
  );

  final _currentPageNotifier = ValueNotifier<int>(0);

  NuxDevice device = NuxDeviceControl().device;

  int currentSample = 0;
  bool pageLeft = false;
  int latency = SharedPrefs().getInt(SettingsKeys.latency, 0);

  //screen stuff
  double _samplesPerPixel = 0, _msPerSample = 0;

  //speed and pitch shifting stuff
  double speed = 1;
  int semitones = 0;

  //stuff for inserting
  EditorState state = EditorState.play;
  dynamic selectedPreset;
  AutomationEvent? duplicatedEvent;

  @override
  void initState() {
    super.initState();

    automation = AutomationController(widget.track.automation);
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    device = NuxDeviceControl().device;

    decodeAudio();
    automation.setAudioFile(widget.track.path, 100);

    //set latency only when a device is connected
    if (BLEMidiHandler().connectedDevice != null)
      automation.setAudioLatency(latency);
    else
      automation.setAudioLatency(0);

    automation.positionStream.listen(playPositionUpdate);
    automation.playerStateStream.listen(playerStateUpdate);
    automation.eventStream.listen(eventUpdate);
  }

  Future decodeAudio() async {
    await decoder.open(widget.track.path);

    decoder.decode(() {
      wfData = WaveformData(maxValue: 1, data: decoder.samples);
    }, () {
      if (pageLeft) return false;
      wfData!.setUpdate();
      setState(() {});
      return true;
    }, () {
      //final update
      wfData!.setReady();
      setState(() {});
    });
  }

  int sampleToMs(int sample) {
    var percentage = sample / wfData!.data.length;
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
    setState(() {});
  }

  void eventUpdate(AutomationEvent event) {
    switch (event.type) {
      case AutomationEventType.preset:
        var preset = event.getPreset();
        if (preset != null && preset["product_id"] == device.productStringId)
          device.presetFromJson(
              preset,
              event.cabinetLevelOverrideEnable
                  ? event.cabinetLevelOverride
                  : null);
        break;
      case AutomationEventType.loop:
        break;
    }
  }

  void timingData(double samplesPerPixel, double msPerSample) {
    _samplesPerPixel = samplesPerPixel;
    _msPerSample = msPerSample;
  }

  void stepLeft() {
    var event = automation.selectedEvent;
    if (event == null) return;
    var subtract =
        Duration(milliseconds: (_samplesPerPixel / _msPerSample).ceil());
    if (event.eventTime > subtract)
      event.eventTime -= subtract;
    else
      event.eventTime = Duration(milliseconds: 0);

    automation.sortEvents();
    setState(() {});
  }

  void stepRight() {
    var event = automation.selectedEvent;
    if (event == null) return;
    var subtract =
        Duration(milliseconds: (_samplesPerPixel / _msPerSample).ceil());
    var songLength = automation.duration;
    if (event.eventTime < songLength - subtract)
      event.eventTime += subtract;
    else
      event.eventTime = songLength;

    automation.sortEvents();
    setState(() {});
  }

  void editEvent(AutomationEvent event) {
    var editor = EventEditor(event: event);
    editor.buildDialog(context).then((value) {
      setState(() {});
    });
  }

  void duplicateEvent(AutomationEvent event) {
    state = EditorState.duplicateInsert;
    duplicatedEvent = event;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        pageLeft = true;
        await automation.dispose();
        //revert back to orientation change
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
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
                flex: 3,
                child: Stack(
                  children: [
                    PaintedWaveform(
                      sampleData: wfData,
                      currentSample: currentSample,
                      automation: automation,
                      onTimingData: timingData,
                      onEventSelectionChanged: () {
                        setState(() {});
                      },
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
                                  AutomationEventType.preset)
                                ..setPresetUuid(selectedPreset["uuid"]);
                            });
                            break;
                          case EditorState.duplicateInsert:
                            if (duplicatedEvent == null) break;
                            setState(() {
                              state = EditorState.play;
                              automation.addEventFromOther(duplicatedEvent!,
                                  Duration(milliseconds: sampleToMs(sample)));
                            });
                            break;
                        }
                      },
                    ),
                    if (state != EditorState.play)
                      Container(
                          color: Colors.grey[700],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Tap here to insert event",
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                  ],
                  alignment: Alignment.center,
                )),
            //Playback controls
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
                MaterialButton(
                  onPressed: stepLeft, //move event left
                  height: 70,
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                MaterialButton(
                  onPressed: stepRight, //move event left
                  height: 70,
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                /*PopupMenuButton(
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
                ),*/
              ],
            ),
            Expanded(
                flex: 2,
                child: IndexedStack(
                  index: state == EditorState.play ? 0 : 1,
                  alignment: Alignment.center,
                  children: [
                    PageView(
                      controller: controller,
                      onPageChanged: (int index) {
                        _currentPageNotifier.value = index;
                      },
                      children: [
                        PresetsPanel(
                            automation: automation,
                            onDelete: () {
                              if (automation.selectedEvent != null)
                                automation
                                    .removeEvent(automation.selectedEvent!);
                              setState(() {});
                            },
                            onEditEvent: editEvent,
                            onDuplicateEvent: duplicateEvent,
                            onSelectedPreset: (_preset) {
                              setState(() {
                                selectedPreset = _preset;
                                state = EditorState.insert;
                              });
                            }),
                        SpeedPanel(
                          semitones: semitones,
                          speed: speed,
                          onSpeedChanged: (_speed) {
                            setState(() {
                              speed = _speed;
                              automation.setSpeed(speed);
                            });
                          },
                          onSemitonesChanged: (_semitones, pitch) {
                            setState(() {
                              semitones = _semitones;
                              automation.setPitch(pitch);
                            });
                          },
                        ),
                        Text("TODO"),
                      ],
                    ),
                    ElevatedButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        state = EditorState.play;
                        setState(() {});
                      },
                    )
                  ],
                )),
            Container(
              height: 30,
              alignment: Alignment.center,
              child: state != EditorState.play
                  ? null
                  : CirclePageIndicator(
                      itemCount: 3,
                      currentPageNotifier: _currentPageNotifier,
                    ),
            )
            /*ElevatedButton(onPressed: () {}, child: Text("Do other stuff here"))*/
          ]),
        ),
      ),
    );
  }
}
