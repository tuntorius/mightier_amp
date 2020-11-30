// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../widgets/thickSlider.dart';
import '../widgets/scrollPicker.dart';

class DrumEditor extends StatefulWidget {
  @override
  _DrumEditorState createState() => _DrumEditorState();
}

class _DrumEditorState extends State<DrumEditor> {
  int selectedDrumPattern = 0;
  final NuxDevice device = NuxDeviceControl().device;

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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
