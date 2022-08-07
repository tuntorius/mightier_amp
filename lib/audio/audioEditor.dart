// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/UI/widgets/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/audio/automationController.dart';
import 'package:mighty_plug_manager/audio/widgets/presetsPanel.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

import 'audioDecoder.dart';
import 'models/jamTrack.dart';
import 'models/trackAutomation.dart';
import 'models/waveform_data.dart';
import 'widgets/eventEditor.dart';
import 'widgets/loopPanel.dart';
import 'widgets/painted_waveform.dart';
import 'widgets/speedPanel.dart';

enum EditorState { play, insert, duplicateInsert, insertLoop1, insertLoop2 }

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

  NuxDevice device = NuxDeviceControl.instance().device;

  int currentSample = 0;
  bool pageLeft = false;
  int latency = SharedPrefs().getInt(SettingsKeys.latency, 0);

  //screen stuff
  double _samplesPerPixel = 0, _msPerSample = 0;

  //stuff for inserting
  EditorState state = EditorState.play;
  dynamic selectedPreset;
  AutomationEvent? duplicatedEvent;

  AutomationEventType showType = AutomationEventType.preset;

  @override
  void initState() {
    super.initState();

    automation = AutomationController(widget.track, widget.track.automation);
    WidgetsFlutterBinding.ensureInitialized();

    if (AppThemeConfig.allowRotation)
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    device = NuxDeviceControl.instance().device;

    decodeAudio();
    automation.setAudioFile(widget.track.path, 100);

    automation.positionStream.listen(playPositionUpdate);
    automation.playerStateStream.listen(playerStateUpdate);
    //automation.eventStream.listen(eventUpdate);

    controller.addListener(() {
      if (controller.page == null) return;
      double p = controller.page!;
      if (p == p.round()) {
        print(p.round());
        switch (p.round()) {
          case 0:
            showType = AutomationEventType.preset;
            break;
          case 1:
            showType = AutomationEventType.loop;
            break;
          case 2:
            break;
        }
        setState(() {});
      }
    });
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

  void useLoopPoints(bool enable) {
    automation.useLoopPoints = enable;
    if (!automation.hasLoopPoints()) state = EditorState.insertLoop1;
    setState(() {});
  }

  AutomationEventType? showEventType() {
    if (showType == AutomationEventType.loop &&
        (!automation.loopEnable || !automation.useLoopPoints)) return null;
    return showType;
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () async {
        pageLeft = true;
        await automation.dispose();
        //revert back to orientation change
        if (AppThemeConfig.allowRotation)
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ]);

        NuxDeviceControl.instance().resetToChannelDefaults();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Song editor"),
        ),
        body: Container(
          child: Column(children: [
            Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    PaintedWaveform(
                      sampleData: wfData,
                      currentSample: currentSample,
                      automation: automation,
                      onTimingData: timingData,
                      showType: showEventType(),
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
                          case EditorState.insertLoop1:
                            setState(() {
                              state = EditorState.insertLoop2;
                              automation.addEvent(
                                  Duration(milliseconds: sampleToMs(sample)),
                                  AutomationEventType.loop);
                            });
                            break;
                          case EditorState.insertLoop2:
                            setState(() {
                              state = EditorState.play;
                              automation.useLoopPoints = true;
                              automation.addEvent(
                                  Duration(milliseconds: sampleToMs(sample)),
                                  AutomationEventType.loop);
                            });
                            break;
                        }
                      },
                    ),
                    if (state != EditorState.play)
                      ColoredBox(
                          color: Colors.grey[700]!,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Tap here to insert event",
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
                    automation.rewind();
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

                        //clear selected event
                        automation.selectedEvent = null;
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
                        LoopPanel(
                          automation: automation,
                          onUseLoopPoints: useLoopPoints,
                          onLoopEnable: (value) {
                            setState(() {
                              automation.loopEnable = value ?? false;
                            });
                          },
                          onLoopTimes: (value) {
                            setState(() {
                              automation.loopTimes = value;
                            });
                          },
                        ),
                        SpeedPanel(
                          semitones: automation.pitch,
                          speed: automation.speed,
                          onSpeedChanged: (_speed) {
                            setState(() {
                              automation.speed = _speed;
                              automation.setSpeed(_speed);
                            });
                          },
                          onSemitonesChanged: (_semitones) {
                            setState(() {
                              automation.pitch = _semitones;
                              automation.setPitch(_semitones);
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        if (state == EditorState.insertLoop1 ||
                            state == EditorState.insertLoop2)
                          automation.removeAllLoopEvents();

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
          ]),
        ),
      ),
    );
  }
}
