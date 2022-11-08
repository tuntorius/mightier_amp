import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';

import '../../../bluetooth/devices/presets/Preset.dart';
import 'EffectChainButton.dart';

class EffectChainBar extends StatelessWidget {
  static const double effectsChainPadding = 6;

  final double maxHeight;
  final NuxDevice device;
  final Preset preset;
  final bool reorderable;
  final void Function(int) onTap;
  final void Function(int) onDoubleTap;
  final ReorderCallback onReorder;

  const EffectChainBar(
      {Key? key,
      required this.maxHeight,
      required this.device,
      required this.preset,
      required this.onTap,
      required this.onDoubleTap,
      required this.onReorder,
      required this.reorderable})
      : super(key: key);

  EffectChainButton buildItem(context, index) {
    var proc = preset.getProcessorAtSlot(index);
    var effect = device.processorListNuxIndex(proc);
    bool selected = index == device.selectedSlot;

    return EffectChainButton(
        index: index,
        effectInfo: effect!,
        color: preset.effectColor(index),
        enabled: preset.slotEnabled(index),
        selected: selected,
        key: Key(index.toString()),
        onTap: () => onTap(index),
        onDoubleTap: () => onDoubleTap(index));
  }

  @override
  Widget build(BuildContext context) {
    double constrainHeight = max(
        min(
            (MediaQuery.of(context).size.width - effectsChainPadding * 2) /
                device.effectsChainLength /
                0.8,
            maxHeight),
        10);

    Widget list;
    if (reorderable) {
      list = ReorderableList(
        padding: const EdgeInsets.symmetric(horizontal: effectsChainPadding),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: device.effectsChainLength,
        proxyDecorator: (widget, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              final double animValue =
                  Curves.easeInOut.transform(animation.value);
              final double offset = lerpDouble(0, -15, animValue)!;
              return Material(
                color: Colors.transparent,
                child: Transform.translate(
                  offset: Offset(0, offset),
                  child: widget,
                ),
              );
            },
          );
        },
        itemBuilder: buildItem,
        onReorder: (a, b) {
          if (b > a) b--;
          onReorder(a, b);
        },
      );
    } else {
      list = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: effectsChainPadding),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: device.effectsChainLength,
        itemBuilder: buildItem,
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: constrainHeight),
      child: list,
    );
  }
}
