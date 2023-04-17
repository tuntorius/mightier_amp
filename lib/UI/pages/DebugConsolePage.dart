import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugConsole extends StatelessWidget {
  static String output = "";

  const DebugConsole({Key? key}) : super(key: key);

  static void print(Object? value) {
    output += value.toString();
  }

  static void printString(Object? value) {
    output += value.toString();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController c = TextEditingController(text: DebugConsole.output);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TextField(
              maxLines: null,
              readOnly: true,
              controller: c,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: output));
              },
              child: const Text("Copy to Clipboard"))
        ],
      ),
    );
  }
}
