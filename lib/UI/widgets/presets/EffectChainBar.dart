import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
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

  const EffectChainBar({
    Key? key,
    required this.maxHeight,
    required this.device,
    required this.preset,
    required this.onTap,
    required this.onDoubleTap,
    required this.onReorder,
    required this.reorderable,
  }) : super(key: key);

  Widget buildItem(context, index) {
    var proc = preset.getFXIDFromSlot(index);
    var effect = device.getProcessorInfoByFXID(proc);
    
    // SAFEGUARD: If the effect doesn't exist (e.g. out of bounds during a transition), render empty space
    if (effect == null) {
       return SizedBox(
         key: Key(index.toString()), 
         width: 50,
       );
    }
    
    bool selected = index == device.selectedSlot;
    
    // SAFEGUARD: Ensure color lookup gracefully degrades
    Color chainColor = Colors.grey;
    try {
      chainColor = preset.effectColor(index);
    } catch (e) {
      chainColor = Colors.grey;
    }
    
    // SAFEGUARD: Ensure enabled lookup gracefully degrades
    bool chainEnabled = true;
    try {
      chainEnabled = preset.slotEnabled(index);
    } catch (e) {
      chainEnabled = true;
    }

    return EffectChainButton(
      index: index,
      effectInfo: effect,
      color: chainColor,
      enabled: chainEnabled,
      selected: selected,
      reorderable: reorderable,
      key: Key(index.toString()),
      onTap: () => onTap(index),
      onDoubleTap: () => onDoubleTap(index),
    );
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
        itemCount: device.effectsChainLength, // FIX: Reverted to device length to respect the base class
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
        itemCount: device.effectsChainLength, // FIX: Reverted to device length
        itemBuilder: buildItem,
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: constrainHeight),
      child: list,
    );
  }
}