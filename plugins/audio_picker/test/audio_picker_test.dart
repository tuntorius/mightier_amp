import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_picker/audio_picker.dart';

void main() {
  const MethodChannel channel = MethodChannel('audio_picker');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('pick_audio', () async {
    expect(await AudioPicker.pickAudio(), '42');
  });
}
