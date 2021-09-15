// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxConstants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mighty_plug_manager/UI/pages/settings.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/UI/widgets/ModeControl.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/plug_air/Cabinet.dart';
import 'package:undo/undo.dart';
import '../../../bluetooth/devices/utilities/DelayTapTimer.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:tinycolor/tinycolor.dart';
import '../../../bluetooth/devices/effects/Processor.dart';
import '../../../bluetooth/devices/presets/Preset.dart';
import '../thickSlider.dart';

class EffectEditor extends StatefulWidget {
  final Preset preset;
  final int slot;
  EffectEditor({required this.preset, required this.slot});
  @override
  _EffectEditorState createState() => _EffectEditorState();
}

class _EffectEditorState extends State<EffectEditor> {
  DelayTapTimer timer = DelayTapTimer();
  double _oldValue = 0;
  String percentFormatter(val) {
    return "${val.round()} %";
  }

  String dbFormatter(double val) {
    return "${val.toStringAsFixed(1)} db";
  }

  ThickSlider createSlider(Parameter param, bool isPortrait) {
    bool enabled = widget.preset.slotEnabled(widget.slot);
    return ThickSlider(
      value: param.value,
      min: param.valueType == ValueType.db ? -6 : 0,
      max: param.valueType == ValueType.db ? 6 : 100,
      label: param.name,
      labelFormatter: (val) {
        switch (param.valueType) {
          case ValueType.percentage:
            return percentFormatter(val);
          case ValueType.db:
            return dbFormatter(val);
          case ValueType.tempo:
            var unit = SharedPrefs()
                .getValue(SettingsKeys.timeUnit, TimeUnit.BPM.index);
            if (unit == TimeUnit.BPM.index)
              return "${Parameter.percentageToBPM(val).toStringAsFixed(2)} BPM";
            return "${Parameter.percentageToTime(val).toStringAsFixed(2)} s";
          case ValueType.vibeMode:
            if (val == 0)
              return "Vibe";
            else if (val.round() == 100) return "Chorus";
            return "";
          default:
            return "";
        }
      },
      activeColor: enabled
          ? widget.preset.effectColor(widget.slot)
          : TinyColor(widget.preset.effectColor(widget.slot))
              .desaturate(80)
              .color,
      onChanged: (val) {
        setState(() {
          widget.preset.setParameterValue(param, val);
        });
      },
      onDragStart: (val) {
        _oldValue = val;
      },
      onDragEnd: (val) {
        //undo/redo here
        NuxDeviceControl().changes.add(Change<double>(
            _oldValue,
            () => widget.preset.setParameterValue(param, val),
            (oldVal) => widget.preset.setParameterValue(param, oldVal)));
        NuxDeviceControl().undoStackChanged();
      },
      handleVerticalDrag: isPortrait,
    );
  }

  ModeControl createModeControl(Parameter param) {
    bool enabled = widget.preset.slotEnabled(widget.slot);
    return ModeControl(
      value: param.value,
      onChanged: (val) {
        NuxDeviceControl().changes.add(Change<double>(
            _oldValue,
            () => widget.preset.setParameterValue(param, val),
            (oldVal) => widget.preset.setParameterValue(param, oldVal)));
        NuxDeviceControl().undoStackChanged();
      },
      type: param.valueType,
      effectColor: widget.preset.effectColor(widget.slot),
      enabled: enabled,
    );
  }

  Widget createTapTempo(Parameter param) {
    bool enabled = widget.preset.slotEnabled(widget.slot);
    return RawMaterialButton(
      onPressed: () {
        timer.addClickTime();
        var result = timer.calculate();
        if (result != false) {
          setState(() {
            var newValue = Parameter.timeToPercentage(result / 1000);
            widget.preset.setParameterValue(param, newValue);

            NuxDeviceControl().changes.add(Change<double>(
                param.value,
                () => widget.preset.setParameterValue(param, newValue),
                (oldVal) => widget.preset.setParameterValue(param, oldVal)));
            NuxDeviceControl().undoStackChanged();
          });
        }
      },
      elevation: 2.0,
      fillColor: enabled
          ? TinyColor(widget.preset.effectColor(widget.slot)).darken(15).color
          : TinyColor(widget.preset.effectColor(widget.slot))
              .desaturate(80)
              .darken(15)
              .color,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          "Tap",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      padding: EdgeInsets.all(15.0),
      shape: CircleBorder(),
    );
  }

  Widget createCabinetRename(Cabinet cab) {
    return Column(
      children: [
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  var _dev = NuxDeviceControl().device;
                  AlertDialogs.showInputDialog(context,
                      title: "Set cabinet name",
                      description: "",
                      value: cab.name, onConfirm: (value) {
                    _dev.renameCabinet(cab.nuxIndex, value);
                  });
                },
                child: Text("Rename Cabinet")),
            ElevatedButton(
                onPressed: () {
                  var _dev = NuxDeviceControl().device;
                  _dev.renameCabinet(cab.nuxIndex, cab.cabName);
                },
                child: Text("Reset Name"))
          ],
        ),
        InkWell(
          onTap: () async {
            var _url = AppConstants.patcherUrl;
            await canLaunch(_url)
                ? await launch(_url)
                : throw 'Could not launch $_url';
          },
          child: Container(
            height: 50,
            child: Center(
              child: RichText(
                  text: TextSpan(
                style: TextStyle(fontSize: 18),
                children: [
                  TextSpan(text: "Use "),
                  TextSpan(
                    text: "NUX IR Patcher",
                    style: TextStyle(
                        color: Colors.lightBlue,
                        decoration: TextDecoration.underline),
                  ),
                  TextSpan(text: " to import custom IRs")
                ],
              )),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var _preset = widget.preset;
    var _slot = widget.slot;
    var _dev = NuxDeviceControl().device;
    var sliders = <Widget>[];

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    //get all the parameters for the slot
    List<Processor> prc = _preset.getEffectsForSlot(_slot);

    //create the widgets to edit them
    var _selected = _preset.getSelectedEffectForSlot(_slot);
    List<Parameter> params = prc[_selected].parameters;

    if (params.length > 0) {
      for (int i = 0; i < params.length; i++) {
        var widget;
        if (params[i].valueType.index < ValueType.vibeMode.index)
          widget = Flexible(
              fit: FlexFit.loose, child: createSlider(params[i], isPortrait));
        else {
          widget = createModeControl(params[i]);
        }
        sliders.add(widget);

        if (params[i].valueType == ValueType.tempo) {
          sliders.add(createTapTempo(params[i]));
        }

        if (_dev.cabinetSupport && _dev.cabinetSlotIndex == _slot) {
          //add cabinet rename here
          sliders.add(createCabinetRename(prc[_selected] as Cabinet));
        }
      }
      sliders.add(const SizedBox(
        height: 20,
      ));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: sliders);
  }
}
