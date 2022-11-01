// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';

import 'blinkWidget.dart';

class NuxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? elevation;
  final bool showExpandButton;
  final bool expanded;
  final Function(bool)? onExpandStateChanged;

  const NuxAppBar({
    this.elevation,
    this.showExpandButton = false,
    this.onExpandStateChanged,
    this.expanded = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showExpandButton)
          Container(
            height: kToolbarHeight,
            width: kToolbarHeight,
            color: Theme.of(context).primaryColor,
            child: IconButton(
              icon: Icon(
                expanded ? Icons.arrow_left : Icons.arrow_right,
                size: 32,
              ),
              onPressed: () {
                onExpandStateChanged?.call(!expanded);
              },
            ),
          ),
        if (expanded)
          Expanded(
            child: AppBar(
              elevation: elevation,
              title: const Text("Mightier Amp"),
              titleSpacing: showExpandButton ? 0 : null,
              centerTitle: showExpandButton ? false : null,
              actions: [
                //battery percentage
                StreamBuilder<int>(
                  stream: NuxDeviceControl.instance().batteryPercentage.stream,
                  builder: (context, batteryPercentage) {
                    if (NuxDeviceControl.instance().isConnected &&
                        batteryPercentage.connectionState ==
                            ConnectionState.active &&
                        batteryPercentage.data != 0 &&
                        NuxDeviceControl.instance().device.batterySupport) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                              angle: pi / 2,
                              child: const Icon(
                                Icons.battery_full,
                                size: 40,
                              )),
                          Text(
                            "${batteryPercentage.data}%",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(width: 8),
                StreamBuilder<MidiSetupStatus>(
                  stream: BLEMidiHandler.instance().status,
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
                      case MidiSetupStatus
                          .deviceFound: //note device found is issued
                      //during search only, but here it means nothing
                      //so keep search status
                      case MidiSetupStatus.deviceSearching:
                        icon = Icons.bluetooth_searching;
                        return BlinkWidget(
                          interval: 500,
                          children: const [
                            Icon(
                              Icons.bluetooth_searching,
                              color: Colors.grey,
                            ),
                            Icon(Icons.bluetooth_searching)
                          ],
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
                ),
                const SizedBox(
                  width: 15,
                )
              ],
            ),
          )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
