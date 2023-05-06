import 'package:flutter/material.dart';

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

  const EffectChainButton(
      {Key? key,
      required this.effectInfo,
      required this.enabled,
      required this.selected,
      required this.color,
      this.onTap,
      this.onDoubleTap,
      required this.index,
      required this.reorderable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _color = enabled ? color : Theme.of(context).disabledColor;
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
                              ? _color
                              : Theme.of(context).scaffoldBackgroundColor,
                          border: Border.all(
                            color: _color,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3))),
                      child: Icon(
                        effectInfo.icon,
                        //size: 30,
                        color: selected ? Colors.black : _color,
                      ),
                    ),
                    ExcludeSemantics(
                      child: Text(
                        effectInfo.shortName,
                        style: TextStyle(
                            fontSize: 10,
                            color: enabled
                                ? null
                                : Theme.of(context).textTheme.caption!.color),
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
