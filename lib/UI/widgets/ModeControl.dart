import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
import 'package:tinycolor2/tinycolor2.dart';

class ModeControl extends StatelessWidget {
  final bool enabled;
  final double value;
  final ValueType type;
  final Color effectColor;
  final ValueChanged<double>? onChanged;
  const ModeControl(
      {Key? key,
      required this.type,
      required this.value,
      required this.enabled,
      required this.effectColor,
      required this.onChanged})
      : super(key: key);

  String getText() {
    switch (type) {
      case ValueType.vibeMode:
        return "Mode:";
      case ValueType.boostMode:
        return "Boost:";
      case ValueType.brightMode:
        return "Bright:";
      case ValueType.contourMode:
        return "Contour:";
      default:
        return "";
    }
  }

  List<String> getElementsCount() {
    switch (type) {
      case ValueType.vibeMode:
        return ["Vibe", "Chorus"];
      case ValueType.boostMode:
      case ValueType.brightMode:
        return ["Off", "On"];
      case ValueType.contourMode:
        return ["Vintage", "Off", "Modern"];
      default:
        return [];
    }
  }

  List<int> getElementValues() {
    switch (type) {
      case ValueType.contourMode:
        return [0, 64, 127];
      default:
        return [0, 127];
    }
  }

  Widget getButtonItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 50),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          //width = constraints.maxWidth - 1;
          var color = enabled
              ? effectColor
              : TinyColor(effectColor).desaturate(80).color;
          var height = constraints.maxHeight;

          var elements = getElementsCount();
          var active = List<bool>.filled(elements.length, false);
          var index = ((value / 127) * (elements.length - 1)).round();
          active[index] = true;
          return Container(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getText(),
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  ToggleButtons(
                    children: [
                      for (var i = 0; i < elements.length; i++)
                        getButtonItem(elements[i]),
                    ],
                    isSelected: active,
                    fillColor: TinyColor(color).darken(15).color,
                    borderColor: color,
                    selectedBorderColor: color,
                    color: color,
                    selectedColor: Colors.white,
                    onPressed: (int newIndex) {
                      var val = getElementValues()[newIndex];
                      onChanged?.call(val.toDouble());
                    },
                  )
                ],
              ),
            ),
          );
        }));
  }
}
