import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';

import 'audio_player_adapter.dart';

class JustAudioAdapter implements AudioPlayerAdapter {
  late AudioPlayer _player;
  late AudioPipeline _pipeline;
  final _enhancer = AndroidLoudnessEnhancer();

  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<PlayerState> _stateSubscription;

  final StreamController<Duration> _positionController =
      StreamController<Duration>();

  final StreamController<AudioPlayerState> _stateController =
      StreamController<AudioPlayerState>();
  @override
  Stream<AudioPlayerState> get playerStateStream => _stateController.stream;
  JustAudioAdapter() {
    if (Platform.isAndroid) {
      _pipeline = AudioPipeline(androidAudioEffects: [_enhancer]);
      _player = AudioPlayer(audioPipeline: _pipeline);
      _pipeline.androidAudioEffects.add(_enhancer);
      _enhancer.setEnabled(true);
    } else {
      _player = AudioPlayer();
    }

    _positionSubscription = _player.positionStream.listen((position) {
      // Notify the position stream listener
      _positionController.add(position);
    });

    _stateSubscription = _player.playerStateStream.listen((event) {
      AudioPlayerState event = AudioPlayerState.idle;
      if (_player.playerState.processingState == ProcessingState.completed) {
        event = AudioPlayerState.reachedEnd;
      }
      _stateController.add(event);
    });
  }

  @override
  Future<void> setAudioFile(String path) async {
    var source = ProgressiveAudioSource(Uri.parse(path));
    await _player.setAudioSource(source);
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  void setSpeed(double speed) {
    _player.setSpeed(speed);
  }

  @override
  void setPitch(double pitch) {
    _player.setPitch(pitch);
  }

  @override
  Future seek(Duration position) {
    return _player.seek(position);
  }

  @override
  void setGain(double gain) {
    _enhancer.setTargetGain(gain / 10);
  }

  @override
  Stream<Duration> createPositionStream() {
    return _player.createPositionStream(
        steps: 1,
        minPeriod: const Duration(milliseconds: 5),
        maxPeriod: const Duration(milliseconds: 5));
  }

  @override
  Duration get position => _player.position;

  @override
  Duration get duration => _player.duration ?? const Duration();

  @override
  bool get playing =>
      _player.playing &&
      _player.playerState.processingState != ProcessingState.completed;

  @override
  AudioPlayerState get playerState {
    if (_player.playerState.processingState == ProcessingState.completed) {
      return AudioPlayerState.reachedEnd;
    }
    return AudioPlayerState.idle;
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    await _positionSubscription.cancel();
    await _stateSubscription.cancel();
    _positionController.close();
    _stateController.close();
  }
}
