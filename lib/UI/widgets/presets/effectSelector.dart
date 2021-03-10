// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/material.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import 'effectEditor.dart';
import 'package:tinycolor/tinycolor.dart';
import '../../../bluetooth/devices/effects/Processor.dart';
import '../../../bluetooth/devices/presets/Preset.dart';
import '../customPopupMenu.dart' as custom;

class EffectSelector extends StatefulWidget {
  final Preset preset;
  final NuxDevice device;

  EffectSelector({@required this.preset, @required this.device});
  @override
  _EffectSelectorState createState() => _EffectSelectorState();
}

class _EffectSelectorState extends State<EffectSelector> {
  List<bool> _effectSelection;
  //int _selectedEffect = 0;

  int get _selectedEffect => widget.device.selectedEffect;
  set _selectedEffect(val) => widget.device.selectedEffect = val;

  List<Widget> _buttons;
  Preset _preset;
  List<custom.PopupMenuEntry<dynamic>> _effectItems;
  String _selectedEffectName;

  Color _effectColor;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> createSlotButtons() {
    var btns = <Widget>[];
    for (int i = 0; i < _effectSelection.length; i++) {
      Color c = _preset.slotEnabled(i) ? _preset.effectColor(i) : null;
      btns.add(
        Column(
          children: [
            Icon(
              widget.device.processorList[i].icon,
              size: 30,
              color: c,
            ),
            Text(
              widget.device.processorList[i].shortName,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }
    return btns;
  }

  @override
  Widget build(BuildContext context) {
    _preset = widget.preset;

    _effectSelection =
        List<bool>.filled(widget.device.processorList.length, false);
    _effectSelection[_selectedEffect] = true;

    _effectColor = _preset.effectColor(_selectedEffect);

    //create effect buttons
    _buttons = createSlotButtons();

    //create effect models dropdown list
    List<Processor> effects = _preset.getEffectsForSlot(_selectedEffect);

    //effect color for popup menu. Make sure it's contrasty to the text
    var _popupEffectColor = _effectColor;
    for (int i = 0; i < 2; i++)
      if (TinyColor(_popupEffectColor).isLight())
        _popupEffectColor = TinyColor(_popupEffectColor).darken(15).color;

    _selectedEffectName = _preset
        .getEffectsForSlot(
            _selectedEffect)[_preset.getSelectedEffectForSlot(_selectedEffect)]
        .name;

    //create popup menu
    _effectItems = <custom.PopupMenuEntry<dynamic>>[];
    for (int f = 0; f < effects.length; f++) {
      if (effects[f].isSeparator == true) {
        _effectItems.add(custom.PopupMenuDivider(
          text: effects[f].category,
          color: Colors.grey,
        ));
      }

      _effectItems.add(custom.PopupMenuItem(
        value: f,
        backgroundColor: f == _preset.getSelectedEffectForSlot(_selectedEffect)
            ? _popupEffectColor
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            effects[f].name,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
    }

    var effectSelectButton = Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              widget.device.processorList[_selectedEffect].icon,
              color: _effectColor,
            ),
            Text(
              widget.device.processorList[_selectedEffect].longName,
              style:
                  TextStyle(color: _effectColor, fontWeight: FontWeight.bold),
            ),
            if (_selectedEffect != 0) SizedBox(height: 1, width: 8),
            if (_selectedEffect != 0)
              Text(
                _selectedEffectName,
                style: TextStyle(color: Colors.white),
              )
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
          selectedColor: Colors.grey[600],
          selectedBorderColor: _effectColor,
          children: _buttons,
          isSelected: _effectSelection,
          onPressed: (int index) {
            setState(() {
              for (int buttonIndex = 0;
                  buttonIndex < _effectSelection.length;
                  buttonIndex++) {
                if (buttonIndex == index) {
                  _effectSelection[buttonIndex] = true;
                  _selectedEffect = buttonIndex;
                } else {
                  _effectSelection[buttonIndex] = false;
                }
              }
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedEffect != 0)
              custom.PopupMenuButton(
                child: effectSelectButton,
                itemBuilder: (context) => _effectItems,
                onSelected: (index) {
                  setState(() {
                    _preset.setSelectedEffectForSlot(
                        _selectedEffect, index, true);
                  });
                },
              )
            else
              effectSelectButton,
            Row(
              children: [
                if (_selectedEffect != 0)
                  IconButton(
                    onPressed: () {
                      var effect =
                          _preset.getSelectedEffectForSlot(_selectedEffect) - 1;
                      if (effect < 0) effect = effects.length - 1;
                      setState(() {
                        _preset.setSelectedEffectForSlot(
                            _selectedEffect, effect, true);
                      });
                    },
                    icon: Transform.rotate(
                        angle: pi,
                        child: Icon(Icons.play_arrow,
                            color: TinyColor(_effectColor).brighten(20).color)),
                    iconSize: 30,
                  ),
                if (_selectedEffect != 0)
                  IconButton(
                    onPressed: () {
                      var effect =
                          _preset.getSelectedEffectForSlot(_selectedEffect) + 1;
                      if (effect > effects.length - 1) effect = 0;
                      setState(() {
                        _preset.setSelectedEffectForSlot(
                            _selectedEffect, effect, true);
                      });
                    },
                    icon: Icon(Icons.play_arrow,
                        color: TinyColor(_effectColor).brighten(20).color),
                    iconSize: 30,
                  ),
                if (_preset.slotSwitchable(_selectedEffect))
                  Switch(
                    value: _preset.slotEnabled(_selectedEffect),
                    onChanged: (val) {
                      setState(() {
                        _preset.setSlotEnabled(_selectedEffect, val, true);
                      });
                    },
                    activeColor: TinyColor(_effectColor).brighten(20).color,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey[700],
                  ),
              ],
            ),
          ],
        ),
        EffectEditor(
          preset: _preset,
          slot: _selectedEffect,
        )
      ],
    );
  }
}
