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
    var _selected = preset.getSelectedEffectForSlot(slot);

    switch (prc[_selected].editorUI) {
      case EffectEditorUI.Sliders:
        return SlidersEditor(preset: widget.preset, slot: widget.slot);
      case EffectEditorUI.EQ:
        return EqualizerEditor(
          eqEffect: prc[_selected],
          onChanged: (parameter, value) {
            setState(() {
              widget.preset.setParameterValue(parameter, value);
            });
          },
          onChangedFinal: (parameter, newValue, oldValue) {
            NuxDeviceControl.instance().changes.add(Change<double>(
                oldValue,
                () => widget.preset.setParameterValue(parameter, newValue),
                (oldVal) =>
                    widget.preset.setParameterValue(parameter, oldVal)));
            NuxDeviceControl.instance().undoStackChanged();
          },
        );
    }
  }
}
