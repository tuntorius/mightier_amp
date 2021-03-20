// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';
import 'dart:math';

import 'package:just_audio/just_audio.dart';

enum AutomationEventType { changePreset }

class AutomationEvent {
  AutomationEventType type;
  Duration eventTime;

  //values if type is presetChange
  dynamic preset;
  String presetCategory = "";
  String presetName = "";
  int channel = 0;
  AutomationEvent({required this.eventTime, required this.type});
}

class TrackAutomation {
  final player = AudioPlayer();

  final _events = <AutomationEvent>[];
  String _audioFile = "";

  List<AutomationEvent> get events => _events;

  //optimisation for searching for the next event
  int _nextEvent = 0;
  int _positionReport = 0;
  int _positionResolution = 1;

  int _latency = 0;
  int _speed = 1;

  //editor use only. don't serialize
  AutomationEvent? selectedEvent;

  StreamController<Duration> _positionController = StreamController<Duration>();
  StreamController<AutomationEvent> _eventController =
      StreamController<AutomationEvent>();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<AutomationEvent> get eventStream => _eventController.stream;

  Duration get duration => player.duration ?? Duration();
  PlayerState get playerState => player.playerState;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  bool get playing => player.playing;

  void setAudioFile(String path, int positionResolution) async {
    _audioFile = path;
    await player.setFilePath(path);

    //force 1ms precision. It's needed for accurate event switch
    player.createPositionStream(
        steps: 99999999999,
        minPeriod: Duration(milliseconds: 1),
        maxPeriod: Duration(milliseconds: 200))
      ..listen(playPositionUpdate);

    _positionResolution = max(1, positionResolution);
  }

  void setAudioLatency(int latency) {
    _latency = latency;
  }

  //stream listener for track position updates
  void playPositionUpdate(Duration position) {
    //switch presets here when needed
    if (_positionReport % _positionResolution == 0)
      _positionController.add(position);

    _positionReport++;

    if (_nextEvent < _events.length) {
      if (_events[_nextEvent].eventTime.inMilliseconds <=
          position.inMilliseconds - _latency * (1 / _speed)) {
        //execute event
        executeEvent(_events[_nextEvent]);
        //increment expected event
        _nextEvent++;
      }
    }
  }

  void executeEvent(AutomationEvent event) {
    switch (event.type) {
      case AutomationEventType.changePreset:
        print("Changing preset");
        break;
    }
    _eventController.add(event);
  }

  void play() async {
    if (playerState.processingState == ProcessingState.completed)
      await player.seek(Duration(seconds: 0));
    player.play();
  }

  void playPause() {
    if (playerState.playing == false ||
        playerState.processingState == ProcessingState.completed)
      play();
    else
      player.pause();
  }

  void setSpeed(double speed) {
    player.setSpeed(speed);
  }

  void setPitch(double pitch) {
    //TODO: just_audio library will implement this soon
    //player.setPitch(pitch);
  }

  void seek(Duration position) {
    player.seek(position);

    _nextEvent = _events.length;
    //recalculate next event
    for (int i = 0; i < _events.length; i++) {
      if (position < _events[i].eventTime) {
        //this is the first event prior the seek time
        _nextEvent = i;
        break;
      }
    }

    print("next event $_nextEvent");
    //execute the previous
    if (_nextEvent > 0) executeEvent(_events[_nextEvent - 1]);
  }

  Future dispose() async {
    await player.stop();
    await player.dispose();
    _positionController.close();
    _eventController.close();
  }

  void sortEvents() {
    _events.sort((a, b) => a.eventTime.compareTo(b.eventTime));
  }

  AutomationEvent addEvent(Duration atPosition, AutomationEventType type) {
    //finally make sure the events are sorted
    var event = AutomationEvent(eventTime: atPosition, type: type);
    _events.add(event);
    selectedEvent = event;
    sortEvents();
    return event;
  }

  void removeEvent(AutomationEvent event) {
    if (!_events.contains(event)) return;
    //make sure no reference remains
    if (selectedEvent == event) selectedEvent = null;
    _events.remove(event);
    sortEvents();
  }
}
