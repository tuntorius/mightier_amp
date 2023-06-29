import 'package:flutter/material.dart';

class HoldToRepeat extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration initialDelay;
  final Duration repeatInterval;

  const HoldToRepeat({
    Key? key,
    required this.child,
    required this.onPressed,
    this.initialDelay = const Duration(milliseconds: 800),
    this.repeatInterval = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  _HoldToRepeatState createState() => _HoldToRepeatState();
}

class _HoldToRepeatState extends State<HoldToRepeat> {
  bool _isPressed = false;

  void _doRepeatingAction() {
    if (_isPressed) {
      widget.onPressed();
      Future.delayed(widget.repeatInterval, _doRepeatingAction);
    }
  }

  void _onTapDown() {
    widget.onPressed();
    setState(() {
      _isPressed = true;
      Future.delayed(widget.initialDelay, () {
        if (_isPressed) {
          _doRepeatingAction();
        }
      });
    });
    Feedback.forTap(context);
  }

  void _onTapUp() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapUp,
      child: widget.child,
    );
  }
}
