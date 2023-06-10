import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';

import '../../../bluetooth/devices/NuxMightyPlugPro.dart';
import '../../widgets/thickSlider.dart';

class DrumEQBottomSheet extends StatefulWidget {
  const DrumEQBottomSheet({super.key});

  @override
  State<DrumEQBottomSheet> createState() => _DrumEQBottomSheetState();
}

class _DrumEQBottomSheetState extends State<DrumEQBottomSheet> {
  @override
  Widget build(BuildContext context) {
    var dev = NuxDeviceControl.instance().device as NuxMightyPlugPro;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Drum Tone Controls",
        ),
        SizedBox(
          height: 16,
        ),
        ThickSlider(
          min: 0,
          max: 100,
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
          skipEmitting: 5,
          activeColor: Colors.blue,
          label: "Treble",
          value: dev.drumsTreble,
          labelFormatter: (val) => "${dev.drumsTreble.round()} %",
          onChanged: (val, skip) {
            dev.setDrumsTone(val, DrumsToneControl.Treble, !skip);
            setState(() {});
          },
        ),
        const SizedBox(
          height: 50,
        )
      ],
    );
  }
}
