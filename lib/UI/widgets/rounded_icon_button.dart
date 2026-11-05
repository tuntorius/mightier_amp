// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final double borderRadius;

  const RoundedIconButton(
      {Key? key,
      this.onPressed,
      required this.icon,
      this.tooltip,
      this.borderRadius = 6})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color disabledBg = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return Container(
      decoration: ShapeDecoration(
        color: onPressed != null ? Colors.blue : disabledBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius)),
      ),
      child: IconButton(
        constraints: ButtonTheme.of(context).constraints,
        icon: icon,
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}