// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:undo/undo.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/effects/Processor.dart';
import '../../../bluetooth/devices/presets/Preset.dart';
import 'effectEditors/EqualizerEditor.dart';
import 'effectEditors/SlidersEditor.dart';

class EffectEditor extends StatefulWidget {
  final Preset preset;
  final int slot;
  const EffectEditor({Key? key, required this.preset, required this.slot})
      : super(key: key);
  @override
  State createState() => _EffectEditorState();
}

class _EffectEditorState extends State<EffectEditor> {
  @override
  Widget build(BuildContext context) {
    var preset = widget.preset;
    var slot = widget.slot;

    //get all the parameters for the slot
    List<Processor> prc = preset.getEffectsForSlot(slot);

    //create the widgets to edit them
    var selected = preset.getSelectedEffectForSlot(slot);

    switch (prc[selected].editorUI) {
      case EffectEditorUI.Sliders:
        return SlidersEditor(preset: widget.preset, slot: widget.slot);
      case EffectEditorUI.EQ:
        return EqualizerEditor(
          eqEffect: prc[selected],
          enabled: widget.preset.slotEnabled(widget.slot),
          onChanged: (parameter, value, skip) {
            setState(() {
              widget.preset.setParameterValue(parameter, value, notify: !skip);
            });
          },
          onChangedFinal: _updateSliderValue,
        );
    }
  }

  void _updateSliderValue(
      Parameter parameter, double newValue, double oldValue) {
    var device = NuxDeviceControl().device;
    var slot = device.selectedSlot;

    NuxDeviceControl.instance().changes.add(
            Change<({double value, int selectedSlot})>(
                (value: oldValue, selectedSlot: slot), () {
          var currentSlot = device.selectedSlot;
          if (slot != currentSlot) {
            device.selectedSlot = slot;
          }
          widget.preset.setParameterValue(parameter, newValue);
        }, (oldVal) {
          var currentSlot = device.selectedSlot;
          if (oldVal.selectedSlot != currentSlot) {
            device.selectedSlot = oldVal.selectedSlot;
          }
          widget.preset.setParameterValue(parameter, oldVal.value);
        }));
    NuxDeviceControl.instance().undoStackChanged();
  }
}
