// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/presets/EffectChainBar.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:undo/undo.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../../bluetooth/devices/NuxFXID.dart';
import '../../utils.dart';
import 'effectEditor.dart';
import 'package:tinycolor2/tinycolor2.dart';
import '../../../bluetooth/devices/effects/Processor.dart';
import '../../../bluetooth/devices/presets/Preset.dart';
import '../common/customPopupMenu.dart' as custom;

class EffectSelector extends StatefulWidget {
  final Preset preset;
  final NuxDevice device;

  const EffectSelector({Key? key, required this.preset, required this.device})
      : super(key: key);
  @override
  State createState() => _EffectSelectorState();
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
      var effectSlot = _selectedSlot;
      //put new effect in stack
      var oldEffect = (
        slot: _selectedSlot,
        index: _preset.getSelectedEffectForSlot(_selectedSlot),
      );
      List<Change<({int slot, int index})>> totalChanges = [];

      totalChanges.add(Change(oldEffect, () {
        if (_selectedSlot != effectSlot) _selectedSlot = effectSlot;
        _preset.setSelectedEffectForSlot(effectSlot, index, true);
      }, (oldVal) {
        if (_selectedSlot != oldVal.slot) _selectedSlot = oldVal.slot;
        _preset.setSelectedEffectForSlot(oldVal.slot, oldVal.index, true);
      }));

      if (device.cabinetSupport &&
          SharedPrefs().getInt(SettingsKeys.changeCabs, 1) == 1) {
        if (_selectedSlot == device.amplifierSlotIndex) {
          //get the cabinet for this amp and set it
          Processor amp = _preset.getEffectsForSlot(_selectedSlot)[index];
          if (amp is Amplifier) {
            var proc = _preset.getFXIDFromSlot(device.cabinetSlotIndex);
            var cabIndex =
                _preset.getEffectArrayIndexFromNuxIndex(proc, amp.defaultCab);
            var oldEffect = (
              slot: device.cabinetSlotIndex,
              index: _preset.getSelectedEffectForSlot(device.cabinetSlotIndex)
            );
            totalChanges.add(Change(
                oldEffect,
                () => _preset.setSelectedEffectForSlot(
                    device.cabinetSlotIndex, cabIndex, true),
                (oldVal) => _preset.setSelectedEffectForSlot(
                    oldVal.slot, oldVal.index, true)));
          }
        }
      }
      if (totalChanges.length == 1) {
        NuxDeviceControl.instance().changes.add(totalChanges[0]);
      } else {
        NuxDeviceControl.instance().changes.addGroup(totalChanges);
      }
      NuxDeviceControl.instance().undoStackChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    var layout = getEditorLayoutMode(MediaQuery.of(context));
    _preset = widget.preset;

    _effectColor = _preset.effectColor(_selectedSlot);
    var _effectColorBright =
        TinyColor.fromColor(_effectColor).brighten(20).color;

    var proc = _preset.getFXIDFromSlot(_selectedSlot);
    var effectInfo = widget.device.getProcessorInfoByFXID(proc)!;

    //create effect models dropdown list
    List<Processor> effects = _preset.getEffectsForSlot(_selectedSlot);

    //effect color for popup menu. Make sure it's contrasty to the text
    var popupEffectColor = _effectColor;

    //try to darken up to 2 times until the color is not light anymore
    for (int i = 0; i < 2; i++) {
      if (TinyColor.fromColor(popupEffectColor).isLight()) {
        popupEffectColor =
            TinyColor.fromColor(popupEffectColor).darken(15).color;
      }
    }

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
            ? popupEffectColor
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "${f + 1}. ${effects[f].name}",
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
              effectInfo.icon,
              color: _effectColorBright,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              effectInfo.longName,
              style: TextStyle(
                  color: _effectColorBright, fontWeight: FontWeight.bold),
            ),
            if (_effectItems.length > 1) const SizedBox(height: 1, width: 8),
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
            device: widget.device,
            preset: _preset,
            reorderable: widget.device.reorderableFXChain,
            onTap: (i) {
              setState(() {
                _selectedSlot = i;
              });
            },
            onDoubleTap: (int i) {
              if (_preset.slotSwitchable(i)) {
                bool state = _preset.slotEnabled(i);
                _setSlotEnabledState(i, !state);
              }
            },
            onReorder: (from, to) {
              var old = from + to * 100;
              setState(() {
                NuxDeviceControl.instance().changes.add(Change<int>(old, () {
                      //get type of old slot
                      var selectedType = _preset.getFXIDFromSlot(_selectedSlot);
                      _preset.swapProcessorSlots(from, to, true);
                      _selectSlotByFXID(selectedType);
                    }, (oldVal) {
                      //get type of old slot
                      var selectedType = _preset.getFXIDFromSlot(_selectedSlot);
                      int from = oldVal % 100;
                      int to = (oldVal / 100).floor();
                      //positions are swapped on undo
                      _preset.swapProcessorSlots(to, from, true);
                      _selectSlotByFXID(selectedType);
                    }));
                NuxDeviceControl.instance().undoStackChanged();
              });
            }),
        const SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_effectItems.length > 1)
                custom.PopupMenuButton(
                  itemBuilder: (context) => _effectItems,
                  onSelected: setSelectedEffect,
                  initialValue: _preset.getSelectedEffectForSlot(_selectedSlot),
                  child: effectSelectButton,
                )
              else
                ExcludeSemantics(child: effectSelectButton),
              const SizedBox(
                  width: 1,
                  height:
                      48), //used to even out sizes when switch is not visible
              Row(
                children: [
                  if (_effectItems.length > 1)
                    IconButton(
                      tooltip: "Previous effect",
                      onPressed: () {
                        var effect =
                            _preset.getSelectedEffectForSlot(_selectedSlot) - 1;
                        if (effect < 0) effect = effects.length - 1;
                        setSelectedEffect(effect);
                      },
                      icon: Transform.rotate(
                          angle: pi,
                          child: Icon(Icons.play_arrow,
                              color: _effectColorBright)),
                      iconSize: 30,
                    ),
                  if (_effectItems.length > 1)
                    IconButton(
                      tooltip: "Next effect",
                      onPressed: () {
                        var effect =
                            _preset.getSelectedEffectForSlot(_selectedSlot) + 1;
                        if (effect > effects.length - 1) effect = 0;
                        setSelectedEffect(effect);
                      },
                      icon: Icon(Icons.play_arrow, color: _effectColorBright),
                      iconSize: 30,
                    ),
                  if (_preset.slotSwitchable(_selectedSlot))
                    Tooltip(
                      message: "Toggle ${effectInfo.longName}",
                      child: Switch(
                        value: _preset.slotEnabled(_selectedSlot),
                        onChanged: (val) {
                          _setSlotEnabledState(_selectedSlot, val);
                        },
                        activeColor: _effectColorBright,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (layout == EditorLayoutMode.expand)
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

  void _setSlotEnabledState(int slot, bool value) {
    setState(() {
      NuxDeviceControl.instance().changes.add(Change<bool>(
          !value,
          () => _preset.setSlotEnabled(slot, value, true),
          (oldVal) => _preset.setSlotEnabled(slot, oldVal, true)));
      NuxDeviceControl.instance().undoStackChanged();
    });
  }

  void _selectSlotByFXID(NuxFXID type) {
    for (int i = 0; i < widget.device.effectsChainLength; i++) {
      if (_preset.getFXIDFromSlot(i) == type) _selectedSlot = i;
    }
  }
}
