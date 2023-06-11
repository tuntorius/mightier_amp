import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final void Function()? onPressed;
  final double iconSize;
  final double iconPadding;
  const CircularButton(
      {super.key,
      required this.icon,
      required this.backgroundColor,
      this.onPressed,
      this.iconPadding = 20,
      this.iconSize = 28});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.all(iconPadding),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
      ),
      child: Icon(
        icon,
        size: iconSize,
      ),
    );
  }
}
