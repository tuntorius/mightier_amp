import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

typedef StaleBookmarkCallback = void Function(String old, String updated);

class AudioPicker {
  static const MethodChannel _channel = MethodChannel('audio_picker');
  static AudioPicker? _instance;

  StaleBookmarkCallback? _onStaleBookmark;

  factory AudioPicker() {
    _instance ??= AudioPicker._();
    return _instance!;
  }

  AudioPicker._() {
    // Attach handlers to the platform channel here
    _channel.setMethodCallHandler((call) async {
      // Check if the method name is updateBookmark
      if (call.method == "updateBookmark") {
        // Get the old and new bookmark data from the arguments
        var oldBookmark = call.arguments[0] as String;
        var newBookmark = call.arguments[1] as String;

        _onStaleBookmark?.call(oldBookmark, newBookmark);
      }
    });
  }

  void regusterOnStaleBookmark(StaleBookmarkCallback callback) {
    _onStaleBookmark = callback;
  }

  Future<String> pickAudio() async {
    final String absolutePath = await _channel.invokeMethod('pick_audio');
    return absolutePath;
  }

  Future<List<String>> pickAudioMultiple() async {
    final absolutePath = await _channel.invokeMethod('pick_audio_multiple');
    if (absolutePath is String) return [absolutePath];
    if (absolutePath != null) return List<String>.from(absolutePath);
    return [];
  }

  Future<List<String>> pickAudioFiles() async {
    final absolutePath =
        await _channel.invokeMethod('pick_audio_file_multiple');

    if (absolutePath != null) return List<String>.from(absolutePath);
    return absolutePath;
  }

  Future<String> iosBookmarkToUrl(String bookmark) async {
    var url = await _channel
        .invokeMethod('pick_audio_bookmark_to_url', {'bookmark': bookmark});
    return url;
  }

  void iosReleaseSecurityScope(String url) {
    _channel.invokeMethod('pick_audio_release_security_scope', {'url': url});
  }

  Future<Map<String, String>> getMetadata(String assetUrl) async {
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
