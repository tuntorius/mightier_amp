import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/thickSlider.dart';

import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/features/looper.dart';
import '../../widgets/common/ModeControlRegular.dart';

class LooperControl extends StatefulWidget {
  final VoidCallback onStateChanged;
  final bool smallControls;
  const LooperControl(
      {super.key, required this.onStateChanged, required this.smallControls});

  @override
  State<LooperControl> createState() => _LooperControlState();
}

class _LooperControlState extends State<LooperControl> {
  static const fontSize = TextStyle(fontSize: 18);
  late Looper _looper;
  late LooperData _data = LooperData();
  Timer? _blinkTimer;
  StreamSubscription? _subscription;
  bool _blinkOn = true;

  @override
  void initState() {
    super.initState();
    _looper = NuxDeviceControl().device as Looper;
    _subscription = _looper.getLooperDataStream().listen(_onData);
    _looper.requestLooperSettings();

    _blinkTimer = Timer.periodic(const Duration(milliseconds: 400), _onBlink);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _onData(LooperData data) {
    _data = data;
    widget.onStateChanged();
    setState(() {});
  }

  void _onBlink(timer) {
    _blinkOn = !_blinkOn;
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

  Color _getRecordButtonColor() {
    if (!_blinkOn && _data.loopState > 0 && _data.loopState < 4) {
      return Colors.grey[700]!;
    }
    switch (_data.loopState) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
      case 4:
        return Colors.green;
      case 3:
        return Colors.amber[700]!;
      case 9:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  IconData getUndoButtonIcon() {
    if (_data.loopUndoState == 2) return Icons.redo;
    return Icons.undo;
  }

  Color _getUndoButtonColor() {
    if (_data.loopUndoState == 2) return Colors.purple[700]!;
    return Colors.blue;
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
    var looper = (NuxDeviceControl().device as Looper);
    var connected = NuxDeviceControl().isConnected;

    return Column(children: [
      const SizedBox(
        height: 8,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              circularButton(getRecordButtonIcon(), _getRecordButtonColor(),
                  connected ? looper.looperRecordPlay : null),
              circularButton(Icons.stop, Colors.amber,
                  getStopEnabled() ? looper.looperStop : null),
              circularButton(Icons.clear, Colors.amber,
                  getClearEnabled() ? looper.looperClear : null),
              circularButton(getUndoButtonIcon(), _getUndoButtonColor(),
                  getUndoEnabled() ? looper.looperUndoRedo : null),
            ]),
      ),
      const SizedBox(height: 8),
      ListTile(
        enabled: connected,
        title: const Text("Recording", style: fontSize),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 40),
          child: ModeControlRegular(
            options: const ["Normal", "Auto"],
            textStyle: fontSize,
            selected: looper.loopRecordMode,
            onSelected: connected
                ? (index) {
                    looper.looperNrAr(index == 1);
                    setState(() {});
                  }
                : null,
          ),
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      ThickSlider(
        enabled: connected,
        min: 0,
        max: 100,
        maxHeight: widget.smallControls ? 40 : null,
        activeColor: Colors.blue,
        label: "Looper Level",
        value: looper.loopLevel.toDouble(),
        labelFormatter: (val) => val.toInt().toString(),
        onChanged: (value, skip) {
          looper.looperLevel(value.toInt());
          setState(() {});
        },
        onDragEnd: (value) {
          looper.looperLevel(value.toInt());
          setState(() {});
        },
      )
    ]);
  }
}
