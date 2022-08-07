import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/hotkeyInput.dart';
import 'package:mighty_plug_manager/UI/popups/midiControlInfo.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/Preset.dart';
import 'package:mighty_plug_manager/midi/ControllerConstants.dart';
import 'package:mighty_plug_manager/midi/MidiControllerManager.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

class HotkeysSetup extends StatefulWidget {
  final MidiController controller;
  final HotkeyCategory category;
  const HotkeysSetup(
      {Key? key, required this.controller, required this.category})
      : super(key: key);

  @override
  _HotkeysSetupState createState() => _HotkeysSetupState();
}

class _HotkeysSetupState extends State<HotkeysSetup> {
  Widget buildWidget(String name, IconData? icon, Color? color,
      HotkeyControl ctrl, int ctrlIndex, int ctrlSubIndex, bool sliderMode,
      {Function()? infoButton}) {
    //sliders are not enabled in hid mode
    bool enabled =
        !(sliderMode && widget.controller.type == ControllerType.Hid);
    Widget trailing;
    var hk =
        widget.controller.getHotkeyByFunction(ctrl, ctrlIndex, ctrlSubIndex);
    String key = hk == null ? "None" : hk.hotkeyName;
    if (infoButton == null)
      trailing = Text(key);
    else
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enabled)
            IconButton(onPressed: infoButton, icon: Icon(Icons.info_outline)),
          Text(key)
        ],
      );

    return ListTile(
        enabled: enabled,
        leading: Icon(
          icon,
          color: color,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => HotkeyInputDialog().buildDialog(
                context,
                hotkeyName: name,
                midiController: widget.controller,
                ctrl: ctrl,
                ctrlIndex: ctrlIndex,
                ctrlSubIndex: ctrlSubIndex,
                sliderMode: sliderMode),
          ).then((value) {
            MidiControllerManager().cancelOnDataOverride();
            setState(() {});
          });
        },
        title: Text(name),
        subtitle: enabled ? null : Text("Not supported in HID mode"),
        trailing: trailing);
  }

  List<Widget> _buildChannelWidgets() {
    List<Widget> widgets = [];
    widgets.add(buildWidget("Previous Channel", Icons.keyboard_arrow_left, null,
        HotkeyControl.PreviousChannel, 0, 0, false));
    widgets.add(buildWidget("Next Channel", Icons.keyboard_arrow_right, null,
        HotkeyControl.NextChannel, 0, 0, false));

    for (int i = 0; i < NuxDeviceControl.instance().device.channelsCount; i++) {
      widgets.add(buildWidget("Channel ${i + 1}", Icons.circle,
          Preset.channelColors[i], HotkeyControl.ChannelByIndex, i, 0, false));
    }
    return widgets;
  }

  List<Widget> _buildEffectsWidgets() {
    List<Widget> widgets = [];
    var dev = NuxDeviceControl.instance().device;
    for (int i = 0; i < dev.processorList.length; i++) {
      var switchable = dev.getPreset(dev.selectedChannel).slotSwitchable(i);
      if (switchable) {
        var name = dev.processorList[i].longName;
        var icon = dev.processorList[i].icon;
        var color = dev.processorList[i].color;
        widgets.add(buildWidget("Switch $name on", icon, color,
            HotkeyControl.EffectSlotEnable, i, 0, false));
        widgets.add(buildWidget("Switch $name off", icon, color,
            HotkeyControl.EffectSlotDisable, i, 0, false));
        widgets.add(buildWidget("Toggle $name", icon, color,
            HotkeyControl.EffectSlotToggle, i, 0, false));
      }
    }

    return widgets;
  }

  List<Widget> _buildParametersWidgets() {
    List<Widget> widgets = [];
    var dev = NuxDeviceControl.instance().device;

    //enumerate all the slots in the signal chain
    for (int i = 0; i < dev.processorList.length; i++) {
      var effects = dev.getPreset(dev.selectedChannel).getEffectsForSlot(i);
      int maxParams = 0;
      for (int p = 0; p < effects.length; p++) {
        if (effects[p].parameters.length > maxParams)
          maxParams = effects[p].parameters.length;
      }

      //enumerate each slot for available params
      for (int p = 0; p < maxParams; p++) {
        var name = dev.processorList[i].longName;
        var icon = dev.processorList[i].icon;
        var color = dev.processorList[i].color;
        bool showInfo = false;
        String title;

        //check if parameters repeat
        List<String> params = [];
        for (int pp = 0; pp < effects.length; pp++) {
          if (effects[pp].parameters.length > p) {
            var name = effects[pp].parameters[p].name;
            if (!params.contains(name)) params.add(name);
          }
        }

        if (effects.length == 1 || params.length == 1)
          title = "$name ${effects[0].parameters[p].name}";
        else {
          title = "$name parameter ${p + 1}";
          showInfo = true;
        }

        widgets.add(buildWidget(
            title, icon, color, HotkeyControl.ParameterSet, i, p, true,
            infoButton:
                !showInfo ? null : () => _displayParameterInfo(effects, p)));
      }
    }

    return widgets;
  }

  _displayParameterInfo(List<Processor> effects, int paramIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) => MidiControlInfoDialog()
          .buildDialog(context, effects: effects, paramIndex: paramIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    String title = "";

    switch (widget.category) {
      case HotkeyCategory.Channels:
        widgetList = _buildChannelWidgets();
        title = "Channel Hotkeys";
        break;
      case HotkeyCategory.EffectSlots:
        widgetList = _buildEffectsWidgets();
        title = "Effect On/Off Hotkeys";
        break;
      case HotkeyCategory.EffectParameters:
        widgetList = _buildParametersWidgets();
        title = "Parameter Hotkeys";
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: widgetList,
      ),
    );
  }
}
