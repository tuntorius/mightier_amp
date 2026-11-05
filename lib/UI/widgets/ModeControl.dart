// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

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

  Widget getButtonItem(BuildContext context, String text, bool isActive, Color buttonColor) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // When active, the text must contrast with the button's fill color.
    // When inactive, it contrasts with the transparent/background.
    Color textColor;
    if (isActive) {
      textColor = buttonColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    } else {
      textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 45),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          
          Color activeColor = effectColor;

          if (effectColor == Colors.grey || effectColor.value == 0xFF9E9E9E) {
            activeColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
          } else if (!isDark && TinyColor.fromColor(activeColor).isLight()) {
            activeColor = TinyColor.fromColor(activeColor).darken(25).color;
          }

          var color = enabled
              ? activeColor
              : TinyColor.fromColor(activeColor).desaturate(80).color;

          var elements = getElementsCount();
          var active = List<bool>.filled(elements.length, false);
          var index = getIndexByValue(value.round());
          active[index] = true;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            dense: true,
            title: Text(getText(),
                style: TextStyle(
                    color: enabled 
                        ? Theme.of(context).colorScheme.onSurface 
                        : Theme.of(context).hintColor, 
                    fontSize: 20)),
            trailing: ToggleButtons(
              isSelected: active,
              fillColor: color,
              borderColor: color,
              selectedBorderColor: color,
              color: color,
              onPressed: (int newIndex) {
                var val = getElementValues()[newIndex];
                onChanged?.call(val.toDouble());
              },
              children: [
                for (var i = 0; i < elements.length; i++)
                  getButtonItem(context, elements[i], active[i], color),
              ],
            ),
          );
        }));
  }
}