// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/midi/ControllerConstants.dart';
import 'package:mighty_plug_manager/midi/MidiControllerManager.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

class HotkeyInputDialog {
  late BuildContext _context;
  late TextEditingController controller;

  static const None = "None";
  int? _hotkeyCode;
  late final MidiController _midiController;
  late HotkeyControl _control;
  late int _index;
  late int _subindex;
  bool _sliderMode = false;

  //slider mode vars
  int _previousCode = -1;
  int? previousSliderValue;
  bool _invert = false;

  _applyHotkey() {
    if (_hotkeyCode != null) {
      do {
        bool ignoreLowByte = _control == HotkeyControl.ParameterSet;
        var hk = _midiController.getHotkeyByCode(_hotkeyCode!, ignoreLowByte);
        if (hk != null) {
          _midiController.removeHotkey(hk);
        } else {
          break;
        }
      } while (_control == HotkeyControl.ParameterSet);
      _midiController.assignHotkey(
          _control, _index, _subindex, _hotkeyCode!, controller.text, _invert);
      MidiControllerManager().saveConfig();
    } else {
      _midiController.removeHotkeyByFunction(_control, _index, _subindex);
      MidiControllerManager().saveConfig();
    }

    Navigator.of(_context).pop();
  }

  _onControllerData(int code, int? sliderValue, String name) {
    if (_sliderMode) {
      if (sliderValue == null) return;
      if (_invert) sliderValue = 127 - sliderValue;
      code &= 0xffffff00;
      if (code == _previousCode && previousSliderValue != sliderValue) {
        //valid adjustment
        name = name.substring(0, name.length - 2);
        name += sliderValue.toRadixString(16).padLeft(2, '0');
        controller.text = name;
        _hotkeyCode = code;
      }
      _previousCode = code;
      previousSliderValue = sliderValue;
    } else {
      controller.text = name;
      _hotkeyCode = code;
    }
  }

  Widget buildDialog(BuildContext context,
      {required MidiController midiController,
      required HotkeyControl ctrl,
      required int ctrlIndex,
      required int ctrlSubIndex,
      required String hotkeyName,
      required bool sliderMode}) {
    _midiController = midiController;
    _context = context;
    _control = ctrl;
    _index = ctrlIndex;
    _subindex = ctrlSubIndex;
    _sliderMode = sliderMode;

    var hk = _midiController.getHotkeyByFunction(ctrl, ctrlIndex, ctrlSubIndex);

    controller = TextEditingController(text: hk == null ? None : hk.hotkeyName);
    _invert = hk?.invertSlider ?? false;

    MidiControllerManager().overrideOnData(_onControllerData);

    return FocusScope(
      autofocus: true,
      onKey: (node, event) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent' &&
            event.logicalKey.keyId != 0x100001005) {
          MidiControllerManager().onHIDData(event);
        }
        return KeyEventResult.skipRemainingHandlers;
      },
      child: StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop()),
              const Text('Set hotkey'),
            ],
          ),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            if (sliderMode)
              Text(
                  "Adjust the pedal/knob/slider you wish to assign to $hotkeyName")
            else
              Text("Press the control you wish to assign to $hotkeyName"),
            if (sliderMode)
              CheckboxListTile(
                  title: const Text("Invert"),
                  value: _invert,
                  onChanged: (value) {
                    setState(() {
                      _invert = value!;
                    });
                  }),
            AbsorbPointer(
              child: TextField(
                controller: controller,
                readOnly: true,
                autofocus: false,
              ),
            )
          ]),
          actions: [
            TextButton(
                onPressed: () {
                  controller.text = None;
                  _hotkeyCode = null;
                },
                child: const Text("Clear")),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel")),
            TextButton(
                onPressed: _applyHotkey,
                child: Text(
                  "OK",
                  style: TextStyle(color: Theme.of(context).hintColor),
                ))
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
        );
      }),
    );
  }
}
