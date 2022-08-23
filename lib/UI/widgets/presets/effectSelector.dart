// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/presets/EffectChainBar.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:undo/undo.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import 'EffectChainButton.dart';
import 'effectEditor.dart';
import 'package:tinycolor2/tinycolor2.dart';
import '../../../bluetooth/devices/effects/Processor.dart';
import '../../../bluetooth/devices/presets/Preset.dart';
import '../customPopupMenu.dart' as custom;

class EffectSelector extends StatefulWidget {
  final Preset preset;
  final NuxDevice device;

  EffectSelector({required this.preset, required this.device});
  @override
  _EffectSelectorState createState() => _EffectSelectorState();
}

class _EffectSelectorState extends State<EffectSelector> {
  int get _selectedSlot => widget.device.selectedSlot;
  set _selectedSlot(val) => widget.device.selectedSlot = val;

  late Preset _preset;
  late List<custom.PopupMenuEntry<dynamic>> _effectItems;
  String _selectedEffectName = "";

  late Color _effectColor;

  @override
  void initState() {
    super.initState();
  }

  void setSelectedEffect(dynamic index) {
    //the index param is always int, it's dynamic because the menu widget requires that

    setState(() {
      var device = NuxDeviceControl.instance().device;

      //put new effect in stack
      var oldEffect = _preset.getSelectedEffectForSlot(_selectedSlot);
      List<Change<int>> totalChanges = [];

      totalChanges.add(Change<int>(
          oldEffect,
          () => _preset.setSelectedEffectForSlot(_selectedSlot, index, true),
          (oldVal) =>
              _preset.setSelectedEffectForSlot(_selectedSlot, oldVal, true)));

      if (device.cabinetSupport &&
          SharedPrefs().getInt(SettingsKeys.changeCabs, 1) == 1) {
        if (_selectedSlot == device.amplifierSlotIndex) {
          //get the cabinet for this amp and set it
          Processor amp = _preset.getEffectsForSlot(_selectedSlot)[index];
          if (amp is Amplifier) {
            var oldEffect =
                _preset.getSelectedEffectForSlot(device.cabinetSlotIndex);
            totalChanges.add(Change<int>(
                oldEffect,
                () => _preset.setSelectedEffectForSlot(
                    device.cabinetSlotIndex, amp.defaultCab, true),
                (oldVal) => _preset.setSelectedEffectForSlot(
                    device.cabinetSlotIndex, oldVal, true)));
          }
        }
      }
      if (totalChanges.length == 1)
        NuxDeviceControl.instance().changes.add(totalChanges[0]);
      else
        NuxDeviceControl.instance().changes.addGroup(totalChanges);
      NuxDeviceControl.instance().undoStackChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    _preset = widget.preset;

    _effectColor = _preset.effectColor(_selectedSlot);

    //create effect models dropdown list
    List<Processor> effects = _preset.getEffectsForSlot(_selectedSlot);

    //effect color for popup menu. Make sure it's contrasty to the text
    var _popupEffectColor = _effectColor;

    //try to darken up to 2 times until the color is not light anymore
    for (int i = 0; i < 2; i++)
      if (TinyColor(_popupEffectColor).isLight())
        _popupEffectColor = TinyColor(_popupEffectColor).darken(15).color;

    _selectedEffectName = _preset
        .getEffectsForSlot(
            _selectedSlot)[_preset.getSelectedEffectForSlot(_selectedSlot)]
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
        backgroundColor: f == _preset.getSelectedEffectForSlot(_selectedSlot)
            ? _popupEffectColor
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            effects[f].name,
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
              widget.device.processorList[_selectedSlot].icon,
              color: _effectColor,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              widget.device.processorList[_selectedSlot].longName,
              style:
                  TextStyle(color: _effectColor, fontWeight: FontWeight.bold),
            ),
            if (_effectItems.length > 1) SizedBox(height: 1, width: 8),
            if (_effectItems.length > 1) Text(_selectedEffectName)
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        EffectChainBar(
            maxHeight: 60,
            effectsList: widget.device.processorList,
            preset: _preset,
            reorderable: widget.device.reorderableFXChain,
            onTap: (i) {
              setState(() {
                var old = _selectedSlot;
                _selectedSlot = i;

                NuxDeviceControl.instance().changes.add(Change<int>(
                    old,
                    () => _selectedSlot = i,
                    (oldVal) => _selectedSlot = oldVal));
                NuxDeviceControl.instance().undoStackChanged();
              });
            },
            onReorder: (from, to) {
              setState(() {
                NuxDeviceControl.instance().changes.add(Change(
                    1,
                    () => _preset.swapProcessorSlots(from, to, true),
                    (oldVal) => _preset.swapProcessorSlots(from, to, true)));
              });
            }),
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedSlot != 0 && _effectItems.length > 1)
              custom.PopupMenuButton(
                child: effectSelectButton,
                itemBuilder: (context) => _effectItems,
                onSelected: setSelectedEffect,
              )
            else
              effectSelectButton,
            SizedBox(
                width: 1,
                height: 48), //used to even out sizes when switch is not visible
            Row(
              children: [
                if (_selectedSlot != 0 && _effectItems.length > 1)
                  IconButton(
                    onPressed: () {
                      var effect =
                          _preset.getSelectedEffectForSlot(_selectedSlot) - 1;
                      if (effect < 0) effect = effects.length - 1;
                      setSelectedEffect(effect);
                    },
                    icon: Transform.rotate(
                        angle: pi,
                        child: Icon(Icons.play_arrow,
                            color: TinyColor(_effectColor).brighten(20).color)),
                    iconSize: 30,
                  ),
                if (_selectedSlot != 0 && _effectItems.length > 1)
                  IconButton(
                    onPressed: () {
                      var effect =
                          _preset.getSelectedEffectForSlot(_selectedSlot) + 1;
                      if (effect > effects.length - 1) effect = 0;
                      setSelectedEffect(effect);
                    },
                    icon: Icon(Icons.play_arrow,
                        color: TinyColor(_effectColor).brighten(20).color),
                    iconSize: 30,
                  ),
                if (_preset.slotSwitchable(_selectedSlot))
                  Switch(
                    value: _preset.slotEnabled(_selectedSlot),
                    onChanged: (val) {
                      setState(() {
                        NuxDeviceControl.instance().changes.add(Change<bool>(
                            !val,
                            () => _preset.setSlotEnabled(
                                _selectedSlot, val, true),
                            (oldVal) => _preset.setSlotEnabled(
                                _selectedSlot, oldVal, true)));
                        NuxDeviceControl.instance().undoStackChanged();
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
        if (isPortrait)
          Expanded(
              child: EffectEditor(
            preset: _preset,
            slot: _selectedSlot,
          ))
        else
          EffectEditor(
            preset: _preset,
            slot: _selectedSlot,
          )
      ],
    );
  }
}
