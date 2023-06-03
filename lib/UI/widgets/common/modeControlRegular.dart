import 'package:flutter/material.dart';

class ModeControlRegular extends StatelessWidget {
  final List<String> options;
  final int selected;
  final void Function(int index)? onSelected;
  final TextStyle? textStyle;
  const ModeControlRegular(
      {super.key,
      required this.options,
      required this.selected,
      this.onSelected,
      this.textStyle});

  Widget _modeButton(String mode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(mode, style: textStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<bool> active =
        List.generate(options.length, (i) => i == selected ? true : false);
    return ToggleButtons(
      fillColor: Colors.blue,
      selectedBorderColor: Colors.blue,
      borderColor: Colors.grey[600],
      color: Colors.grey,
      isSelected: active,
      onPressed: onSelected,
      children: [
        for (var i = 0; i < options.length; i++) _modeButton(options[i])
      ],
    );
  }
}
