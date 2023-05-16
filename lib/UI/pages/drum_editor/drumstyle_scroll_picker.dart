import 'package:flutter/material.dart';

import '../../../bluetooth/devices/NuxDevice.dart';
import 'DrumStyleBottomSheet.dart';
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
    return Semantics(
      label: "Drum style",
      child: ListTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: const BorderSide(width: 1, color: Colors.white)),
        title: Text(
          layout == DrumEditorLayout.PlugPro
              ? _getComplexListStyle(drumStyles)
              : drumStyles[selectedDrumPattern],
          style: _fontStyle,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return DrumStyleBottomSheet(
                  styleMap: drumStyles,
                  mode: layout == DrumEditorLayout.PlugPro
                      ? DrumStyleMode.categorized
                      : DrumStyleMode.flat,
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
}
