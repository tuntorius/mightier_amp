import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/midi/ControllerConstants.dart';

import 'ControllerHotkeys.dart';

enum ControllerType { Hid, MidiUsb, MidiBle }
enum ControllerStatus { Connected, Disconnected }

abstract class MidiController {
  String get name;
  String get id;
  ControllerType get type;

  List<ControllerHotkey> _hotkeys = [];

  //faster access by code
  Map<int, ControllerHotkey> _hotkeysDictionary = {};

  assignHotkey(HotkeyControl ctrl, int index, int subindex, int keyCode,
      String hotkeyName) {
    //find if already set for this function
    if (ctrl == HotkeyControl.ParameterSet) keyCode &= 0xffffff00;

    var hk = getHotkeyByFunction(ctrl, index, subindex);
    if (hk == null)
      hk = ControllerHotkey(
          control: ctrl,
          index: index,
          subIndex: subindex,
          hotkeyCode: keyCode,
          hotkeyName: hotkeyName);
    else {
      hk.hotkeyCode = keyCode;
      hk.hotkeyName = hotkeyName;
    }

    if (!_hotkeys.contains(hk)) {
      _hotkeys.add(hk);
      _rebuildDictionary();
    }
  }

  removeHotkey(ControllerHotkey? hk) {
    if (hk != null) {
      _hotkeys.remove(hk);
      _rebuildDictionary();
    }
  }

  removeHotkeyByFunction(HotkeyControl ctrl, int index, int subindex) {
    var hk = getHotkeyByFunction(ctrl, index, subindex);
    removeHotkey(hk);
  }

  ControllerHotkey? getHotkeyByCode(int code, bool ignoreLowByte) {
    if (_hotkeysDictionary.containsKey(code)) return _hotkeysDictionary[code];

    //now enumerate the dictionary and find keys with the lower byte set to 0
    var mainCode = code & 0xffffff00;
    for (var key in _hotkeysDictionary.keys) {
      var _key = key & 0xffffff00;
      if (_key == mainCode &&
          (ignoreLowByte ||
              _hotkeysDictionary[key]!.control == HotkeyControl.ParameterSet))
        return _hotkeysDictionary[key];
    }

    return null;
  }

  ControllerHotkey? getHotkeyByFunction(
      HotkeyControl ctrl, int index, int subindex) {
    for (var hk in _hotkeys) {
      if (hk.control == ctrl && hk.index == index && hk.subIndex == subindex)
        return hk;
    }
    return null;
  }

  _rebuildDictionary() {
    _hotkeysDictionary.clear();
    for (var hk in _hotkeys) {
      _hotkeysDictionary[hk.hotkeyCode] = hk;
    }
  }

  @protected
  void Function(MidiController, ControllerStatus)? onStatus;

  @protected
  void Function(MidiController, List<int>)? onDataReceived;

  setOnStatus(Function(MidiController, ControllerStatus) event) {
    onStatus = event;
  }

  setOnDataReceived(Function(MidiController, List<int>) event) {
    onDataReceived = event;
  }

  bool get connected;

  @override
  bool operator ==(other) {
    return (other is MidiController) && other.name == name;
  }

  @override
  int get hashCode => super.hashCode;

  Future<bool> connect();

  Map<String, dynamic> toJson() {
    var data = Map<String, dynamic>();
    data["name"] = name;
    data["id"] = id;

    List<Map<String, dynamic>> hk = [];

    for (int i = 0; i < _hotkeys.length; i++) hk.add(_hotkeys[i].toJson());
    data["hotkeys"] = hk;
    return data;
  }

  fromJson(dynamic json) {
    if (json["hotkeys"] != null) {
      _hotkeys.clear();
      for (var hk in json["hotkeys"])
        _hotkeys.add(ControllerHotkey.fromJson(hk));
      _rebuildDictionary();
    }
  }
}
