import 'package:flutter/material.dart';

import '../../bluetooth/NuxDeviceControl.dart';
import '../../platform/simpleSharedPrefs.dart';
import 'thickSlider.dart';

class VolumeDrawer extends StatelessWidget {
  final bool expanded;
  final Function(bool) onExpandChange;
  final Function() onChanged;
  const VolumeDrawer(
      {Key? key,
      required this.expanded,
      required this.onExpandChange,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onExpandChange(!expanded);
        onChanged();
      },
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < 0) {
          //open
          onExpandChange(true);
          onChanged();
        } else {
          //close
          onExpandChange(false);
          onChanged();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            decoration: BoxDecoration(
                color:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
            child: Icon(
              expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              size: 20,
              color: Colors.grey,
            ),
          ),
          AnimatedContainer(
            padding: EdgeInsets.all(8),
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            duration: Duration(milliseconds: 100),
            height: expanded ? 60 : 0,
            child: ThickSlider(
              activeColor: Colors.blue,
              value: NuxDeviceControl().masterVolume,
              skipEmitting: 3,
              label: "Volume",
              labelFormatter: (value) {
                return value.round().toString();
              },
              min: 0,
              max: 100,
              handleVerticalDrag: false,
              onChanged: (value) {
                NuxDeviceControl().masterVolume = value;
                onChanged();
              },
              onDragEnd: (value) {
                SharedPrefs().setValue(
                    SettingsKeys.masterVolume, NuxDeviceControl().masterVolume);
              },
            ),
          ),
        ],
      ),
    );
  }
}
