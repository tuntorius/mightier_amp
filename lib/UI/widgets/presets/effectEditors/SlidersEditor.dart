import 'package:flutter/material.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:undo/undo.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../bluetooth/NuxDeviceControl.dart';
import '../../../../bluetooth/devices/NuxConstants.dart';
import '../../../../bluetooth/devices/effects/Processor.dart';
import '../../../../bluetooth/devices/presets/Preset.dart';
import '../../../../utilities/DelayTapTimer.dart';
import '../../../../bluetooth/devices/value_formatters/TempoFormatter.dart';
import '../../../../bluetooth/devices/value_formatters/ValueFormatter.dart';
import '../../../popups/alertDialogs.dart';
import '../../../utils.dart';
import '../../ModeControl.dart';
import '../../thickSlider.dart';

class SlidersEditor extends StatefulWidget {
  final Preset preset;
  final int slot;
  const SlidersEditor({Key? key, required this.preset, required this.slot})
      : super(key: key);

  @override
  State<SlidersEditor> createState() => _SlidersEditorState();
}

class _SlidersEditorState extends State<SlidersEditor> {
  double _oldValue = 0;

  ThickSlider _createSlider(Parameter param, bool handleVerticalDrag) {
    bool enabled = widget.preset.slotEnabled(widget.slot);
    return ThickSlider(
      value: param.value,
      parameter: param,
      min: param.formatter.min.toDouble(),
      max: param.formatter.max.toDouble(),
      label: param.name,
      labelFormatter: (val) => param.label,
      activeColor: enabled
          ? widget.preset.effectColor(widget.slot)
          : TinyColor.fromColor(widget.preset.effectColor(widget.slot))
              .desaturate(80)
              .color,
      onChanged: (value, bool skip) {
        setState(() {
          widget.preset.setParameterValue(param, value, notify: !skip);
        });
      },
      onDragStart: (val) {
        _oldValue = val;
      },
      onDragEnd: (val) {
        //undo/redo here
        NuxDeviceControl.instance().changes.add(Change<double>(
            _oldValue,
            () => widget.preset.setParameterValue(param, val),
            (oldVal) => widget.preset.setParameterValue(param, oldVal)));
        NuxDeviceControl.instance().undoStackChanged();
      },
      handleVerticalDrag: handleVerticalDrag,
    );
  }

  ModeControl _createModeControl(Parameter param) {
    bool enabled = widget.preset.slotEnabled(widget.slot);
    return ModeControl(
      value: param.value,
      parameter: param,
      onChanged: (val) {
        NuxDeviceControl.instance().changes.add(Change<double>(
            _oldValue,
            () => widget.preset.setParameterValue(param, val),
            (oldVal) => widget.preset.setParameterValue(param, oldVal)));
        NuxDeviceControl.instance().undoStackChanged();
      },
      effectColor: widget.preset.effectColor(widget.slot),
      enabled: enabled,
    );
  }

  Widget _createTapTempo(Parameter param) {
    bool enabled = widget.preset.slotEnabled(widget.slot);
    return RawMaterialButton(
      onPressed: () {
        DelayTapTimer.addClickTime();
        var result = DelayTapTimer.calculate();
        if (result != false) {
          setState(() {
            var newValue = (param.formatter as TempoFormatter)
                .timeToPercentage(result / 1000);
            widget.preset.setParameterValue(param, newValue);

            NuxDeviceControl.instance().changes.add(Change<double>(
                param.value,
                () => widget.preset.setParameterValue(param, newValue),
                (oldVal) => widget.preset.setParameterValue(param, oldVal)));
            NuxDeviceControl.instance().undoStackChanged();
          });
        }
      },
      elevation: 2.0,
      fillColor: enabled
          ? TinyColor.fromColor(widget.preset.effectColor(widget.slot))
              .darken(15)
              .color
          : TinyColor.fromColor(widget.preset.effectColor(widget.slot))
              .desaturate(80)
              .darken(15)
              .color,
      padding: const EdgeInsets.all(15.0),
      shape: const CircleBorder(),
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          "Tap",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Widget _createCabinetRename(Cabinet cab) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  var dev = NuxDeviceControl.instance().device;
                  AlertDialogs.showInputDialog(context,
                      title: "Set cabinet name",
                      description: "",
                      value: cab.name, onConfirm: (value) {
                    dev.renameCabinet(cab.nuxIndex, value);
                  });
                },
                icon: const Icon(Icons.drive_file_rename_outline),
                label: const Text("Rename Cabinet")),
            ElevatedButton.icon(
                onPressed: () {
                  var dev = NuxDeviceControl.instance().device;
                  dev.renameCabinet(cab.nuxIndex, cab.cabName);
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text("Reset Name"))
          ],
        ),
        InkWell(
          onTap: () async {
            var url = AppConstants.patcherUrl;
            await canLaunchUrlString(url)
                ? await launchUrlString(url)
                : throw 'Could not launch $url';
          },
          child: SizedBox(
            height: 50,
            child: Center(
              child: RichText(
                  text: const TextSpan(
                style: TextStyle(fontSize: 18, color: Colors.white),
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
    var preset = widget.preset;
    var slot = widget.slot;
    var dev = NuxDeviceControl.instance().device;
    var sliders = <Widget>[];

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var layout = getEditorLayoutMode(MediaQuery.of(context));

    var handleVerticalDrag = isPortrait && layout != EditorLayoutMode.scroll;
    //get all the parameters for the slot
    List<Processor> prc = preset.getEffectsForSlot(slot);

    //create the widgets to edit them
    var selected = preset.getSelectedEffectForSlot(slot);
    List<Parameter> params = prc[selected].parameters;

    if (params.isNotEmpty) {
      for (int i = 0; i < params.length; i++) {
        Widget widget;
        switch (params[i].formatter.inputType) {
          case InputType.SliderInput:
            widget = Flexible(
                fit: FlexFit.loose,
                child: _createSlider(params[i], handleVerticalDrag));
            break;
          case InputType.SwitchInput:
            widget = _createModeControl(params[i]);
            break;
        }
        sliders.add(widget);

        //add tap tempo button
        if (params[i].formatter is TempoFormatter) {
          sliders.add(_createTapTempo(params[i]));
        }

        //add cabinet rename if supported
        if (dev.cabinetSupport &&
            dev.cabinetSlotIndex == slot &&
            dev.hackableIRs) {
          sliders.add(_createCabinetRename(prc[selected] as Cabinet));
        }
      }
      sliders.add(const SizedBox(
        height: 20,
      ));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: sliders);
  }
}
