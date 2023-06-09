import 'package:flutter/material.dart';

class EQGroup extends StatelessWidget {
  final int eqGroup;
  final void Function(int?)? onChanged;
  const EQGroup({super.key, required this.eqGroup, this.onChanged});

  static const List<DropdownMenuItem<int>> eqGroups = [
    DropdownMenuItem<int>(
      value: 0,
      child: Text("Group 1"),
    ),
    DropdownMenuItem<int>(
      value: 1,
      child: Text("Group 2"),
    ),
    DropdownMenuItem<int>(
      value: 2,
      child: Text("Group 3"),
    ),
    DropdownMenuItem<int>(
      value: 3,
      child: Text("Group 4"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "EQ Group",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(
          width: 8,
        ),
        DropdownButton(
          items: eqGroups,
          onChanged: onChanged,
          value: eqGroup,
        )
      ],
    );
  }
}
