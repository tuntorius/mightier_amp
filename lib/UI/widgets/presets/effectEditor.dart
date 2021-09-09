// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/settings.dart';
import 'package:mighty_plug_manager/UI/widgets/ModeControl.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
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

  @override
  Widget build(BuildContext context) {
    var _preset = widget.preset;
    var _slot = widget.slot;
    var sliders = <Widget>[];

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    bool enabled = _preset.slotEnabled(_slot);

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
              fit: FlexFit.loose,
              child: ThickSlider(
                value: params[i].value,
                min: params[i].valueType == ValueType.db ? -6 : 0,
                max: params[i].valueType == ValueType.db ? 6 : 100,
                label: params[i].name,
                labelFormatter: (val) {
                  switch (params[i].valueType) {
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
                    ? _preset.effectColor(_slot)
                    : TinyColor(_preset.effectColor(_slot))
                        .desaturate(80)
                        .color,
                onChanged: (val) {
                  setState(() {
                    _preset.setParameterValue(params[i], val);
                  });
                },
                onDragStart: (val) {
                  _oldValue = val;
                },
                onDragEnd: (val) {
                  //undo/redo here
                  NuxDeviceControl().changes.add(Change<double>(
                      _oldValue,
                      () => _preset.setParameterValue(params[i], val),
                      (oldVal) =>
                          _preset.setParameterValue(params[i], oldVal)));
                  NuxDeviceControl().undoStackChanged();
                },
                handleVerticalDrag: isPortrait,
              ));
        else {
          widget = ModeControl(
            value: params[i].value,
            onChanged: (val) {
              NuxDeviceControl().changes.add(Change<double>(
                  _oldValue,
                  () => _preset.setParameterValue(params[i], val),
                  (oldVal) => _preset.setParameterValue(params[i], oldVal)));
              NuxDeviceControl().undoStackChanged();
            },
            type: params[i].valueType,
            effectColor: _preset.effectColor(_slot),
            enabled: enabled,
          );
        }
        sliders.add(widget);

        if (params[i].valueType == ValueType.tempo) {
          sliders.add(RawMaterialButton(
            onPressed: () {
              timer.addClickTime();
              var result = timer.calculate();
              if (result != false) {
                setState(() {
                  var newValue = Parameter.timeToPercentage(result / 1000);
                  _preset.setParameterValue(params[i], newValue);

                  NuxDeviceControl().changes.add(Change<double>(
                      params[i].value,
                      () => _preset.setParameterValue(params[i], newValue),
                      (oldVal) =>
                          _preset.setParameterValue(params[i], oldVal)));
                  NuxDeviceControl().undoStackChanged();
                });
              }
            },
            elevation: 2.0,
            fillColor: enabled
                ? TinyColor(_preset.effectColor(_slot)).darken(15).color
                : TinyColor(_preset.effectColor(_slot))
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
          ));
        }
      }
      sliders.add(const SizedBox(
        height: 20,
      ));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: sliders);
  }
}
