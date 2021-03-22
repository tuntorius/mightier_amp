import 'dart:async';
import 'dart:math';

import 'package:just_audio/just_audio.dart';
import 'package:mighty_plug_manager/audio/models/trackAutomation.dart';

class AutomationController {
  final TrackAutomation automation;
  final player = AudioPlayer();

  StreamController<Duration> _positionController = StreamController<Duration>();
  StreamController<AutomationEvent> _eventController =
      StreamController<AutomationEvent>();

  List<AutomationEvent> get events => automation.events;
  AutomationEvent get initialEvent => automation.initialEvent;

  //optimisation for searching for the next event
  int _nextEvent = 0;
  int _positionReport = 0;
  int _positionResolution = 1;

  AutomationController(this.automation);

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<AutomationEvent> get eventStream => _eventController.stream;

  Duration get duration => player.duration ?? Duration();
  PlayerState get playerState => player.playerState;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  bool get playing => player.playing;

  int _latency = 0;
  int _speed = 1;

  //editor use only. don't serialize
  AutomationEvent? selectedEvent;

  void setAudioFile(String path, int positionResolution) async {
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

    if (_nextEvent < automation.events.length) {
      if (automation.events[_nextEvent].eventTime.inMilliseconds <=
          position.inMilliseconds - _latency * (1 / _speed)) {
        //set event
        executeEvent(automation.events[_nextEvent]);
        //increment expected event
        _nextEvent++;
        print("!!!!!!next event $_nextEvent");
      }
    }
  }

  void executeEvent(AutomationEvent event) {
    switch (event.type) {
      case AutomationEventType.preset:
        print("Changing preset");
        break;
      case AutomationEventType.loop:
        break;
    }
    _eventController.add(event);
  }

  void play() async {
    if (playerState.processingState == ProcessingState.completed)
      await player.seek(Duration(seconds: 0));
    player.play();
    seek(player.position);
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
    _updateActiveEvent();
  }

  void sortEvents() {
    automation.sortEvents();
    _updateActiveEvent();
  }

  void _updateActiveEvent() {
    if (!player.playing) return;
    var position = player.position;
    _nextEvent = automation.events.length;
    //recalculate next event
    for (int i = 0; i < automation.events.length; i++) {
      if (position.inMilliseconds - _latency * (1 / _speed) <
          automation.events[i].eventTime.inMilliseconds) {
        //this is the first event prior the seek time
        _nextEvent = i;
        break;
      }
    }

    print("!!!!!!next event $_nextEvent");
    //execute the previous
    if (_nextEvent > 0)
      executeEvent(automation.events[_nextEvent - 1]);
    else
      executeEvent(automation.initialEvent);
  }

  AutomationEvent addEvent(Duration atPosition, AutomationEventType type) {
    //finally make sure the events are sorted
    var event = AutomationEvent(
      eventTime: atPosition,
      type: type,
    );
    automation.events.add(event);
    selectedEvent = event;
    sortEvents();
    return event;
  }

  void addEventFromOther(AutomationEvent other, Duration atPosition) {
    AutomationEvent ev =
        AutomationEvent(eventTime: atPosition, type: other.type);
    ev.setPresetUuid(other.getPresetUuid());
    ev.cabinetLevelOverride = other.cabinetLevelOverride;
    ev.cabinetLevelOverrideEnable = other.cabinetLevelOverrideEnable;
    automation.events.add(ev);
    selectedEvent = ev;
    sortEvents();
  }

  void removeEvent(AutomationEvent event) {
    if (!automation.events.contains(event)) return;
    //make sure no reference remains
    if (selectedEvent == event) selectedEvent = null;
    automation.events.remove(event);
    sortEvents();
  }

  Future dispose() async {
    await player.stop();
    await player.dispose();
    _positionController.close();
    _eventController.close();
  }
}
