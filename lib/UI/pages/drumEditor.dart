// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/utilities/DelayTapTimer.dart';
import '../widgets/thickSlider.dart';
import '../widgets/scrollPicker.dart';
import 'dart:math' as Math;

class DrumEditor extends StatefulWidget {
  DrumEditor();
  @override
  _DrumEditorState createState() => _DrumEditorState();
}

class _DrumEditorState extends State<DrumEditor> {
  int selectedDrumPattern = 0;
  //final NuxDevice device = NuxDeviceControl().device;
  DelayTapTimer timer = DelayTapTimer();

  bool remoteDrumStyleChange = false;

  @override
  void initState() {
    super.initState();
    NuxDeviceControl().addListener(onDeviceChanged);
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl().removeListener(onDeviceChanged);
  }

  void onDeviceChanged() {
    remoteDrumStyleChange = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    NuxDevice? device = NuxDeviceControl().device;
    final ThemeData theme = Theme.of(context);

    selectedDrumPattern = device.selectedDrumStyle;
    Orientation orientation = MediaQuery.of(context).orientation;
    var height = 3;
    if (orientation == Orientation.portrait) {
      if (MediaQuery.of(context).size.height < 640)
        height = 4;
      else
        height = 5;
    }

    double padding = isPortrait ? 0 : MediaQuery.of(context).size.width * 0.25;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Container(
              decoration: isPortrait
                  ? null
                  : BoxDecoration(
                      border:
                          Border.all(color: Theme.of(context).disabledColor),
                      borderRadius: BorderRadius.circular(6)),
              height: ScrollPicker.itemHeight * height,
              child: Container(
                child: ScrollPicker(
                  showDivider: false,
                  remoteChange: remoteDrumStyleChange,
                  initialValue: selectedDrumPattern,
                  items: device.getDrumStyles(),
                  onChanged: (value) {
                    setState(() {
                      selectedDrumPattern = value;
                    });
                  },
                  onChangedFinal: (value, remote) {
                    if (remote)
                      remoteDrumStyleChange = false;
                    else
                      setState(() {
                        device.setDrumsStyle(value);
                        device.setDrumsTempo(device.drumsTempo);
                      });
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Drums",
                textAlign: TextAlign.center,
                style: theme.textTheme.headline5!.copyWith(color: Colors.white),
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
          Flexible(
            child: ThickSlider(
              min: 0,
              max: 100,
              activeColor: Colors.blue,
              label: "Volume",
              handleVerticalDrag: isPortrait,
              value: device.drumsVolume.toDouble(),
              labelFormatter: (val) => "${device.drumsVolume.round()} %",
              onChanged: (val) {
                setState(() {
                  device.setDrumsLevel(val);
                });
              },
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: ThickSlider(
              min: 40,
              max: 240,
              skipEmitting: 5,
              activeColor: Colors.blue,
              label: "Tempo",
              handleVerticalDrag: isPortrait,
              value: device.drumsTempo,
              labelFormatter: (val) =>
                  "${device.drumsTempo.toStringAsFixed(2)} BPM",
              onChanged: (val) {
                setState(() {
                  device.setDrumsTempo(val);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: RawMaterialButton(
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
              padding: EdgeInsets.all(12.0),
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
