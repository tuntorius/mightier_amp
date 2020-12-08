// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Delay.dart';
import 'package:tinycolor/tinycolor.dart';
import '../../../bluetooth/devices/effects/Processor.dart';
import '../../../bluetooth/devices/presets/Preset.dart';
import '../thickSlider.dart';

class EffectEditor extends StatefulWidget {
  final Preset preset;
  final int slot;
  EffectEditor({this.preset, this.slot});
  @override
  _EffectEditorState createState() => _EffectEditorState();
}

class _EffectEditorState extends State<EffectEditor> {
  DelayTapTimer timer = DelayTapTimer();

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
    var sliders = List<Widget>();

    bool enabled = _preset.slotEnabled(_slot);

    //store a reference to the tempo parameter if any
    Parameter tempoParameter;

    //get all the parameters for the slot
    List<Processor> prc = _preset.getEffectsForSlot(_slot);

    //create the widgets to edit them
    if (prc != null) {
      var _selected = _preset.getSelectedEffectForSlot(_slot);
      List<Parameter> params = prc[_selected].parameters;

      if (params != null && params.length > 0) {
        for (int i = 0; i < params.length; i++) {
          sliders.add(ThickSlider(
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
                  return "${Parameter.percentageToTime(val).toStringAsFixed(2)} s";
              }
              return "";
            },
            activeColor: enabled
                ? _preset.effectColor(_slot)
                : TinyColor(_preset.effectColor(_slot)).desaturate(80).color,
            onChanged: (val) {
              setState(() {
                _preset.setParameterValue(params[i], val);
              });
            },
          ));

          if (params[i].valueType == ValueType.tempo) {
            sliders.add(RawMaterialButton(
              onPressed: () {
                timer.addClickTime();
                var result = timer.calculate();
                if (result != false) {
                  setState(() {
                    _preset.setParameterValue(
                        params[i], Parameter.timeToPercentage(result / 1000));
                  });
                }
              },
              elevation: 2.0,
              fillColor: _preset.effectColor(_slot),
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
      }
    }
    return ListView(
      children: sliders,
    );
  }
}
