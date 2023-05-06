import 'package:flutter/material.dart';

import '../../../bluetooth/devices/NuxDevice.dart';
import 'DrumStyleBottomSheet.dart';
import '../../widgets/scrollPicker.dart';
import 'drumEditor.dart';

class DrumStyleScrollPicker extends StatelessWidget {
  static const _fontStyle = TextStyle(fontSize: 20);

  final int selectedDrumPattern;
  final DrumEditorLayout layout;
  final NuxDevice device;
  final dynamic drumStyles;

  // Events
  final ValueChanged<int> onChanged;
  final Function(int, bool, NuxDevice) onChangedFinal;
  final Function() onComplete;

  const DrumStyleScrollPicker(
      {super.key,
      required this.selectedDrumPattern,
      required this.layout,
      required this.device,
      required this.drumStyles,
      required this.onChanged,
      required this.onChangedFinal,
      required this.onComplete});

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

  String _getComplexListStyle(Map<String, Map> list) {
    for (String cat in list.keys) {
      for (String style in list[cat]!.keys) {
        if (list[cat]![style] == selectedDrumPattern) return "$cat - $style";
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    if (layout == DrumEditorLayout.Standard) {
      return SizedBox(
        height: _getScrollPickerHeight(mediaQuery),
        child: ScrollPicker(
          enabled: device.drumsEnabled,
          initialValue: selectedDrumPattern,
          items: drumStyles,
          onChanged: onChanged,
          onChangedFinal: (value, userGenerated) {
            onChangedFinal(value, userGenerated, device);
          },
        ),
      );
    } else if (layout == DrumEditorLayout.PlugPro) {
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
            _getComplexListStyle(drumStyles),
            style: _fontStyle,
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: !device.drumsEnabled
              ? null
              : () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return DrumStyleBottomSheet(
                          styleMap: drumStyles,
                          selected: selectedDrumPattern,
                          onChange: (value) {
                            onChangedFinal(value, true, device);
                          },
                        );
                      }).whenComplete(() {
                    onComplete();
                  });
                },
        ),
      );
    }
    return const SizedBox();
  }
}
