import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugConsole extends StatelessWidget {
  static String output = "";

  static void print(Object? value) {
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
                Clipboard.setData(new ClipboardData(text: output));
              },
              child: Text("Copy to Clipboard"))
        ],
      ),
    );
  }
}
