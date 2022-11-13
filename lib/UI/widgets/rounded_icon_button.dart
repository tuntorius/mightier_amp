import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

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
    return Container(
      decoration: ShapeDecoration(
        color: onPressed != null ? Colors.blue : Colors.grey[800],
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
