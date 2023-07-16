import 'dart:async';

import 'package:av_player/av_player.dart';
import 'package:mighty_plug_manager/audio/lib_adapters/audio_player_adapter.dart';

class AVFoundationAdapter implements AudioPlayerAdapter {
  final AVPlayer _player = AVPlayer();

  final StreamController<Duration> _positionController =
      StreamController<Duration>();

  final StreamController<AudioPlayerState> _stateController =
      StreamController<AudioPlayerState>();

  StreamSubscription? _positionSub;

  Duration _position = const Duration();
  bool _playing = false;
  AudioPlayerState _state = AudioPlayerState.idle;

  @override
  Duration get duration => _player.duration;

  @override
  // TODO: implement playerState
  AudioPlayerState get playerState => _state;

  @override
  Stream<AudioPlayerState> get playerStateStream => _stateController.stream;

  @override
  // TODO: implement playing
  bool get playing => _playing;

  @override
  Duration get position => _position;

  AVFoundationAdapter() {
    _positionSub = _player.positionStream.listen(_onPosition);
  }
  @override
  Stream<Duration> createPositionStream() {
    return _positionController.stream;
  }

  void _onPosition(Duration position) {
    _position = position;
    _positionController.add(position);
    if (position == _player.duration) {
      _state = AudioPlayerState.reachedEnd;
      _stateController.add(_state);
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    _positionController.close();
    _stateController.close();
    _positionSub?.cancel();
    _playing = false;
  }

  @override
  Future<void> setAudioFile(String path) {
    _playing = false;
    _state = AudioPlayerState.idle;
    _stateController.add(_state);
    return _player.setAudioFile(path);
  }

  @override
  Future<void> play() {
    _playing = true;
    _state = AudioPlayerState.idle;
    _stateController.add(_state);
    return _player.play();
  }

  @override
  Future<void> pause() {
    _playing = false;
    _state = AudioPlayerState.idle;
    _stateController.add(_state);
    return _player.pause();
  }

  @override
  Future<void> stop() {
    _playing = false;
    _state = AudioPlayerState.idle;
    _stateController.add(_state);
    return _player.stop();
  }

  @override
  Future seek(Duration position) {
    _state = AudioPlayerState.idle;
    _stateController.add(_state);
    return _player.seek(position);
  }

  @override
  void setGain(double gain) {
    // TODO: implement setGain
  }

  @override
  void setPitch(double pitch) {
    _player.setPitch(pitch);
  }

  @override
  void setSpeed(double speed) {
    _player.setSpeed(speed);
  }
}
