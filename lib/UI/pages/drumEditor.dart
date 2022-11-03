// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/DrumStyleBottomSheet.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/utilities/DelayTapTimer.dart';
import '../widgets/thickSlider.dart';
import '../widgets/scrollPicker.dart';
import 'dart:math' as math;

enum DrumEditorLayout { Standard, PlugPro }

class DrumEditor extends StatefulWidget {
  const DrumEditor({Key? key}) : super(key: key);
  @override
  State createState() => _DrumEditorState();
}

class _DrumEditorState extends State<DrumEditor> {
  final _drumStyles = NuxDeviceControl.instance().device.getDrumStyles();
  DrumEditorLayout _layout = DrumEditorLayout.Standard;
  int _selectedDrumPattern = 0;
  late NuxDevice device;
  final DelayTapTimer _timer = DelayTapTimer();

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

  String _getComplexListStyle(Map<String, Map> list) {
    for (String cat in list.keys) {
      for (String style in list[cat]!.keys) {
        if (list[cat]![style] == _selectedDrumPattern) return "$cat - $style";
      }
    }
    return "";
  }

  Widget _createScrollPicker() {
    final mediaQuery = MediaQuery.of(context);

    if (_layout == DrumEditorLayout.Standard) {
      return SizedBox(
        height: _getScrollPickerHeight(mediaQuery),
        child: ScrollPicker(
          enabled: device.drumsEnabled,
          initialValue: _selectedDrumPattern,
          items: _drumStyles,
          onChanged: _onScrollPickerChanged,
          onChangedFinal: (value, userGenerated) {
            _onScrollPickerChangedFinal(value, userGenerated, device);
          },
        ),
      );
    } else if (_layout == DrumEditorLayout.PlugPro) {
      return ListTile(
        title: Text(
          _getComplexListStyle(_drumStyles),
          style: const TextStyle(fontSize: 20),
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: !device.drumsEnabled
            ? null
            : () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return DrumStyleBottomSheet(
                        styleMap: _drumStyles,
                        selected: _selectedDrumPattern,
                        onChange: (value) {
                          _onScrollPickerChangedFinal(value, true, device);
                        },
                      );
                    }).whenComplete(() {
                  setState(() {});
                });
              },
      );
    }
    return const SizedBox();
  }

  Widget _activeSwitch() {
    return SwitchListTile(
      title: const Text(
        "Active",
        style: TextStyle(fontSize: 20),
      ),
      value: device.drumsEnabled,
      onChanged: (val) {
        setState(() {
          device.setDrumsEnabled(val);
        });
      },
    );
  }

  List<Widget> _sliders() {
    return [
      Flexible(
        child: ThickSlider(
          min: 0,
          max: 100,
          enabled: device.drumsEnabled,
          activeColor: Colors.blue,
          label: "Volume",
          value: device.drumsVolume.toDouble(),
          labelFormatter: (val) => "${device.drumsVolume.round()} %",
          onChanged: (val) {
            setState(() {
              device.setDrumsLevel(val);
            });
          },
        ),
      ),
      Flexible(
        child: ThickSlider(
          min: 40,
          max: 240,
          enabled: device.drumsEnabled,
          skipEmitting: 5,
          activeColor: Colors.blue,
          label: "Tempo",
          value: device.drumsTempo,
          labelFormatter: (val) =>
              "${device.drumsTempo.toStringAsFixed(1)} BPM",
          onChanged: (val) {
            setState(() {
              device.setDrumsTempo(val);
            });
          },
        ),
      ),
    ];
  }

  List<Widget> _toneSliders() {
    var dev = device as NuxMightyPlugPro;
    return [
      Flexible(
        child: ThickSlider(
          min: 0,
          max: 100,
          enabled: device.drumsEnabled,
          skipEmitting: 5,
          activeColor: Colors.blue,
          label: "Bass",
          value: dev.drumsBass,
          labelFormatter: (val) => "${dev.drumsBass.round()} %",
          onChanged: (val) {
            dev.setDrumsTone(val, DrumsToneControl.Bass);
            setState(() {});
          },
        ),
      ),
      Flexible(
        child: ThickSlider(
          min: 0,
          max: 100,
          enabled: device.drumsEnabled,
          skipEmitting: 5,
          activeColor: Colors.blue,
          label: "Middle",
          value: dev.drumsMiddle,
          labelFormatter: (val) => "${dev.drumsMiddle.round()} %",
          onChanged: (val) {
            dev.setDrumsTone(val, DrumsToneControl.Middle);
            setState(() {});
          },
        ),
      ),
      Flexible(
        child: ThickSlider(
          min: 0,
          max: 100,
          enabled: device.drumsEnabled,
          skipEmitting: 5,
          activeColor: Colors.blue,
          label: "Treble",
          value: dev.drumsTreble,
          labelFormatter: (val) => "${dev.drumsTreble.round()} %",
          onChanged: (val) {
            dev.setDrumsTone(val, DrumsToneControl.Treble);
            setState(() {});
          },
        ),
      )
    ];
  }

  Widget _tapButton() {
    return MaterialButton(
      onPressed: device.drumsEnabled ? _onTapTempo : null,
      color: Colors.blue,
      splashColor: Colors.lightBlue[100],
      height: 80,
      child: const Text(
        "Tap Tempo",
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bool portrait = mediaQuery.orientation == Orientation.portrait;

    _layout = _drumStyles is List<String>
        ? DrumEditorLayout.Standard
        : DrumEditorLayout.PlugPro;

    device = NuxDeviceControl.instance().device;

    _selectedDrumPattern = device.selectedDrumStyle;

    if (portrait) {
      return SafeArea(
        child: Column(
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
                    ..._sliders(),
                    if (_layout == DrumEditorLayout.PlugPro) ..._toneSliders(),
                    const SizedBox(height: 10),
                    _tapButton()
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      if (_layout == DrumEditorLayout.Standard) {
        return SafeArea(
            child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                flex: 4,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _activeSwitch(),
                      ..._sliders(),
                      const SizedBox(height: 10),
                      Expanded(child: _tapButton())
                    ])),
            const SizedBox(
              width: 12,
            ),
            Flexible(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(child: _createScrollPicker()),
                    Container(
                      height: 120,
                      color: Colors.orange,
                    )
                  ],
                ))
          ],
        ));
      } else {
        return SafeArea(
            child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                flex: 4,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _activeSwitch(),
                      Expanded(child: _createScrollPicker()),
                      ..._sliders(),
                      _tapButton(),
                    ])),
            const SizedBox(
              width: 12,
            ),
            Flexible(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._toneSliders(),
                    Container(
                      height: 120,
                      color: Colors.orange,
                    )
                  ],
                ))
          ],
        ));
      }
    }
  }

  double _getScrollPickerHeight(MediaQueryData mediaQuery) {
    Orientation orientation = mediaQuery.orientation;
    double numOfSelectItems = 3;
    if (orientation == Orientation.portrait) {
      if (mediaQuery.size.height < 640) {
        numOfSelectItems = 3.5;
      } else {
        numOfSelectItems = 3.5;
      }
    }
    return ScrollPicker.itemHeight * numOfSelectItems;
  }

  void _onScrollPickerChanged(value) {
    _selectedDrumPattern = value;
    setState(() {});
  }

  void _onScrollPickerChangedFinal(
      int value, bool userGenerated, NuxDevice? device) {
    if (userGenerated) {
      _selectedDrumPattern = value;
      //setState(() {
      device?.setDrumsStyle(value);
      device?.setDrumsTempo(device.drumsTempo);
      //});
    }
  }

  void _onTapTempo() {
    _timer.addClickTime();
    var result = _timer.calculate();
    if (result != false) {
      setState(() {
        var bpm = 60 / (result / 1000);
        bpm = math.min(math.max(bpm, 40), 240);
        device.setDrumsTempo(bpm);
      });
    }
  }

  void onDeviceChanged() {
    setState(() {});
  }
}
