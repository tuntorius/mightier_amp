import 'dart:async';

import 'package:flutter/services.dart';

class AVPlayer {
  static const MethodChannel _channel = MethodChannel('av_player');
  static const EventChannel _playerStateStreamChannel =
      EventChannel('av_player/playerStateStream');

  Duration _duration = Duration();
  Duration get duration => _duration;

  Future<void> setAudioFile(String path) async {
    int durationMs = await _channel.invokeMethod('setAudioFile', path);

    _duration = Duration(milliseconds: durationMs);
  }

  Future<void> play() async {
    await _channel.invokeMethod('play');
  }

  Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  void setSpeed(double speed) {
    _channel.invokeMethod('setSpeed', speed);
  }

  void setPitch(double pitch) {
    _channel.invokeMethod('setPitch', pitch);
  }

  Future<void> seek(Duration position) async {
    await _channel.invokeMethod('seek', position.inMilliseconds);
  }

  Stream<Duration> get positionStream {
    return _playerStateStreamChannel
        .receiveBroadcastStream()
        .map<Duration>((position) {
      return Duration(milliseconds: position);
    });
  }
}
