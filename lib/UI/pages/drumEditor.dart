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
      return Semantics(
        label: "Drum style",
        child: ListTile(
          enabled: device.drumsEnabled,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(
                  width: 1,
                  color: device.drumsEnabled ? Colors.white : Colors.grey)),
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
        ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: ElevatedButton(
              onPressed: device.drumsEnabled ? _onTapTempo : null,
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith(
                  (states) {
                    return states.contains(MaterialState.pressed)
                        ? Colors.lightBlue[100]
                        : null;
                  },
                ),
              ),
              child: const Text(
                "Tap Tempo",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),

          //TapOrHoldButton here
          //https://stackoverflow.com/questions/52128572/flutter-execute-method-so-long-the-button-pressed

          Expanded(
            flex: 4,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ElevatedButton(
                      onPressed:
                          device.drumsEnabled ? () => _modifyTempo(-5) : null,
                      child: const Text("-5"),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed:
                          device.drumsEnabled ? () => _modifyTempo(-1) : null,
                      child: const Text("-1"),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed:
                          device.drumsEnabled ? () => _modifyTempo(1) : null,
                      child: const Text("+1"),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ElevatedButton(
                      onPressed:
                          device.drumsEnabled ? () => _modifyTempo(5) : null,
                      child: const Text("+5"),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
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
                    ..._sliders(smallSliders),
                    if (_layout == DrumEditorLayout.PlugPro)
                      ..._toneSliders(smallSliders),
                    const SizedBox(height: 6),
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
            child: Column(
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
                          _tapButton()
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
                          // Container(
                          //   height: 120,
                          //   color: Colors.orange,
                          // )
                        ],
                      ))
                ],
              ),
            ),
          ],
        ));
      } else {
        return SafeArea(
            child: Column(
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
                          // Container(
                          //   height: 120,
                          //   color: Colors.orange,
                          // )
                        ],
                      ))
                ],
              ),
            ),
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
      device?.setDrumsStyle(value);

      //workaround for a bug in Mighty Plug
      device?.setDrumsTempo(device.drumsTempo + 1, true);
      device?.setDrumsTempo(device.drumsTempo - 1, true);
    }
  }

  void _modifyTempo(double amount) {
    setState(() {
      double newTempo = device.drumsTempo + amount;
      newTempo = math.max(
          math.min(newTempo, device.drumsMaxTempo), device.drumsMinTempo);
      device.setDrumsTempo(newTempo, true);
    });
  }

  void _onTapTempo() {
    _timer.addClickTime();
    var result = _timer.calculate();
    if (result != false) {
      setState(() {
        var bpm = 60 / (result / 1000);
        bpm =
            math.min(math.max(bpm, device.drumsMinTempo), device.drumsMaxTempo);
        device.setDrumsTempo(bpm, true);
      });
    }
  }

  void onDeviceChanged() {
    setState(() {});
  }
}
