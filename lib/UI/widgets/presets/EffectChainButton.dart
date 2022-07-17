import 'package:flutter/material.dart';

import '../../../bluetooth/devices/effects/Processor.dart';

class EffectChainButton extends StatelessWidget {
  final ProcessorInfo effectInfo;
  final bool enabled;
  final Color color;
  final GestureTapCallback? onTap;

  const EffectChainButton(
      {Key? key,
      required this.effectInfo,
      required this.enabled,
      required this.color,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _color = enabled ? color : Theme.of(context).disabledColor;
    return AspectRatio(
      aspectRatio: 0.8,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 1),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: _color,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                child: Icon(
                  effectInfo.icon,
                  //size: 30,
                  color: _color,
                ),
              ),
              Text(
                effectInfo.shortName,
                style: TextStyle(
                    fontSize: 10,
                    color: enabled ? null : Theme.of(context).disabledColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
