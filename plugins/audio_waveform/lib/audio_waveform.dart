import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';

class AudioWaveformDecoder {
  static const platform = const MethodChannel("com.tuntori.audio_waveform");
  int size = 0;
  double _durationms = 0;
  List<int> _samples = <int>[];

  List<int> get samples => _samples;
  double get duration => _durationms;

  Future<void> open(String path) async {
    try {
      print("opening $path");
      size = 0;
      var sendMap = <String, String>{"path": path};

      await platform.invokeMethod("open", sendMap);
      print("File opened");
    } catch (e) {
      print(e);
    }
  }

  Future<Uint8List?> nextBuffer() async {
    if (Platform.isIOS)
      return await platform.invokeMethod("next", {"frameCount": 128});
    return await platform.invokeMethod("next");
  }

  Future<int> _duration() async {
    return await platform.invokeMethod("duration");
  }

  Future<int> _sampleRate() async {
    return await platform.invokeMethod("sampleRate");
  }

  Future<void> release() async {
    try {
      await platform.invokeMethod("close");
    } catch (e) {
      print(e);
    }
  }

  void decode(void Function() onStart, bool Function() onProgress,
      void Function() onFinish) async {
    //get audio duration
    _durationms = await _duration() / 1000000;
    int sampleRate = await _sampleRate();
    print("$duration} seconds");
    //calc approx buffer size and create it
    int bytes = ((duration) * sampleRate).ceil();
    int bufferIndex = 0;
    int sampleStep = max(duration.round() / 10, 1).floor();

    print("sample step $sampleStep");
    int expectedSize = (bytes / sampleStep).ceil();
    _samples = List<int>.filled(expectedSize, 0, growable: true);

    int pos = 0;

    onStart();
    Stopwatch stopwatch = Stopwatch()..start();
    do {
      Uint8List? list = await nextBuffer();
      if (list == null) {
        break;
      }

      int listEndIndex = pos + list.length;
      if (listEndIndex > _samples.length) {
        _samples.length = listEndIndex;
      }

      _samples.setRange(pos, listEndIndex, list);
      pos += list.length;

      bufferIndex++;

      //update on every hundredth sample or so
      if (bufferIndex % 200 == 0) {
        // inform for progress and check whether to continue
        if (!onProgress()) {
          await release();
          return;
        }
      }
    } while (true);

    print("Length: $pos");
    print(
        "expected length ${(bytes / sampleStep).ceil()}, final length ${_samples.length}");
    print('decode executed in ${stopwatch.elapsed}');

    await release();
    onFinish();
  }
}
