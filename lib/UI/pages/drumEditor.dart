// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/utils.dart';
import 'package:mighty_plug_manager/main.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/utilities/DelayTapTimer.dart';
import '../widgets/thickSlider.dart';
import '../widgets/scrollPicker.dart';
import 'dart:math' as math;

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
    NuxDeviceControl.instance().addListener(onDeviceChanged);
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl.instance().removeListener(onDeviceChanged);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final layoutMode = getLayoutMode(mediaQuery);

    NuxDevice? device = NuxDeviceControl.instance().device;
    final ThemeData theme = Theme.of(context);

    selectedDrumPattern = device.selectedDrumStyle;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (layoutMode == LayoutMode.navBar)
            SizedBox(
              height: _getScrollPickerHeight(mediaQuery),
              child: ScrollPicker(
                showDivider: false,
                remoteChange: remoteDrumStyleChange,
                initialValue: selectedDrumPattern,
                items: device.getDrumStyles(),
                onChanged: _onScrollPickerChanged,
                onChangedFinal: (value, remote) {
                  _onScrollPickerChangedFinal(value, remote, device);
                },
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
          ThickSlider(
            min: 0,
            max: 100,
            activeColor: Colors.blue,
            label: "Volume",
            handleVerticalDrag: layoutMode == LayoutMode.drawer,
            value: device.drumsVolume.toDouble(),
            labelFormatter: (val) => "${device.drumsVolume.round()} %",
            onChanged: (val) {
              setState(() {
                device.setDrumsLevel(val);
              });
            },
          ),
          ThickSlider(
            min: 40,
            max: 240,
            skipEmitting: 5,
            activeColor: Colors.blue,
            label: "Tempo",
            handleVerticalDrag: layoutMode == LayoutMode.drawer,
            value: device.drumsTempo,
            labelFormatter: (val) =>
                "${device.drumsTempo.toStringAsFixed(1)} BPM",
            onChanged: (val) {
              setState(() {
                device.setDrumsTempo(val);
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (layoutMode == LayoutMode.drawer) ...[
                Flexible(
                  child: SizedBox(
                    height: _getScrollPickerHeight(mediaQuery),
                    child: ScrollPicker(
                      showDivider: false,
                      remoteChange: remoteDrumStyleChange,
                      initialValue: selectedDrumPattern,
                      items: device.getDrumStyles(),
                      onChanged: _onScrollPickerChanged,
                      onChangedFinal: (value, remote) {
                        _onScrollPickerChangedFinal(value, remote, device);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Flexible(
                flex: 2,
                child: MaterialButton(
                  height: _getScrollPickerHeight(mediaQuery),
                  color: Colors.blue.withOpacity(0.2),
                  onPressed: () {
                    timer.addClickTime();
                    var result = timer.calculate();
                    if (result != false) {
                      setState(() {
                        var bpm = 60 / (result / 1000);
                        bpm = math.min(math.max(bpm, 40), 240);
                        device.setDrumsTempo(bpm);
                      });
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Tap",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  double _getScrollPickerHeight(MediaQueryData mediaQuery) {
    Orientation orientation = mediaQuery.orientation;
    var numOfSelectItems = 3;
    if (orientation == Orientation.portrait) {
      if (mediaQuery.size.height < 640) {
        numOfSelectItems = 4;
      } else {
        numOfSelectItems = 5;
      }
    }
    return ScrollPicker.itemHeight * numOfSelectItems;
  }

  void _onScrollPickerChanged(value) {
    setState(() {
      selectedDrumPattern = value;
    });
  }

  void _onScrollPickerChangedFinal(int value, bool remote, NuxDevice? device) {
    if (remote) {
      remoteDrumStyleChange = false;
    } else {
      setState(() {
        device?.setDrumsStyle(value);
        device?.setDrumsTempo(device.drumsTempo);
      });
    }
  }

  void onDeviceChanged() {
    remoteDrumStyleChange = true;
    setState(() {});
  }
}
