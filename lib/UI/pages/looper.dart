import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';

import '../../bluetooth/NuxDeviceControl.dart';
import '../widgets/common/ModeControlRegular.dart';

//fiber_smart_record looks fine for overdub
class LooperControl extends StatefulWidget {
  const LooperControl({super.key});

  @override
  State<LooperControl> createState() => _LooperControlState();
}

class _LooperControlState extends State<LooperControl> {
  static const fontSize = TextStyle(fontSize: 18);

  late int loopState;
  late int loopUndoState;

  @override
  void initState() {
    super.initState();
    NuxDeviceControl.instance().addListener(onDeviceUpdated);
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl.instance().removeListener(onDeviceUpdated);
  }

  void onDeviceUpdated() {
    setState(() {});
  }

  Widget circularButton(
      IconData icon, Color backgroundColor, Function()? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: backgroundColor, // <-- Button color
        foregroundColor: Colors.white, // <-- Splash color
      ),
      child: Icon(
        icon,
        size: 28,
      ),
    );
  }

  IconData getRecordButtonIcon() {
    switch (loopState) {
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
    if (loopUndoState == 2) return Icons.redo;
    return Icons.undo;
  }

  bool getStopEnabled() {
    switch (loopState) {
      case 2:
      case 3:
        return true;
      default:
        return false;
    }
  }

  bool getClearEnabled() {
    if (loopState > 0 && loopState < 5) return true;
    return false;
  }

  bool getUndoEnabled() {
    return loopUndoState > 0;
  }

  @override
  Widget build(BuildContext context) {
    var device = (NuxDeviceControl().device as NuxMightyPlugPro);
    loopState = device.loopState;
    loopUndoState = device.loopUndoState;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                circularButton(getRecordButtonIcon(), Colors.red, () {}),
                circularButton(
                    Icons.stop, Colors.green, getStopEnabled() ? () {} : null),
                circularButton(
                    Icons.clear, Colors.blue, getClearEnabled() ? () {} : null),
                circularButton(getUndoButtonIcon(), Colors.purple,
                    getUndoEnabled() ? () {} : null),
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
                selected: 0,
                onSelected: (index) {},
              ),
            ],
          )
        ]),
      ),
    );
  }
}
