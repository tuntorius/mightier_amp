import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class AudioPicker {
  static const MethodChannel _channel = MethodChannel('audio_picker');

  static Future<String> pickAudio() async {
    final String absolutePath = await _channel.invokeMethod('pick_audio');
    return absolutePath;
  }

  static Future<List<String>> pickAudioMultiple() async {
    final absolutePath = await _channel.invokeMethod('pick_audio_multiple');
    if (absolutePath is String) return [absolutePath];
    if (absolutePath != null) return List<String>.from(absolutePath);
    return [];
  }

  static Future<List<String>> pickAudioFiles() async {
    final absolutePath = await _channel.invokeMethod('pick_audio_file_multiple');

    if (absolutePath != null) return List<String>.from(absolutePath);
    return absolutePath;
  }

  static Future<Map<String, String>> getMetadata(String assetUrl) async {
    if (Platform.isIOS) {
      if (assetUrl.contains("ipod-library://")) {
        String url = assetUrl;
        Uri uri = Uri.parse(url);
        assetUrl = uri.queryParameters["id"] ?? assetUrl;
      }
      final result =
          await _channel.invokeMethod('get_metadata', {'assetUrl': assetUrl});
      return Map<String, String>.from(result);
    } else if (Platform.isAndroid) {
      //BROKEN
      final result =
          await _channel.invokeMethod('get_metadata', {'uri': assetUrl});
      return Map<String, String>.from(result);
    }
    return Future.error("Unsupported platform");
  }
}
