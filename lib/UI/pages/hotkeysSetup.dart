import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/hotkeyInput.dart';
import 'package:mighty_plug_manager/UI/popups/midiControlInfo.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/MidiControllerHandles.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
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
  State createState() => _HotkeysSetupState();
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
    if (infoButton == null) {
      trailing = Text(key);
    } else {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: infoButton, icon: const Icon(Icons.info_outline)),
          Text(key)
        ],
      );
    }

    return ListTile(
        enabled: enabled,
        leading: Icon(
          icon,
          color: color,
        ),
        minLeadingWidth: 0,
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
        subtitle: enabled ? null : const Text("Not supported in HID mode"),
        trailing: trailing);
  }

  List<Widget> _buildChannelWidgets() {
    List<Widget> widgets = [];
    widgets.add(buildWidget("Previous Channel", Icons.keyboard_arrow_left, null,
        HotkeyControl.PreviousChannel, 0, 0, false));
    widgets.add(buildWidget("Next Channel", Icons.keyboard_arrow_right, null,
        HotkeyControl.NextChannel, 0, 0, false));

    var colors =
        NuxDeviceControl.instance().device.presets[0].channelColorsList;
    for (int i = 0; i < NuxDeviceControl.instance().device.channelsCount; i++) {
      widgets.add(buildWidget("Channel ${i + 1}", Icons.circle, colors[i],
          HotkeyControl.ChannelByIndex, i, 0, false));
    }

    widgets.add(buildWidget("Previous Preset", Icons.keyboard_double_arrow_up,
        null, HotkeyControl.PreviousPresetGlobal, 0, 0, false));
    widgets.add(buildWidget("Next Preset", Icons.keyboard_double_arrow_down,
        null, HotkeyControl.NextPresetGlobal, 0, 0, false));
    widgets.add(buildWidget(
        "Previous Preset in Category",
        Icons.keyboard_arrow_up,
        null,
        HotkeyControl.PreviousPresetCategory,
        0,
        0,
        false));
    widgets.add(buildWidget(
        "Next Preset in Category",
        Icons.keyboard_arrow_down,
        null,
        HotkeyControl.NextPresetCategory,
        0,
        0,
        false));
    return widgets;
  }

  List<Widget> _buildEffectsWidgets() {
    List<Widget> widgets = [];
    var dev = NuxDeviceControl.instance().device;
    for (int i = 0; i < dev.processorList.length; i++) {
      var fxid = dev.processorList[i].nuxFXID;
      var slot = dev.getPreset(dev.selectedChannel).getSlotFromFXID(fxid)!;
      //var count =
      //    dev.getPreset(dev.selectedChannel).getEffectsForSlot(prc).length;
      //var index = fxid.toInt();

      var name = dev.processorList[i].longName;
      var icon = dev.processorList[i].icon;
      var color = dev.processorList[i].color;

      var switchable = dev.getPreset(dev.selectedChannel).slotSwitchable(slot);
      var effects = dev.getPreset(dev.selectedChannel).getEffectsForSlot(slot);
      var fx = effects[0];
      if (switchable) {
        widgets.add(buildWidget(
            "Switch $name on",
            icon,
            color,
            HotkeyControl.EffectSlotEnable,
            fx.midiControlOn!.id.index,
            0,
            false));
        widgets.add(buildWidget(
            "Switch $name off",
            icon,
            color,
            HotkeyControl.EffectSlotDisable,
            fx.midiControlOff!.id.index,
            0,
            false));
        widgets.add(buildWidget(
            "Toggle $name",
            icon,
            color,
            HotkeyControl.EffectSlotToggle,
            fx.midiControlToggle!.id.index,
            0,
            false));
      }
      if (effects.length > 1) {
        widgets.add(buildWidget(
            "Previous $name",
            icon,
            color,
            HotkeyControl.EffectDecrement,
            fx.midiControlPrev!.id.index,
            0,
            false));
        widgets.add(buildWidget(
            "Next $name",
            icon,
            color,
            HotkeyControl.EffectIncrement,
            fx.midiControlNext!.id.index,
            0,
            false));
      }
    }

    return widgets;
  }

  List<Widget> _buildParametersWidgets() {
    List<Widget> widgets = [];
    var dev = NuxDeviceControl.instance().device;

    //add master volume
    widgets.add(buildWidget("Volume", Icons.volume_up, Colors.white,
        HotkeyControl.MasterVolumeSet, 0, 0, true,
        infoButton: null));

    List<MidiControllerHandle> effectHandles = [];
    //enumerate all the slots in the signal chain
    for (int i = 0; i < dev.processorList.length; i++) {
      effectHandles.clear();
      var fxid = dev.processorList[i].nuxFXID;
      var prc = dev.getPreset(dev.selectedChannel).getSlotFromFXID(fxid)!;
      var effects = dev.getPreset(dev.selectedChannel).getEffectsForSlot(prc);
      for (int p = 0; p < effects.length; p++) {
        for (var param in effects[p].parameters) {
          if (param.midiControllerHandle != null &&
              !effectHandles.contains(param.midiControllerHandle)) {
            effectHandles.add(param.midiControllerHandle!);
          }
        }
      }

      var name = dev.processorList[i].longName;
      var icon = dev.processorList[i].icon;
      var color = dev.processorList[i].color;
      for (var handle in effectHandles) {
        var title = "$name ${handle.label}";

        widgets.add(buildWidget(title, icon, color, HotkeyControl.ParameterSet,
            handle.id.index, 0, true,
            infoButton: () => _displayParameterInfo(effects, handle.id)));

        if (handle.id == ControllerHandleId.delayTime) {
          widgets.add(buildWidget("$name Tap Tempo", icon, color,
              HotkeyControl.DelayTapTempo, handle.id.index, 0, false,
              infoButton: null));
        }
      }
    }

    return widgets;
  }

  List<Widget> _buildWidgetsRange(HotkeyControl from, HotkeyControl to) {
    List<Widget> widgets = [];
    for (int i = from.index; i <= to.index; i++) {
      HotkeyControl cat = HotkeyControl.values[i];
      widgets.add(
          buildWidget(cat.label!, cat.icon, null, cat, 0, 0, cat.sliderMode));
    }

    return widgets;
  }

  _displayParameterInfo(List<Processor> effects, ControllerHandleId handleId) {
    showDialog(
      context: context,
      builder: (BuildContext context) => MidiControlInfoDialog()
          .buildDialog(context, effects: effects, handleId: handleId),
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
        title = "Effect Hotkeys";
        break;
      case HotkeyCategory.EffectParameters:
        widgetList = _buildParametersWidgets();
        title = "Parameter Hotkeys";
        break;
      case HotkeyCategory.Drums:
        title = "Drums Hotkeys";
        widgetList = _buildWidgetsRange(
            HotkeyControl.DrumsStartStop, HotkeyControl.DrumsNextStyle);
        break;
      case HotkeyCategory.Looper:
        title = "Looper Hotkeys";
        widgetList = _buildWidgetsRange(
            HotkeyControl.LooperRecord, HotkeyControl.LooperLevel);
        break;
      case HotkeyCategory.JamTracks:
        title = "JamTracks Hotkeys";
        widgetList = _buildWidgetsRange(
            HotkeyControl.JamTracksPlayPause, HotkeyControl.JamTracksABRepeat);
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
