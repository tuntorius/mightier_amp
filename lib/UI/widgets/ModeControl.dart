import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../bluetooth/devices/value_formatters/SwitchFormatters.dart';

class ModeControl extends StatelessWidget {
  final bool enabled;
  final double value;
  final Parameter parameter;
  final Color effectColor;
  final ValueChanged<double>? onChanged;
  const ModeControl(
      {Key? key,
      required this.parameter,
      required this.value,
      required this.enabled,
      required this.effectColor,
      required this.onChanged})
      : super(key: key);

  String getText() {
    return (parameter.formatter as SwitchFormatter).labelTitle;
  }

  List<String> getElementsCount() {
    return (parameter.formatter as SwitchFormatter).labelValues;
  }

  List<int> getElementValues() {
    return (parameter.formatter as SwitchFormatter).midiValues;
  }

  int getIndexByValue(int midiValue) {
    //find element that is closest to the value
    var list = (parameter.formatter as SwitchFormatter).midiValues;
    int closestValue = 255;
    int selected = -1;
    for (int i = 0; i < list.length; i++) {
      int diff = (list[i] - midiValue).abs();
      if (diff < closestValue) {
        closestValue = diff;
        selected = i;
      }
    }
    return selected;
  }

  Widget getButtonItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 45),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          //width = constraints.maxWidth - 1;
          var color = enabled
              ? effectColor
              : TinyColor.fromColor(effectColor).desaturate(80).color;

          var elements = getElementsCount();
          var active = List<bool>.filled(elements.length, false);
          var index = getIndexByValue(value.round());
          active[index] = true;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            dense: true,
            title: Text(getText(),
                style: const TextStyle(color: Colors.white, fontSize: 20)),
            trailing: ToggleButtons(
              isSelected: active,
              fillColor: TinyColor.fromColor(color).darken(15).color,
              borderColor: color,
              selectedBorderColor: color,
              color: color,
              selectedColor: Colors.white,
              onPressed: (int newIndex) {
                var val = getElementValues()[newIndex];
                onChanged?.call(val.toDouble());
              },
              children: [
                for (var i = 0; i < elements.length; i++)
                  getButtonItem(elements[i]),
              ],
            ),
          );
        }));
  }
}
