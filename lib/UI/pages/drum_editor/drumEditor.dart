// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/drum_eq_bottom_sheet.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/drumstyle_scroll_picker.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/tap_buttons.dart';
import 'package:mighty_plug_manager/UI/widgets/circular_button.dart';
import 'package:mighty_plug_manager/UI/widgets/common/modeControlRegular.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/tempoTrainerSheet.dart';
import 'package:mighty_plug_manager/bluetooth/devices/features/drumsTone.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/features/looper.dart';
import '../../../modules/tempo_trainer.dart';
import '../../widgets/thickSlider.dart';
import 'looperPage.dart';

enum DrumEditorLayout { standard, extendedToneControls }

enum DrumEditorMode { regular, trainer, looper }

class DrumEditor extends StatefulWidget {
  static const fontStyle = TextStyle(fontSize: 18);

  const DrumEditor({Key? key}) : super(key: key);
  @override
  State createState() => _DrumEditorState();
}

class _DrumEditorState extends State<DrumEditor>
    with AutomaticKeepAliveClientMixin<DrumEditor> {
  late dynamic _drumStyles;
  DrumEditorLayout _layout = DrumEditorLayout.standard;
  DrumEditorMode _mode = DrumEditorMode.regular;
  int _selectedDrumPattern = 0;
  late NuxDevice device;

  @override
  void initState() {
    super.initState();
    _drumStyles = NuxDeviceControl.instance().device.getDrumStyles();
    NuxDeviceControl.instance().addListener(_onStateChanged);
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl.instance().removeListener(_onStateChanged);
  }

  Widget _createScrollPicker(
      bool smallControls, bool showPlay, bool playEnabled) {
    var picker = DrumStyleScrollPicker(
        smallControls: smallControls,
        selectedDrumPattern: _selectedDrumPattern,
        layout: _layout,
        device: device,
        drumStyles: _drumStyles,
        onChanged: _onScrollPickerChanged,
        onChangedFinal: _onScrollPickerChangedFinal,
        onComplete: () => setState(() {}));

    if (!showPlay) return picker;
    return Row(
      children: [
        Expanded(child: picker),
        IconButton(
            onPressed: !playEnabled || !NuxDeviceControl().isConnected
                ? null
                : () {
                    device.setDrumsEnabled(!device.drumsEnabled);
                    if (device.drumsEnabled == false) {
                      TempoTrainer.instance().enable = false;
                    }
                    NuxDeviceControl.instance().forceNotifyListeners();
                  },
            padding: const EdgeInsets.only(left: 12, right: 4),
            iconSize: smallControls ? 44 : 56,
            color: device.drumsEnabled ? Colors.orange : Colors.green,
            icon: Icon(device.drumsEnabled ? Icons.stop : Icons.play_arrow))
      ],
    );
  }

  Widget _landscapePlayControl(bool enabled) {
    return CircularButton(
        onPressed: TempoTrainer.instance().enable || !enabled
            ? null
            : () {
                device.setDrumsEnabled(!device.drumsEnabled);
                if (device.drumsEnabled == false) {
                  TempoTrainer.instance().enable = false;
                }
                NuxDeviceControl.instance().forceNotifyListeners();
              },
        backgroundColor: device.drumsEnabled ? Colors.orange : Colors.green,
        icon: device.drumsEnabled ? Icons.stop : Icons.play_arrow);
  }

  Widget _createModeControl(
      {required bool looper,
      required bool landscape,
      required bool smallControls}) {
    double height = smallControls ? 48 : 56;

    if (landscape && !looper) {
      return SizedBox(
        height: height,
        child: const Center(
            child: Text(
          "Trainer",
          style: TextStyle(fontSize: 20),
        )),
      );
    }

    if (landscape) {
      var controls = ["Trainer", "Looper"];
      var mode = _mode;
      if (mode == DrumEditorMode.regular) mode = DrumEditorMode.trainer;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height),
        child: ModeControlRegular(
            options: controls,
            textStyle: DrumEditor.fontStyle,
            selected: mode.index - 1,
            onSelected: (index) {
              _mode = DrumEditorMode.values[index + 1];
              setState(() {});
            }),
      );
    }
    var controls = ["Regular", "Trainer"];
    if (looper) controls.add("Looper");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 40),
        child: ModeControlRegular(
            options: controls,
            textStyle: DrumEditor.fontStyle,
            selected: _mode.index,
            onSelected: (index) {
              _mode = DrumEditorMode.values[index];
              setState(() {});
            }),
      ),
    );
  }

  Widget _drumLevelSlider(bool small) {
    return ThickSlider(
      min: 0,
      max: 100,
      maxHeight: small ? 40 : null,
      activeColor: Colors.blue,
      label: "Drums Level",
      value: device.drumsVolume.toDouble(),
      labelFormatter: (val) => "${device.drumsVolume.round()} %",
      onChanged: (value, skip) {
        setState(() {
          device.setDrumsLevel(value, !skip);
        });
      },
    );
  }

  bool _tempoControlsEnabled() {
    return !TempoTrainer.instance().enable &&
        (device is! Looper ||
            (device is Looper && (device as Looper).loopState == 0));
  }

  Widget _tempoSlider(bool small, bool landscape) {
    if (_mode != DrumEditorMode.trainer || landscape) {
      return ThickSlider(
        enabled: _tempoControlsEnabled(),
        min: device.drumsMinTempo,
        max: device.drumsMaxTempo,
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
      );
    }
    return const SizedBox.shrink();
  }

  List<Widget> _toneSliders(bool small) {
    if (device is! DrumsTone) return [];
    var dev = device as DrumsTone;
    return [
      ThickSlider(
        min: 0,
        max: 100,
        maxHeight: small ? 40 : null,
        skipEmitting: 5,
        activeColor: Colors.blue,
        label: "Bass",
        value: dev.drumsBass,
        labelFormatter: (val) => "${dev.drumsBass.round()} %",
        onChanged: (val, skip) {
          dev.setDrumsTone(val, DrumsToneControl.bass, !skip);
          setState(() {});
        },
      ),
      ThickSlider(
        min: 0,
        max: 100,
        maxHeight: small ? 40 : null,
        skipEmitting: 5,
        activeColor: Colors.blue,
        label: "Middle",
        value: dev.drumsMiddle,
        labelFormatter: (val) => "${dev.drumsMiddle.round()} %",
        onChanged: (val, skip) {
          dev.setDrumsTone(val, DrumsToneControl.middle, !skip);
          setState(() {});
        },
      ),
      ThickSlider(
        min: 0,
        max: 100,
        maxHeight: small ? 40 : null,
        skipEmitting: 5,
        activeColor: Colors.blue,
        label: "Treble",
        value: dev.drumsTreble,
        labelFormatter: (val) => "${dev.drumsTreble.round()} %",
        onChanged: (val, skip) {
          dev.setDrumsTone(val, DrumsToneControl.treble, !skip);
          setState(() {});
        },
      )
    ];
  }

  Widget _tapButton(bool smallControls) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TapButtons(
          smallControls: smallControls,
          device: device,
          onTempoModified: _modifyTempo,
          onTempoChanged: _onTempoChanged,
          enabled: _tempoControlsEnabled()),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediaQuery = MediaQuery.of(context);
    final bool portrait = mediaQuery.orientation == Orientation.portrait;
    final bool smallControls =
        portrait ? mediaQuery.size.height < 690 : mediaQuery.size.height < 400;

    device = NuxDeviceControl.instance().device;

    final bool hasLooper = device is Looper;
    final bool looperEnabled = hasLooper && (device as Looper).loopState != 0;
    _layout = _drumStyles is List<String>
        ? DrumEditorLayout.standard
        : DrumEditorLayout.extendedToneControls;

    _selectedDrumPattern = device.selectedDrumStyle;

    if (portrait) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        //padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Colors.grey[850],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                _createScrollPicker(smallControls, true, !looperEnabled),
                const SizedBox(height: 6),
                _drumLevelSlider(smallControls),
              ]),
            ),
          ),
          _createModeControl(
              looper: hasLooper,
              landscape: false,
              smallControls: smallControls),
          Card(
            color: Colors.grey[850],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _tempoSlider(smallControls, false),
                  if (_mode == DrumEditorMode.regular)
                    _tapButton(smallControls),
                  if (_mode == DrumEditorMode.regular && device is DrumsTone)
                    ..._toneSliders(smallControls),
                  if (_mode == DrumEditorMode.trainer)
                    TempoTrainerSheet(
                        smallControls: smallControls,
                        overtakeDrums: true,
                        enabled: !looperEnabled),
                  if (_mode == DrumEditorMode.looper)
                    LooperControl(
                      onStateChanged: _onStateChanged,
                      smallControls: smallControls,
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    var mode = _mode;
    if (mode == DrumEditorMode.regular) mode = DrumEditorMode.trainer;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            flex: 1,
            child: Card(
              color: Colors.grey[850],
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _createScrollPicker(smallControls, false, false),
                      const SizedBox(height: 6),
                      _drumLevelSlider(smallControls),
                      _tempoSlider(smallControls, true),
                      _tapButton(smallControls),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (device is DrumsTone)
                            CircularButton(
                                icon: Icons.equalizer,
                                backgroundColor: Colors.blue,
                                onPressed: () {
                                  showModalBottomSheet(
                                      showDragHandle: true,
                                      context: context,
                                      builder: (context) {
                                        return const DrumEQBottomSheet();
                                      });
                                }),
                          _landscapePlayControl(!looperEnabled)
                        ],
                      )),
                    ]),
              ),
            )),
        const SizedBox(
          width: 6,
        ),
        Expanded(
            flex: 1,
            child: Card(
              color: Colors.grey[850],
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: _createModeControl(
                            looper: hasLooper,
                            landscape: true,
                            smallControls: smallControls)),
                    const SizedBox(height: 6),
                    if (!hasLooper || mode == DrumEditorMode.trainer)
                      TempoTrainerSheet(
                        smallControls: smallControls,
                        overtakeDrums: false,
                        enabled: device.drumsEnabled ==
                                TempoTrainer.instance().enable &&
                            !looperEnabled,
                      ),
                    if (mode == DrumEditorMode.looper)
                      LooperControl(
                        onStateChanged: _onStateChanged,
                        smallControls: smallControls,
                      ),
                  ],
                ),
              ),
            ))
      ],
    );
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

  void _onStateChanged() {
    _drumStyles = NuxDeviceControl.instance().device.getDrumStyles();
    if (device.drumsEnabled == false &&
        TempoTrainer.instance().enable == true) {
      TempoTrainer.instance().enable = false;
    }
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
