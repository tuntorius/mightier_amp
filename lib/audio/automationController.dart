import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mighty_plug_manager/audio/models/trackAutomation.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';

class AutomationController {
  final TrackAutomation automation;
  final player = AudioPlayer();

  StreamController<Duration> _positionController = StreamController<Duration>();
  //StreamController<AutomationEvent> _eventController =
  //    StreamController<AutomationEvent>();

  List<AutomationEvent> get events => automation.events;
  AutomationEvent get initialEvent => automation.initialEvent;

  //optimisation for searching for the next event
  int _nextEvent = 0;
  int _positionReport = 0;
  int _positionResolution = 1;

  AutomationController(this.automation);

  Stream<Duration> get positionStream => _positionController.stream;
  //Stream<AutomationEvent> get eventStream => _eventController.stream;

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

    if (NuxDeviceControl().isConnected)
      _latency = SharedPrefs().getInt(SettingsKeys.latency, 0);
    else
      _latency = 0;

    //force 1ms precision. It's needed for accurate event switch
    player.createPositionStream(
        steps: 99999999999,
        minPeriod: Duration(microseconds: 1),
        maxPeriod: Duration(milliseconds: 200))
      ..listen(playPositionUpdate);

    _positionResolution = max(1, positionResolution);
  }

  // void setAudioLatency(int latency) {
  //   _latency = latency;
  // }

  //stream listener for track position updates
  void playPositionUpdate(Duration position) {
    //switch presets here when needed
    if (_positionReport % _positionResolution == 0)
      _positionController.add(position);

    _positionReport++;

    //execute loop events without latency calc
    if (_nextEvent < automation.events.length) {
      switch (automation.events[_nextEvent].type) {
        case AutomationEventType.preset:
          if (automation.events[_nextEvent].eventTime.inMilliseconds <=
              position.inMilliseconds - _latency * (1 / _speed)) {
            //set event
            executeEvent(automation.events[_nextEvent]);
            //increment expected event
            _nextEvent++;
            if (kDebugMode) print("FKT next event $_nextEvent");
          }
          break;
        case AutomationEventType.loop:
          //loops should not be compensated for latency
          if (automation.events[_nextEvent].eventTime.inMilliseconds <=
              position.inMilliseconds) {
            //set event
            executeEvent(automation.events[_nextEvent]);
            //increment expected event
            _nextEvent++;
            if (kDebugMode) print("FKT next event $_nextEvent");
          }
          break;
      }
    }
  }

  void executeEvent(AutomationEvent event) {
    var device = NuxDeviceControl().device;

    switch (event.type) {
      case AutomationEventType.preset:
        if (kDebugMode) print("FKT Changing preset ${event.name}");
        var preset = event.getPreset();
        if (preset != null && preset["product_id"] == device.productStringId)
          device.presetFromJson(
              preset,
              event.cabinetLevelOverrideEnable
                  ? event.cabinetLevelOverride
                  : null);
        break;
      case AutomationEventType.loop:
        if (kDebugMode) print("FKT loop");
        //find previous loop point
        for (int i = _nextEvent - 1; i >= 0; i--)
          if (events[i].type == AutomationEventType.loop) {
            seek(events[i].eventTime);
            _nextEvent = i;
            break;
          }
        break;
    }
    //_eventController.add(event);
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

    if (kDebugMode) print("FKT next event $_nextEvent");

    //find previous preset event
    int _prevEvent = -1;
    for (int i = _nextEvent - 1; i >= 0; i--) {
      if (automation.events[i].type == AutomationEventType.preset) {
        _prevEvent = i;
        break;
      }
    }

    //execute the previous
    if (_prevEvent >= 0) {
      //find last
      executeEvent(automation.events[_prevEvent]);
    } else
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
    //_eventController.close();
  }
}
