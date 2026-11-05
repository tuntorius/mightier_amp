// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';

import '../../bluetooth/bleMidiHandler.dart';

class DeviceList extends StatelessWidget {
  final BLEMidiHandler midiHandler = BLEMidiHandler.instance();

  DeviceList({Key? key}) : super(key: key);

  bool isConnected(String id) {
    if (midiHandler.connectedDevice != null &&
        id == midiHandler.connectedDevice?.id) {
      return true;
    }

    for (var controller in midiHandler.controllerDevices) {
      if (controller.id == id) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: midiHandler.nuxDevices.length,
      itemBuilder: (context, index) {
        final result = midiHandler.nuxDevices[index];
        return ListTile(
          title: Text(result.name,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: isConnected(result.id) 
                     ? Theme.of(context).colorScheme.primary 
                     : Theme.of(context).colorScheme.onSurface)),
          trailing: Icon(Icons.bluetooth, color: Theme.of(context).iconTheme.color),
          onTap: () {
            midiHandler.connectToDevice(result.device);
          },
        );
      },
    );
  }
}