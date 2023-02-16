import 'dart:async';

import 'package:flutter/foundation.dart';

import '../automationController.dart';
import '../models/setlist.dart';

enum PlayerState { idle, play, pause }

class SetlistPlayerState extends ChangeNotifier {
  static final SetlistPlayerState _setlistPlayerState = SetlistPlayerState._();

  SetlistPlayerState._();

  factory SetlistPlayerState.instance() {
    return _setlistPlayerState;
  }

  PlayerState state = PlayerState.idle;
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Setlist? setlist;
  int currentTrack = 0;
  Duration currentPosition = const Duration(seconds: 0);
  bool _autoAdvance = true;
  bool _inPositionUpdateMode = false;

  bool _expanded = false;
  bool get expanded => _expanded;

  int _pitch = 1;
  double _speed = 1;

  int get pitch => _pitch;
  set pitch(val) {
    _pitch = val;
    notifyListeners();
  }

  double get speed => _speed;
  set speed(val) {
    _speed = val;
    notifyListeners();
  }

  AutomationController? get automation => _automation;

  bool get autoAdvance => _autoAdvance;
  set autoAdvance(bool val) {
    _autoAdvance = val;
    notifyListeners();
  }

  AutomationController? _automation;

  void openTrack(int setlistIndex) async {
    currentTrack = setlistIndex;
    await closeTrack();

    await _openTrack(setlistIndex);

    await play();
    notifyListeners();
  }

  void openSetlist(Setlist newSetlist) {
    setlist = newSetlist;
  }

  Future _openTrack(int index) async {
    if (setlist == null) return;
    currentTrack = index;
    var track = setlist!.items[index].trackReference;
    if (track != null) {
      print("Opening track ${track.name}");
      print("Track path: ${track.path}");
      _automation = AutomationController(track, track.automation);
      await _automation?.setAudioFile(track.path, 70);
      _automation?.setTrackCompleteEvent(_onTrackComplete);
      _automation?.positionStream.listen(_onPosition);
      pitch = _automation?.pitch ?? 1;
      speed = _automation?.speed ?? 1;
    }
  }

  Future play() async {
    await _automation?.play();
    state = PlayerState.play;
    notifyListeners();
  }

  Future playPause() async {
    if (_automation == null) await _openTrack(currentTrack);
    await _automation?.playPause();
    if (_automation!.player.playerState.playing == false) {
      state = PlayerState.pause;
    } else {
      state = PlayerState.play;
    }
    debugPrint(state.toString());
    notifyListeners();
  }

  Future stop() async {
    await _automation?.stop();
    state = PlayerState.idle;
    notifyListeners();
  }

  void previous() async {
    if (_automation == null) return;
    if (currentTrack == 0 || _automation!.player.position.inSeconds > 2) {
      _automation!.rewind();
    } else if (currentTrack > 0) {
      await closeTrack();
      currentTrack--;
      await _openTrack(currentTrack);
      if (state == PlayerState.play) await play();
    }

    notifyListeners();
  }

  void next() async {
    if (setlist == null) return;
    if (currentTrack < setlist!.items.length - 1) {
      await closeTrack();
      currentTrack++;
      await _openTrack(currentTrack);
      if (state == PlayerState.play) await play();
      notifyListeners();
    }
  }

  Future? closeTrack() {
    return _automation?.dispose();
  }

  void _onPosition(Duration pos) {
    if (!_inPositionUpdateMode) currentPosition = pos;
    _positionController.add(pos);
  }

  String getMMSS(Duration d) {
    var m = d.inMinutes.toString().padLeft(2, "0");
    var s = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$m:$s";
  }

  Duration getDuration() {
    return _automation?.duration ?? const Duration(seconds: 0);
  }

  void setPosition(int positionMS) {
    if (positionMS < 0) positionMS = 0;

    var duration = getDuration().inMilliseconds;
    if (positionMS > duration) positionMS = duration;

    currentPosition = Duration(milliseconds: positionMS);
    _automation?.seek(currentPosition);
    notifyListeners();
    _positionController.add(currentPosition);
  }

  void setPositionUpdateMode(bool enabled) {
    _inPositionUpdateMode = enabled;
    if (!enabled) _automation?.seek(currentPosition);
  }

  void _onTrackComplete() async {
    await closeTrack();

    if (setlist == null) return;
    currentPosition = const Duration(milliseconds: 0);
    if (currentTrack < setlist!.items.length - 1) {
      currentTrack++;
      await _openTrack(currentTrack);
      if (_autoAdvance) {
        await play();
        state = PlayerState.play;
      } else {
        state = PlayerState.pause;
      }
    } else {
      await _openTrack(currentTrack);
      currentTrack = 0;
      state = PlayerState.pause;
    }
    notifyListeners();
  }

  void toggleExpanded() {
    _expanded = !_expanded;
    notifyListeners();
  }
}
