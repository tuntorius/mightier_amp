// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:tinycolor2/tinycolor2.dart';
import '../../../bluetooth/devices/effects/Processor.dart';

class EffectChainButton extends StatelessWidget {
  final ProcessorInfo effectInfo;
  final bool enabled;
  final bool selected;
  final bool reorderable;
  final Color color;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final int index;

  const EffectChainButton({
    Key? key,
    required this.effectInfo,
    required this.enabled,
    required this.selected,
    required this.color,
    this.onTap,
    this.onDoubleTap,
    required this.index,
    required this.reorderable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color activeColor = color;
    
    // Explicit override for EQ to guarantee it is visible when ON
    if (effectInfo.shortName == "EQ" || color == Colors.grey || color.value == 0xFF9E9E9E) {
      activeColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    } 
    // In Light mode, aggressively darken bright colors like Yellow to separate them from the white background
    else if (!isDark && TinyColor.fromColor(activeColor).isLight()) {
      activeColor = TinyColor.fromColor(activeColor).darken(25).color;
    }

    Color inactiveColor = isDark ? Colors.grey[700]! : Colors.grey[400]!;
    Color buttonColor = enabled ? activeColor : inactiveColor;

    Color iconColor;
    if (selected) {
      iconColor = buttonColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    } else {
      iconColor = buttonColor;
    }

    return ReorderableDragStartListener(
      index: index,
      child: AspectRatio(
        aspectRatio: 0.8,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Semantics(
            label: effectInfo.longName,
            selected: selected,
            child: GestureDetector(
              onTap: onTap,
              onHorizontalDragStart: reorderable ? null : (details) {},
              onVerticalDragStart: (details) {
                onDoubleTap?.call();
              },
              child: Transform.translate(
                offset: Offset(0, selected ? -5 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: selected
                              ? buttonColor
                              : Theme.of(context).scaffoldBackgroundColor,
                          border: Border.all(
                            color: buttonColor,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3))),
                      child: Icon(
                        effectInfo.icon,
                        color: iconColor,
                      ),
                    ),
                    ExcludeSemantics(
                      child: Text(
                        effectInfo.shortName,
                        style: TextStyle(
                            fontSize: 10,
                            color: enabled
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).textTheme.bodySmall!.color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}