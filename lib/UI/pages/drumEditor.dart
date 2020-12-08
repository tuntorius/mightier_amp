// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../bluetooth/devices/effects/Delay.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../widgets/thickSlider.dart';
import '../widgets/scrollPicker.dart';
import 'dart:math' as Math;

class DrumEditor extends StatefulWidget {
  @override
  _DrumEditorState createState() => _DrumEditorState();
}

class _DrumEditorState extends State<DrumEditor> {
  int selectedDrumPattern = 0;
  final NuxDevice device = NuxDeviceControl().device;
  DelayTapTimer timer = DelayTapTimer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDrumPattern = device.selectedDrumStyle;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ScrollPicker(
              initialValue: selectedDrumPattern,
              items: NuxDevice.drumStyles,
              onChanged: (value) {
                setState(() {
                  selectedDrumPattern = value;
                });
              },
              onChangedFinal: (value) {
                setState(() {
                  device.setDrumsStyle(value);
                  device.setDrumsTempo(device.drumsTempo);
                });
              },
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Drums",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headline5
                          .copyWith(color: Colors.white),
                    ),
                    Switch(
                      value: device.drumsEnabled,
                      onChanged: (value) {
                        setState(() {
                          device.setDrumsEnabled(value);
                        });
                      },
                    )
                  ],
                ),
                ThickSlider(
                  min: 0,
                  max: 100,
                  activeColor: Colors.blue,
                  label: "Volume",
                  value: device.drumsVolume.toDouble(),
                  labelFormatter: (val) => "${device.drumsVolume}",
                  onChanged: (val) {
                    setState(() {
                      device.setDrumsLevel(val.round());
                    });
                  },
                ),
                ThickSlider(
                  min: 40,
                  max: 240,
                  skipEmitting: 5,
                  activeColor: Colors.blue,
                  label: "Tempo",
                  value: device.drumsTempo,
                  labelFormatter: (val) =>
                      "${device.drumsTempo.toStringAsFixed(2)} BPM",
                  onChanged: (val) {
                    setState(() {
                      device.setDrumsTempo(val);
                    });
                  },
                ),
                RawMaterialButton(
                  onPressed: () {
                    timer.addClickTime();
                    var result = timer.calculate();
                    if (result != false) {
                      setState(() {
                        var bpm = 60 / (result / 1000);
                        bpm = Math.min(Math.max(bpm, 40), 240);
                        device.setDrumsTempo(bpm);
                      });
                    }
                  },
                  elevation: 2.0,
                  fillColor: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Tap",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
