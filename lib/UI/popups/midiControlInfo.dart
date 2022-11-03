// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';

class MidiControlInfoDialog {
  Widget buildDialog(BuildContext context,
      {required List<Processor> effects, required int paramIndex}) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop()),
          const Text('Control Info'),
        ],
      ),
      content: Container(
        height: 400,
        width: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ListView.builder(
          itemBuilder: (context, index) {
            String paramName = "N/A";
            if (effects[index].parameters.length > paramIndex) {
              paramName = effects[index].parameters[paramIndex].name;
            }

            return ListTile(
              title: Text(effects[index].name),
              trailing: Text(paramName),
            );
          },
          itemCount: effects.length,
        ),
      ),
    );
  }
}
