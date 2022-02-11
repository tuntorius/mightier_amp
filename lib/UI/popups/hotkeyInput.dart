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

  _applyHotkey() {
    if (_hotkeyCode != null) {
      do {
        bool ignoreLowByte = _control == HotkeyControl.ParameterSet;
        var hk = _midiController.getHotkeyByCode(_hotkeyCode!, ignoreLowByte);
        if (hk != null)
          _midiController.removeHotkey(hk);
        else
          break;
      } while (_control == HotkeyControl.ParameterSet);
      _midiController.assignHotkey(
          _control, _index, _subindex, _hotkeyCode!, controller.text);
      MidiControllerManager().saveConfig();
    } else {
      _midiController.removeHotkeyByFunction(_control, _index, _subindex);
      MidiControllerManager().saveConfig();
    }

    Navigator.of(_context).pop();
  }

  _onControllerData(int code, int? sliderValue, String name) {
    controller.text = name;
    _hotkeyCode = code;
  }

  Widget buildDialog(BuildContext context,
      {required MidiController midiController,
      required HotkeyControl ctrl,
      required int ctrlIndex,
      required int ctrlSubIndex,
      required String hotkeyName}) {
    _midiController = midiController;
    _context = context;
    _control = ctrl;
    _index = ctrlIndex;
    _subindex = ctrlSubIndex;

    var hk = _midiController.getHotkeyByFunction(ctrl, ctrlIndex, ctrlSubIndex);

    controller = TextEditingController(text: hk == null ? None : hk.hotkeyName);

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
      child: AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop()),
            Text('Set hotkey'),
          ],
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Press the control you wish to assign to $hotkeyName"),
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
              child: Text("Clear")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel")),
          TextButton(
              onPressed: _applyHotkey,
              child: Text(
                "OK",
                style: TextStyle(color: Colors.blue),
              ))
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }
}
