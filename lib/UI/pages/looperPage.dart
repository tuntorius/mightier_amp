import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/thickSlider.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightySpace.dart';

import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/features/looper.dart';
import '../widgets/common/ModeControlRegular.dart';

class LooperControl extends StatefulWidget {
  const LooperControl({super.key});

  @override
  State<LooperControl> createState() => _LooperControlState();
}

class _LooperControlState extends State<LooperControl> {
  static const fontSize = TextStyle(fontSize: 18);
  late Looper _looper;
  late LooperData _data = LooperData();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _looper = NuxDeviceControl().device as Looper;
    _subscription = _looper.getLooperDataStream().listen(onData);
    _looper.requestLooperSettings();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void onData(LooperData data) {
    _data = data;
    setState(() {});
  }

  Widget circularButton(
      IconData icon, Color backgroundColor, Function()? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
      ),
      child: Icon(
        icon,
        size: 28,
      ),
    );
  }

  IconData getRecordButtonIcon() {
    switch (_data.loopState) {
      case 0:
      case 1:
        return Icons.fiber_manual_record;
      case 2:
      case 4:
        return Icons.play_arrow;
      case 3:
        return Icons.fiber_smart_record;
      case 9:
        return Icons.pause;
      default:
        return Icons.fiber_manual_record;
    }
  }

  IconData getUndoButtonIcon() {
    if (_data.loopUndoState == 2) return Icons.redo;
    return Icons.undo;
  }

  bool getStopEnabled() {
    switch (_data.loopState) {
      case 2:
      case 3:
        return true;
      default:
        return false;
    }
  }

  bool getClearEnabled() {
    if (_data.loopState > 0 && _data.loopState < 5) return true;
    return false;
  }

  bool getUndoEnabled() {
    return _data.loopUndoState > 0;
  }

  @override
  Widget build(BuildContext context) {
    var device = (NuxDeviceControl().device as NuxMightySpace);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                circularButton(
                    getRecordButtonIcon(), Colors.red, device.looperRecordPlay),
                circularButton(Icons.stop, Colors.green,
                    getStopEnabled() ? device.looperStop : null),
                circularButton(Icons.clear, Colors.blue,
                    getClearEnabled() ? device.looperClear : null),
                circularButton(getUndoButtonIcon(), Colors.purple,
                    getUndoEnabled() ? device.looperUndoRedo : null),
              ]),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recording", style: fontSize),
              ModeControlRegular(
                options: const ["Normal", "Auto"],
                textStyle: fontSize,
                selected: device.loopRecordMode,
                onSelected: (index) {
                  device.looperNrAr(index == 1);
                  setState(() {});
                },
              ),
            ],
          ),
          ThickSlider(
            min: 0,
            max: 100,
            activeColor: Colors.blue,
            label: "Level",
            value: device.loopLevel.toDouble(),
            labelFormatter: (val) => val.toInt().toString(),
            onChanged: (value, skip) {
              if (skip) {
                device.config.looperData.loopLevel = value;
              } else {
                device.looperLevel(value.toInt());
              }
              setState(() {});
            },
            onDragEnd: (value) {
              device.looperLevel(value.toInt());
              setState(() {});
            },
          )
        ]),
      ),
    );
  }
}
