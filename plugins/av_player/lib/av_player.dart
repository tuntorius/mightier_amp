import 'dart:async';

import 'package:flutter/services.dart';

typedef StaleBookmarkCallback = void Function(String old, String updated);

class AVPlayer {
  static const MethodChannel _channel = MethodChannel('av_player');
  static const EventChannel _playerStateStreamChannel =
      EventChannel('av_player/playerStateStream');

  Future<void> setAudioFile(String path) async {
    await _channel.invokeMethod('setAudioFile', path);
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
