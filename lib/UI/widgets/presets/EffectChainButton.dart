import 'package:flutter/material.dart';

import '../../../bluetooth/devices/effects/Processor.dart';

class EffectChainButton extends StatelessWidget {
  final ProcessorInfo effectInfo;
  final bool enabled;
  final bool selected;
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
      required this.index})
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
            selected: true,
            button: true,
            child: GestureDetector(
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              child: Transform.translate(
                offset: Offset(0, selected ? -5 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: selected ? _color : Colors.grey[900],
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
                        style: const TextStyle(fontSize: 10),
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
