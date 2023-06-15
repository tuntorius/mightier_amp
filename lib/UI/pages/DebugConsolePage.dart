import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugConsole extends StatelessWidget {
  static String output = "";

  const DebugConsole({Key? key}) : super(key: key);

  static void print(Object? value) {
    output += "$value\n";
  }

  static void printString(Object? value) {
    output += "$value\n";
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController c = TextEditingController(text: DebugConsole.output);
    return Scaffold(
      appBar: AppBar(title: const Text("Debug console")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TextField(
                maxLines: null,
                readOnly: true,
                controller: c,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: output));
                    },
                    child: const Text("Copy to Clipboard")),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: () {
                      output = "";
                      c.clear();
                    },
                    child: const Text("Clear")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
