// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/Preset.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import 'effectSelector.dart';

class ChannelSelector extends StatefulWidget {
  final NuxDevice device;
  ChannelSelector({@required this.device});

  @override
  _ChannelSelectorState createState() => _ChannelSelectorState();
}

class _ChannelSelectorState extends State<ChannelSelector> {
  List<bool> _channelsSelection;
  List<Widget> _buttons;
  List<Preset> _presets;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _buttons = <Widget>[];

    _presets = widget.device.getGroupPresets(widget.device.selectedGroup);

    _channelsSelection = List<bool>.filled(_presets.length, false);
    _channelsSelection[widget.device.selectedChannelNormalized] = true;

    for (int i = 0; i < _channelsSelection.length; i++) {
      _buttons.add(
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.circle),
                Text(_presets[i].channelName),
              ],
            )),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          selectedColor:
              _presets[widget.device.selectedChannelNormalized].channelColor,
          selectedBorderColor:
              _presets[widget.device.selectedChannelNormalized].channelColor,
          children: _buttons,
          isSelected: _channelsSelection,
          onPressed: (int index) {
            if (_channelsSelection[index] == true) return;
            setState(() {
              for (int buttonIndex = 0;
                  buttonIndex < _channelsSelection.length;
                  buttonIndex++) {
                if (buttonIndex == index) {
                  _channelsSelection[buttonIndex] = true;
                  widget.device.selectedChannelNormalized = buttonIndex;
                  widget.device.resetToNuxPreset();
                } else {
                  _channelsSelection[buttonIndex] = false;
                }
              }
            });
          },
        ),
        EffectSelector(
            device: widget.device,
            preset: _presets[widget.device.selectedChannelNormalized])
      ],
    );
  }
}
