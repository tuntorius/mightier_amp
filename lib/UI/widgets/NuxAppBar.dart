// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'dart:math';
import 'blinkWidget.dart';

AppBar getAppBar(BLEMidiHandler handler) {
  return AppBar(
    title: Text("Mightier Amp"),
    actions: [
      StreamBuilder<int>(
        builder: (context, value) {
          if (NuxDeviceControl().device.deviceControl.isConnected &&
              value.connectionState == ConnectionState.active &&
              value.data != 0) {
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
          return Container();
        },
        stream: NuxDeviceControl().batteryPercentage.stream,
      ),
      SizedBox(width: 8),
      StreamBuilder<midiSetupStatus>(
        builder: (context, snapshot) {
          IconData icon = Icons.bluetooth_disabled;
          Color color = Colors.grey;
          switch (snapshot.data) {
            case midiSetupStatus.bluetoothOff:
              icon = Icons.bluetooth_disabled;
              break;
            case midiSetupStatus.deviceIdle:
            case midiSetupStatus.deviceConnecting:
              icon = Icons.bluetooth;
              break;
            case midiSetupStatus.deviceFound: //note device found is issued
            //during search only, but here it means nothing
            //so keep search status
            case midiSetupStatus.deviceSearching:
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

            case midiSetupStatus.deviceConnected:
              icon = Icons.bluetooth_connected;
              color = Colors.white;
              break;
            case midiSetupStatus.deviceDisconnected:
              icon = Icons.bluetooth;
              break;
            case midiSetupStatus.unknown:
              icon = Icons.bluetooth_disabled;
              break;
          }
          return Icon(icon, color: color);
        },
        stream: handler.status,
      ),
      SizedBox(
        width: 15,
      )
    ],
  );
}
