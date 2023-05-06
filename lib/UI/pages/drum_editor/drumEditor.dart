// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/drumstyle_scroll_picker.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/tap_buttons.dart';
import 'package:mighty_plug_manager/UI/widgets/tempoTrainerBottomSheet.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../widgets/thickSlider.dart';

enum DrumEditorLayout { Standard, PlugPro }

class DrumEditor extends StatefulWidget {
  static const fontStyle = TextStyle(fontSize: 20);

  const DrumEditor({Key? key}) : super(key: key);
  @override
  State createState() => _DrumEditorState();
}

class _DrumEditorState extends State<DrumEditor> {
  final _drumStyles = NuxDeviceControl.instance().device.getDrumStyles();
  DrumEditorLayout _layout = DrumEditorLayout.Standard;
  int _selectedDrumPattern = 0;
  late NuxDevice device;

  @override
  void initState() {
    super.initState();
    NuxDeviceControl.instance().addListener(onDeviceChanged);
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl.instance().removeListener(onDeviceChanged);
  }

  Widget _createScrollPicker() {
    return DrumStyleScrollPicker(
        selectedDrumPattern: _selectedDrumPattern,
        layout: _layout,
        device: device,
        drumStyles: _drumStyles,
        onChanged: _onScrollPickerChanged,
        onChangedFinal: _onScrollPickerChangedFinal,
        onComplete: () => setState(() {}));
  }

  Widget _activeSwitch() {
    return SwitchListTile(
      dense: true,
      title: const Text(
        "Active",
        style: DrumEditor.fontStyle,
      ),
      value: device.drumsEnabled,
      onChanged: (val) {
        setState(() {
          device.setDrumsEnabled(val);
        });
      },
    );
  }

  List<Widget> _sliders(bool small) {
    return [
      ThickSlider(
        min: 0,
        max: 100,
        maxHeight: small ? 40 : null,
        enabled: device.drumsEnabled,
        activeColor: Colors.blue,
        label: "Volume",
        value: device.drumsVolume.toDouble(),
        labelFormatter: (val) => "${device.drumsVolume.round()} %",
        onChanged: (value, skip) {
          setState(() {
            device.setDrumsLevel(value, !skip);
          });
        },
      ),
      ThickSlider(
        min: device.drumsMinTempo,
        max: device.drumsMaxTempo,
        enabled: device.drumsEnabled,
        maxHeight: small ? 40 : null,
        skipEmitting: 5,
        activeColor: Colors.blue,
        label: "Tempo",
        value: device.drumsTempo,
        labelFormatter: (val) => "${device.drumsTempo.toStringAsFixed(1)} BPM",
        onChanged: (val, skip) {
          setState(() {
            device.setDrumsTempo(val, !skip);
          });
        },
      ),
    ];
  }

  List<Widget> _toneSliders(bool small) {
    var dev = device as NuxMightyPlugPro;
    return [
      ThickSlider(
        min: 0,
        max: 100,
        maxHeight: small ? 40 : null,
        enabled: device.drumsEnabled,
        skipEmitting: 5,
        activeColor: Colors.blue,
        label: "Bass",
        value: dev.drumsBass,
        labelFormatter: (val) => "${dev.drumsBass.round()} %",
        onChanged: (val, skip) {
          dev.setDrumsTone(val, DrumsToneControl.Bass, !skip);
          setState(() {});
        },
      ),
      ThickSlider(
        min: 0,
        max: 100,
        maxHeight: small ? 40 : null,
        enabled: device.drumsEnabled,
        skipEmitting: 5,
        activeColor: Colors.blue,
        label: "Middle",
        value: dev.drumsMiddle,
        labelFormatter: (val) => "${dev.drumsMiddle.round()} %",
        onChanged: (val, skip) {
          dev.setDrumsTone(val, DrumsToneControl.Middle, !skip);
          setState(() {});
        },
      ),
      ThickSlider(
        min: 0,
        max: 100,
        maxHeight: small ? 40 : null,
        enabled: device.drumsEnabled,
        skipEmitting: 5,
        activeColor: Colors.blue,
        label: "Treble",
        value: dev.drumsTreble,
        labelFormatter: (val) => "${dev.drumsTreble.round()} %",
        onChanged: (val, skip) {
          dev.setDrumsTone(val, DrumsToneControl.Treble, !skip);
          setState(() {});
        },
      )
    ];
  }

  Widget _tapButton() {
    return TapButtons(
        device: device,
        onTempoModified: _modifyTempo,
        onTempoChanged: _onTempoChanged,
        showTempoTrainer: _showTempoTrainer);
  }

  void _showTempoTrainer() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return const TempoTrainerBottomSheet();
        });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bool portrait = mediaQuery.orientation == Orientation.portrait;
    final bool smallSliders = mediaQuery.size.height < 640;

    _layout = _drumStyles is List<String>
        ? DrumEditorLayout.Standard
        : DrumEditorLayout.PlugPro;

    device = NuxDeviceControl.instance().device;

    _selectedDrumPattern = device.selectedDrumStyle;

    if (portrait) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        //padding: const EdgeInsets.all(16.0),
        children: [
          _activeSwitch(),
          _createScrollPicker(),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._sliders(smallSliders),
                  if (_layout == DrumEditorLayout.PlugPro)
                    ..._toneSliders(smallSliders),
                  const SizedBox(height: 6),
                  _tapButton(),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      if (_layout == DrumEditorLayout.Standard) {
        return Column(
          children: [
            Card(child: _activeSwitch()),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    flex: 4,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ..._sliders(false),
                          const SizedBox(height: 10),
                          _tapButton(),
                        ]),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Flexible(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(child: _createScrollPicker()),
                        ],
                      ))
                ],
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Card(child: _activeSwitch()),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                      flex: 5,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ..._sliders(false),
                            const SizedBox(height: 10),
                            _tapButton(),
                          ])),
                  const SizedBox(
                    width: 12,
                  ),
                  Flexible(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _createScrollPicker(),
                          ..._toneSliders(false),
                        ],
                      ))
                ],
              ),
            ),
          ],
        );
      }
    }
  }

  void _onScrollPickerChanged(value) {
    _selectedDrumPattern = value;
    setState(() {});
  }

  void _onScrollPickerChangedFinal(
      int value, bool userGenerated, NuxDevice? device) {
    if (userGenerated) {
      _selectedDrumPattern = value;
      device?.setDrumsStyle(value);

      //workaround for a bug in Mighty Plug
      device?.setDrumsTempo(device.drumsTempo + 1, true);
      device?.setDrumsTempo(device.drumsTempo - 1, true);
    }
  }

  void _modifyTempo(double amount) {
    setState(() {
      double newTempo = device.drumsTempo + amount;
      device.setDrumsTempo(newTempo, true);
    });
  }

  void _onTempoChanged(double value) {
    setState(() {
      device.setDrumsTempo(value, true);
    });
  }

  void onDeviceChanged() {
    setState(() {});
  }
}
