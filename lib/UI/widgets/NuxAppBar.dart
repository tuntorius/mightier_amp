// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'dart:math';
import 'blinkWidget.dart';

AppBar getAppBar(BLEMidiHandler handler) {
  return AppBar(
    toolbarHeight: 46,
    title: Text("Mightier Amp"),
    actions: [
      //battery percentage
      StreamBuilder<int>(
        builder: (context, value) {
          if (NuxDeviceControl().isConnected &&
              value.connectionState == ConnectionState.active &&
              value.data != 0 &&
              NuxDeviceControl().device.batterySupport) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                    angle: pi / 2,
                    child: Icon(
                      Icons.battery_full,
                      size: 40,
                    )),
                Text(
                  "${value.data}%",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                )
              ],
            );
          }
          return SizedBox();
        },
        stream: NuxDeviceControl().batteryPercentage.stream,
      ),
      const SizedBox(width: 8),
      StreamBuilder<MidiSetupStatus>(
        builder: (context, snapshot) {
          IconData icon = Icons.bluetooth_disabled;
          Color color = Colors.grey;
          switch (snapshot.data) {
            case null:
              break;
            case MidiSetupStatus.bluetoothOff:
              icon = Icons.bluetooth_disabled;
              break;
            case MidiSetupStatus.deviceIdle:
            case MidiSetupStatus.deviceConnecting:
              icon = Icons.bluetooth;
              break;
            case MidiSetupStatus.deviceFound: //note device found is issued
            //during search only, but here it means nothing
            //so keep search status
            case MidiSetupStatus.deviceSearching:
              icon = Icons.bluetooth_searching;
              return BlinkWidget(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    color: Colors.grey,
                  ),
                  Icon(Icons.bluetooth_searching)
                ],
                interval: 500,
              );

            case MidiSetupStatus.deviceConnected:
              icon = Icons.bluetooth_connected;
              color = Colors.white;
              break;
            case MidiSetupStatus.deviceDisconnected:
              icon = Icons.bluetooth;
              break;
            case MidiSetupStatus.unknown:
              icon = Icons.bluetooth_disabled;
              break;
          }
          return Icon(icon, color: color);
        },
        stream: handler.status,
      ),
      const SizedBox(
        width: 15,
      )
    ],
  );
}
