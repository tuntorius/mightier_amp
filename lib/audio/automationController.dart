import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mighty_plug_manager/audio/models/trackAutomation.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'models/jamTrack.dart';
import 'online_sources/sourceResolver.dart';
import '../platform/platformUtils.dart';

enum ABRepeatState { off, addedA, addedB }

class AutomationController {
  final TrackAutomation automation;
  final JamTrack track;
  final player = AudioPlayer();

  final StreamController<Duration> _positionController =
      StreamController<Duration>();
  //StreamController<AutomationEvent> _eventController =
  //    StreamController<AutomationEvent>();

  List<AutomationEvent> get events => automation.events;
  AutomationEvent get initialEvent => automation.initialEvent;

  bool get presetChangeEventsAvailable {
    if (_presetChangeBypass) return false;
    for (var event in events) {
      if (event.type == AutomationEventType.preset) return true;
    }
    return false;
  }

  //optimisation for searching for the next event
  int _nextEvent = 0;
  int _positionReport = 0;
  int _positionResolution = 1;

  int _currentLoop = 0;
  bool _forceLoopDisable = false;

  bool _presetChangeBypass = false;

  ABRepeatState _abRepeatState = ABRepeatState.off;
  ABRepeatState get abRepeatState => _abRepeatState;

  AutomationController(this.track, this.automation);

  Stream<Duration> get positionStream => _positionController.stream;

  Duration get duration => player.duration ?? const Duration();
  PlayerState get playerState => player.playerState;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  bool get playing => player.playing;

  Function? onTrackComplete;

  int _latency = 0;
  final int _speed = 1;

  StreamSubscription<Duration>? _positionSubscription;

  //loop variables

  bool get loopEnable => _forceLoopDisable ? false : track.loopEnable;

  set loopEnable(val) {
    track.loopEnable = val;
    _currentLoop = 0;
  }

  bool get useLoopPoints =>
      track.useLoopPoints || abRepeatState == ABRepeatState.addedB;

  set useLoopPoints(val) {
    track.useLoopPoints = val;
    _currentLoop = 0;
  }

  int get loopTimes => track.loopTimes;
  set loopTimes(val) {
    track.loopTimes = val;
    if (_currentLoop > track.loopTimes) _currentLoop = track.loopTimes;
  }

  int get currentLoop => _currentLoop;

  double get speed => track.speed;
  set speed(val) => track.speed = val;

  int get pitch => track.pitch;
  set pitch(val) => track.pitch = val;

  //editor use only. don't serialize
  AutomationEvent? selectedEvent;

  Future setAudioFile(String path, int positionEventSkips) async {
    path = await SourceResolver.getSourceUrl(path);
    var source = ProgressiveAudioSource(Uri.parse(path));
    await player.setAudioSource(source);

    if (NuxDeviceControl.instance().isConnected) {
      _latency = SharedPrefs().getInt(SettingsKeys.latency, 0);
    } else {
      _latency = 0;
    }

    setSpeed(speed);
    setPitch(pitch);

    //force 10ms precision. It's needed for accurate event switch
    _positionSubscription = player
        .createPositionStream(
            steps: 1,
            minPeriod: const Duration(milliseconds: 5),
            maxPeriod: const Duration(milliseconds: 5))
        .listen(playPositionUpdate);

    _positionResolution = max(1, positionEventSkips);
  }

  void setTrackCompleteEvent(Function onComplete) {
    onTrackComplete = onComplete;
  }

  //stream listener for track position updates
  void playPositionUpdate(Duration position) {
    //switch presets here when needed
    if (_positionReport % _positionResolution == 0) {
      _positionController.add(position);
    }
    _positionReport++;

    if (position == player.duration) {
      //check for looping

      bool looped = false;
      if (loopEnable && !useLoopPoints) {
        if (loopTimes == 0 || _currentLoop < loopTimes) {
          //seek to beginning
          seek(const Duration(seconds: 0));
          looped = true;
          if (loopTimes > 0) _currentLoop++;
        }
      }

      //call and lose ref to prevent double calling
      if (!looped) {
        onTrackComplete?.call();
        onTrackComplete = null;
      }
    }

    if (_nextEvent < automation.events.length) {
      switch (automation.events[_nextEvent].type) {
        case AutomationEventType.preset:
          if (automation.events[_nextEvent].eventTime.inMilliseconds <=
              position.inMilliseconds - _latency * (1 / _speed)) {
            //set event
            executeEvent(automation.events[_nextEvent]);
            //increment expected event
            _nextEvent++;
            if (kDebugMode) print("next event $_nextEvent");
          }
          break;
        case AutomationEventType.loop:
          //loops should not be compensated for latency
          if (automation.events[_nextEvent].eventTime.inMilliseconds <=
              position.inMilliseconds) {
            //set event
            if (loopEnable && useLoopPoints) {
              executeEvent(automation.events[_nextEvent]);
            }
            //increment expected event
            _nextEvent++;
            if (kDebugMode) print("next event $_nextEvent");
          }
          break;
      }
    }
  }

  void executeEvent(AutomationEvent event) {
    var device = NuxDeviceControl.instance().device;

    switch (event.type) {
      case AutomationEventType.preset:
        if (_presetChangeBypass) break;
        debugPrint("Changing preset ${event.name}");
        var preset = event.getPreset();
        if (preset != null && preset["product_id"] == device.productStringId) {
          device.presetFromJson(
              preset,
              event.cabinetLevelOverrideEnable
                  ? event.cabinetLevelOverride
                  : null);
        }
        break;
      case AutomationEventType.loop:
        if (kDebugMode) print("loop");
        //find previous loop point
        for (int i = _nextEvent - 1; i >= 0; i--) {
          if (events[i].type == AutomationEventType.loop) {
            if (loopTimes == 0 || loopTimes > 0 && _currentLoop < loopTimes) {
              seek(events[i].eventTime);
              _nextEvent = i;
              _currentLoop++;
            }
            break;
          }
        }
        break;
    }
    //_eventController.add(event);
  }

  Future play() async {
    if (playerState.processingState == ProcessingState.completed) {
      await player.seek(const Duration(seconds: 0));
    }
    player.play();
    seek(player.position);
  }

  Future playPause() async {
    if (playerState.playing == false ||
        playerState.processingState == ProcessingState.completed) {
      await play();
    } else {
      await player.pause();
    }
  }

  Future stop() async {
    if (playerState.playing) {
      await player.stop();
    }
  }

  void setSpeed(double speed) {
    player.setSpeed(speed);
  }

  void setPitch(int pitch) {
    if (PlatformUtils.isIOS) return;
    double lPitch = pow(2, pitch / 12).toDouble();
    player.setPitch(lPitch);
  }

  void rewind() {
    _currentLoop = 0;
    seek(const Duration(seconds: 0));
  }

  void forceLoopDisable() {
    _forceLoopDisable = true;
  }

  void seek(Duration position) {
    player.seek(position);
    _updateActiveEvent();

    //check if seek before the first loop and if so - reset the loop counter
    if (useLoopPoints && loopTimes > 0) {
      for (int i = 0; i < events.length; i++) {
        if (events[i].type == AutomationEventType.loop) {
          if (position < events[i].eventTime) _currentLoop = 0;
          break;
        }
      }
    }
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

    if (kDebugMode) print("next event $_nextEvent");

    //find previous preset event
    int prevEvent = -1;
    for (int i = _nextEvent - 1; i >= 0; i--) {
      if (automation.events[i].type == AutomationEventType.preset) {
        prevEvent = i;
        break;
      }
    }

    //execute the previous
    if (prevEvent >= 0) {
      //find last
      executeEvent(automation.events[prevEvent]);
    } else {
      executeEvent(automation.initialEvent);
    }
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

  void bypassPresetChanges() {
    _presetChangeBypass = true;
  }

  //TODO: make sure there are always 2 loop events
  void removeAllLoopEvents() {
    for (int i = events.length - 1; i >= 0; i--) {
      if (events[i].type == AutomationEventType.loop) events.removeAt(i);
    }
  }

  bool hasLoopPoints() {
    int loops = 0;
    for (int i = 0; i < events.length; i++) {
      if (events[i].type == AutomationEventType.loop) loops++;
    }

    //check for errors
    if (loops > 0 && loops != 2) removeAllLoopEvents();

    return loops == 2;
  }

  List<AutomationEvent> getLoopPoints() {
    List<AutomationEvent> loopPoints = [];
    for (int i = 0; i < events.length; i++) {
      if (events[i].type == AutomationEventType.loop) loopPoints.add(events[i]);
    }

    return loopPoints;
  }

  void toggleABRepeat() {
    switch (abRepeatState) {
      case ABRepeatState.off:
        loopEnable = false;
        removeAllLoopEvents();
        addEvent(player.position, AutomationEventType.loop);
        _abRepeatState = ABRepeatState.addedA;
        break;
      case ABRepeatState.addedA:
        loopTimes = 0;
        addEvent(player.position, AutomationEventType.loop);
        var lp = getLoopPoints();
        seek(lp[0].eventTime);
        _abRepeatState = ABRepeatState.addedB;
        loopEnable = true;
        break;
      case ABRepeatState.addedB:
        loopEnable = false;
        _abRepeatState = ABRepeatState.off;
        break;
    }
  }

  Future dispose() async {
    _positionSubscription?.cancel();
    await player.stop();
    await player.dispose();
    _positionController.close();
    //_eventController.close();
  }
}
