// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudioDecoder {
  static const platform = const MethodChannel("mighty_plug/decoder");
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

  Future<Uint8List> nextBuffer() async {
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

  void decode(VoidCallback onStart, bool Function() onProgress,
      VoidCallback onFinish) async {
    //this holds actual buffer length
    int len = 0;

    //get audio duration
    _durationms = await _duration() / 1000000;
    int sampleRate = await _sampleRate();
    print("$duration} seconds");
    //calc approx buffer size and create it
    int bytes = ((duration) * sampleRate).ceil();

    //used for max audio sample value
    int maxValue = 0;

    int cursor = 0;
    int bufferIndex = 0;
    int sampleStep = max(duration.round() / 10, 1).floor();

    print("sample step $sampleStep");
    int expectedSize = (bytes / sampleStep).ceil();
    _samples = List<int>.filled(expectedSize, 0, growable: true);

    int pos = 0;

    onStart();
    Stopwatch stopwatch = new Stopwatch()..start();
    do {
      Uint8List list = await nextBuffer();
      if (list == null) {
        break;
      }

      var blob = ByteData.sublistView(list);
      for (int i = 0; i < list.length; i++) {
        if (cursor % (sampleStep * 4) == 1) {
          //try to implement lowpass filter here
          var val = blob.getInt8(i).abs();

          //do a rudimentary dynamic range expansion
          if (val < 30) val = (val * 0.2).round();
          if (val > 40) val = (val * 1.5).round();
          if (maxValue < val) maxValue = val;
          pos < expectedSize ? _samples[pos++] = val : _samples.add(val);
        }
        cursor++;
      }
      len += list.length;
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

    print("Length: $len");
    print(
        "expected length ${(bytes / sampleStep).ceil()}, final length ${_samples.length}");
    print('decode executed in ${stopwatch.elapsed}');

    await release();
    onFinish();
  }
}
