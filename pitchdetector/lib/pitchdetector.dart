import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pitchdetectorclass.dart';

class Pitchdetector {
  static const MethodChannel _channel = const MethodChannel('pitchdetector');
  late StreamController<Map<String, double>> _recorderController;
  bool _isRecording = false;
  double? _pitch;

  int sampleSize = 2048;
  int sampleRate = 22050;
  List pcmSamples = [];
  late YIN yin;
  Pitchdetector({required this.sampleSize, required this.sampleRate}) {
    _channel.invokeMethod("initializeValues",
        {"sampleRate": sampleRate, "sampleSize": sampleSize});
  }

  Stream<Map<String, double>> get onRecorderStateChanged =>
      _recorderController.stream;

  bool get isRecording => _isRecording;
  double? get pitch => _pitch;

  Future<bool> checkPermission() async {
    return Permission.microphone.request().isGranted;
  }

  startRecording() async {
    _recorderController = StreamController<Map<String, double>>.broadcast();
    if (await checkPermission()) {
      try {
        print("check permission");
        _pitch = null;
        var result = await _channel.invokeMethod('startRecording');
        _isRecording = true;
        createChannelHandler();
      } catch (ex) {
        print(ex);
      }
    } else {}
  }

  createChannelHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "getPcm":
          if (_isRecording) {
            pcmSamples = call.arguments;
            //getPitchAsync(pcmSamples);
            var pitch = yin.getPitch(pcmSamples);
          }
          break;
        case "getPitch":
          if (_isRecording) {
            _recorderController.add({"pitch": call.arguments});
          }
          break;
        default:
          throw new ArgumentError("Unknown method: ${call.method}");
      }
      return null;
    });
  }

  Future getPitchAsync(pcmSamples) {
    return new Future.delayed(new Duration(milliseconds: 550), () {
      getPitchFromSamples(pcmSamples);
    });
  }

  getPitchFromSamples(pcmSamples) {
    double samplePitch = yin.getPitch(pcmSamples);
    if (samplePitch > -1.0) {
      _pitch = samplePitch;
    }
  }

  stopRecording() async {
    try {
      _isRecording = false;
      //getPitchFromSamples(pcmSamples);
      destoryChannelHandler();
      _channel.invokeMethod('stopRecording');
    } catch (ex, stacktrace) {
      print(stacktrace.toString());
    }
  }

  destoryChannelHandler() {
    //_channel.set;
    _recorderController.close();
  }
}
