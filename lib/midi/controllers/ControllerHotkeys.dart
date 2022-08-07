import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';

import '../ControllerConstants.dart';

class ControllerHotkey {
  //type of value it controls
  HotkeyControl control;

  //friendly name
  String hotkeyName;

  //code that activates it - either 16 bit midi message or HID code
  int hotkeyCode;

  //main parameter - i.e. channel or slot
  int index;

  //sub parameter - which slider for example
  int subIndex;

  ControllerHotkey(
      {required this.control,
      required this.index,
      required this.subIndex,
      required this.hotkeyCode,
      required this.hotkeyName});

  execute(int? value) {
    var device = NuxDeviceControl.instance().device;
    int channel = device.selectedChannel;
    switch (control) {
      case HotkeyControl.PreviousChannel:
        do {
          channel--;
          if (channel < 0) channel = device.channelsCount - 1;
        } while (!device.getChannelActive(channel));
        device.selectedChannelNormalized = channel;
        break;
      case HotkeyControl.NextChannel:
        do {
          channel++;
          if (channel >= device.channelsCount) channel = 0;
        } while (!device.getChannelActive(channel));
        device.selectedChannelNormalized = channel;
        break;
      case HotkeyControl.ChannelByIndex:
        device.selectedChannelNormalized = index;
        break;
      case HotkeyControl.EffectSlotEnable:
        var p = device.getPreset(device.selectedChannel);
        p.setSlotEnabled(index, true, true);
        NuxDeviceControl.instance().forceNotifyListeners();
        break;
      case HotkeyControl.EffectSlotDisable:
        var p = device.getPreset(device.selectedChannel);
        p.setSlotEnabled(index, false, true);
        NuxDeviceControl.instance().forceNotifyListeners();
        break;
      case HotkeyControl.EffectSlotToggle:
        var p = device.getPreset(device.selectedChannel);
        p.setSlotEnabled(index, !p.slotEnabled(index), true);
        NuxDeviceControl.instance().forceNotifyListeners();
        break;
      case HotkeyControl.ParameterSet:
        var p = device.getPreset(device.selectedChannel);
        var effect =
            p.getEffectsForSlot(index)[p.getSelectedEffectForSlot(index)];

        //warning: this might be more specific value - not to percentage
        //or the value might be pitch bend which is 14 bit
        p.setParameterValue(effect.parameters[subIndex],
            NuxDeviceControl.instance().sevenBitToPercentage(value ?? 0));
        NuxDeviceControl.instance().forceNotifyListeners();
        break;
    }
  }

  Map<String, dynamic> toJson() {
    var data = Map<String, dynamic>();
    data["name"] = hotkeyName;
    data["control"] = control.toString();
    data["code"] = hotkeyCode;
    data["index"] = index;
    data["subIndex"] = subIndex;

    return data;
  }

  factory ControllerHotkey.fromJson(dynamic json) {
    ControllerHotkey hk = ControllerHotkey(
        control: getHKFromString(json["control"]),
        hotkeyCode: json["code"],
        hotkeyName: json["name"],
        index: json["index"],
        subIndex: json["subIndex"]);
    return hk;
  }

  static HotkeyControl getHKFromString(String controlAsString) {
    for (var element in HotkeyControl.values) {
      if (element.toString() == controlAsString) {
        return element;
      }
    }
    throw Exception("Error: Unknown HotkeyControl type!");
  }
}
