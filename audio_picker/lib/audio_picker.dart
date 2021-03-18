import 'dart:async';

import 'package:flutter/services.dart';

class AudioPicker {
  static const MethodChannel _channel = const MethodChannel('audio_picker');

  static Future<String> pickAudio() async {
    final String absolutePath = await _channel.invokeMethod('pick_audio');
    return absolutePath;
  }

  static Future<List<String>> pickAudioMultiple() async {
    final absolutePath = await _channel.invokeMethod('pick_audio_multiple');
    if (absolutePath is String) return [absolutePath];
    return List<String>.from(absolutePath);
  }
}
