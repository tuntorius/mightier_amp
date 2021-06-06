import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/nestedWillPopScope.dart';
import 'package:pitchdetector/pitchdetector.dart';

class GuitarTuner extends StatefulWidget {
  @override
  _GuitarTunerState createState() => _GuitarTunerState();
}

class Note {
  String name = "";
  int octave = 0;
  double diff = 0;
}

class _GuitarTunerState extends State<GuitarTuner> {
  static const indicatorWidth = 200.0;
  List<String> notes = [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B"
  ];

  bool recording = false;
  late Timer timer;
  double pitch = 0;
  late Pitchdetector detector;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    detector = Pitchdetector(sampleRate: 22050, sampleSize: 2048);
    detector.startRecording();
    detector.onRecorderStateChanged.listen(onPitchChanged);
  }

  void onPitchChanged(event) {
    setState(() {
      pitch = event["pitch"] ?? 0;
      print(pitch);
    });
  }

  Note? calculateNote(double pitch) {
    Note n = Note();
    var basef = 440; //TODO: custom???

    var c0 = basef * pow(2, (-57 / 12));
    if (pitch < c0) return null;
    var nsemi = 12 * log(pitch / c0) / log(2);

    n.octave = (nsemi / 12).floor(); //Scientific pitch notation octave number
    var nnote = nsemi - 12 * n.octave;

    var xnote = nnote.round();
    if (xnote == 12) {
      xnote = 0;
      n.octave++;
    }

    n.name = notes[xnote];

    //calc off-cents by getting
    var xsemi = nsemi.round();
    var diff = -((xsemi - nsemi) * 100).round() / 100;
    n.diff = diff;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    var note = calculateNote(pitch);
    return NestedWillPopScope(
      onWillPop: () {
        detector.stopRecording();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Guitar Tuner"),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pitch: $pitch',
              ),
              Text("${note?.name ?? '-'}${note?.octave ?? '-'}"),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 50,
                    width: indicatorWidth,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.blue)),
                  ),
                  Container(
                    width: 5,
                    height: 70,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.blue)),
                  ),
                  if (note != null)
                    Positioned(
                      left: indicatorWidth / 2 + (note.diff) * indicatorWidth,
                      child: Container(
                        width: 3,
                        height: 50,
                        color: Colors.green,
                      ),
                    )
                ],
              )
            ],
          ),
        ), // ,
      ),
    );
  }
}
