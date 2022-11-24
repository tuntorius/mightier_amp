// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../bluetooth/bleMidiHandler.dart';

class DeviceList extends StatelessWidget {
  final BLEMidiHandler midiHandler = BLEMidiHandler.instance();

  DeviceList({Key? key}) : super(key: key);

  bool isConnected(String id) {
    //check with nux device first
    if (midiHandler.connectedDevice != null && id == midiHandler.connectedDevice?.id) return true;

    for (var controller in midiHandler.controllerDevices) {
      if (controller.id == id) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build
      itemCount: midiHandler.nuxDevices.length,
      // Provide a builder function. This is where the magic happens! We'll
      // convert each item into a Widget based on the type of item it is.
      itemBuilder: (context, index) {
        final result = midiHandler.nuxDevices[index];
        return ListTile(
          title: Text(result.name,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: isConnected(result.id) ? Colors.blue : Colors.white)),
          trailing: const Icon(Icons.bluetooth, color: Colors.white),
          onTap: () {
            midiHandler.connectToDevice(result.device);
          },
        );
      },
    );
  }
}
