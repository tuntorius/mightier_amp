// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../../bluetooth/bleMidiHandler.dart';

class DeviceList extends StatelessWidget {
  final BLEMidiHandler midiHandler = BLEMidiHandler();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build
      itemCount: midiHandler.scanResults.length,
      // Provide a builder function. This is where the magic happens! We'll
      // convert each item into a Widget based on the type of item it is.
      itemBuilder: (context, index) {
        final result = midiHandler.scanResults[index];
        return ListTile(
          title: Text(result.device.name ?? "(No name)",
              style: Theme.of(context).textTheme.headline6.copyWith(
                  color: midiHandler.connectedDevice != null &&
                          result.device.id == midiHandler.connectedDevice.id
                      ? Colors.blue
                      : Colors.white)),
          trailing: result.device.type != BluetoothDeviceType.classic
              ? Icon(Icons.bluetooth, color: Colors.white)
              : null,
          onTap: () {
            midiHandler.connectToDevice(result.device);
            //Navigator.of(context).push(MaterialPageRoute<Null>(
            //  builder: (_) => ControllerPage(),));
          },
        );
      },
    );
  }
}
