// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'package:mighty_plug_manager/midi/MidiControllerManager.dart';

import '../../bluetooth/ble_controllers/BLEController.dart';
import '../../bluetooth/devices/features/tuner.dart';
import '../../midi/ControllerConstants.dart';
import '../mightierIcons.dart';
import '../pages/tunerPage.dart';
import 'common/blinkWidget.dart';

class MAAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double? elevation;
  final bool showExpandButton;
  final bool expanded;
  final Function(bool)? onExpandStateChanged;

  const MAAppBar({
    this.elevation,
    this.showExpandButton = false,
    this.onExpandStateChanged,
    this.expanded = true,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(46);

  @override
  State<MAAppBar> createState() => _NuxAppBarState();
}

class _NuxAppBarState extends State<MAAppBar> {
  static const batteryKey = "batteryValue";

  int? batteryValue;
  StreamSubscription? _hotkeySub;

  @override
  void initState() {
    super.initState();
    batteryValue = PageStorage.of(context)
        .readState(context, identifier: batteryKey) as int?;

    _hotkeySub = MidiControllerManager()
        .controllerStream
        .listen(_onMidiControllerMessage);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _hotkeySub?.cancel();
  }

  void _onMidiControllerMessage(HotkeyControl event) {
    if (ModalRoute.of(context)?.isCurrent == false) {
      return;
    }
    if (event == HotkeyControl.ToggleTuner) {
      var dev = NuxDeviceControl().device;
      if (dev is Tuner) {
        var tuner = dev as Tuner;
        if (tuner.tunerAvailable) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TunerPage(
                    device: dev,
                  )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var devControl = NuxDeviceControl.instance();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showExpandButton)
          Container(
            height: kToolbarHeight,
            width: kToolbarHeight,
            color: Theme.of(context).primaryColor,
            child: IconButton(
              icon: Icon(
                widget.expanded ? Icons.arrow_left : Icons.arrow_right,
                size: 32,
              ),
              onPressed: () {
                widget.onExpandStateChanged?.call(!widget.expanded);
              },
            ),
          ),
        if (widget.expanded)
          Expanded(
            child: AppBar(
              elevation: widget.elevation,
              title: const AppBarTitle(),
              titleSpacing: widget.showExpandButton ? 0 : null,
              centerTitle: widget.showExpandButton ? false : null,
              actions: [
                //battery percentage
                StreamBuilder<int>(
                  stream: devControl.batteryPercentage,
                  builder: (context, batteryPercentage) {
                    if (devControl.isConnected &&
                        (batteryPercentage.data != 0 || batteryValue != null) &&
                        devControl.device.batterySupport) {
                      if (batteryPercentage.hasData) {
                        batteryValue = batteryPercentage.data;
                      }
                      if (batteryValue != null) {
                        PageStorage.of(context).writeState(
                            context, batteryValue,
                            identifier: batteryKey);
                      }
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
                            "$batteryValue%",
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
                if (!widget.showExpandButton)
                  StreamBuilder(
                    stream: devControl.connectStatus,
                    builder: (context,
                        AsyncSnapshot<DeviceConnectionState> snapshot) {
                      if (snapshot.data != DeviceConnectionState.disconnected &&
                          devControl.device is Tuner &&
                          (devControl.device as Tuner).tunerAvailable) {
                        return IconButton(
                            icon: const Icon(MightierIcons.tuner),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TunerPage(
                                        device: devControl.device,
                                      )));
                            });
                      }
                      return const SizedBox();
                    },
                  ),
                StreamBuilder<MidiSetupStatus>(
                  stream: BLEMidiHandler.instance().status,
                  builder: (context, snapshot) {
                    IconData icon = Icons.bluetooth_disabled;
                    Color color = Colors.grey;
                    var status = BLEMidiHandler.instance().currentStatus;
                    switch (status) {
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
                        return const BlinkWidget(
                          interval: 500,
                          children: [
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
                        batteryValue = null;
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
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (BuildContext context, value, Widget? child) {
        if (value is String && value.trim() != "") {
          return Text("$value - Mightier Amp");
        }
        return const Text("Mightier Amp");
      },
      valueListenable: NuxDeviceControl.instance().presetNameNotifier,
    );
  }
}
