// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/presets/effectEditors/EqualizerEditor.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/plugProCommunication.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/effects/Processor.dart';
import '../../../bluetooth/devices/effects/plug_pro/EQ.dart';

class PlugProEQSettings extends StatefulWidget {
  const PlugProEQSettings({Key? key}) : super(key: key);

  @override
  State createState() => _PlugProEQSettingsState();
}

class _PlugProEQSettingsState extends State<PlugProEQSettings> {
  final device = NuxDeviceControl.instance().device as NuxMightyPlugPro;
  final communication =
      NuxDeviceControl.instance().device.communication as PlugProCommunication;
  bool _requestInProgress = false;

  static const List<DropdownMenuItem<int>> eqGroups = [
    DropdownMenuItem<int>(
      value: 0,
      child: Text("Group 1"),
    ),
    DropdownMenuItem<int>(
      value: 1,
      child: Text("Group 2"),
    ),
    DropdownMenuItem<int>(
      value: 2,
      child: Text("Group 3"),
    ),
    DropdownMenuItem<int>(
      value: 3,
      child: Text("Group 4"),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _requestBTData(device.config.bluetoothGroup);
  }

  void _requestBTData(int index) {
    _requestInProgress = true;
    (device.communication as PlugProCommunication).requestBTEQData(index);
  }

  List<Widget> _buildGroupWidget() {
    return [
      Row(
        children: [
          const Text(
            "EQ Group",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(
            width: 8,
          ),
          DropdownButton(
            items: eqGroups,
            onChanged: (int? value) {
              if (value != null) {
                //request another
                device.config.bluetoothGroup = value;
                communication.setBTEq(value);
                _requestBTData(device.config.bluetoothGroup);
                setState(() {});
              }
            },
            value: device.config.bluetoothGroup,
          )
        ],
      ),
      ToggleButtons(
        fillColor: Colors.blue,
        selectedBorderColor: Colors.blue,
        color: Colors.grey,
        isSelected: [
          device.config.bluetoothInvertChannel,
          device.config.bluetoothEQMute
        ],
        onPressed: (index) {
          switch (index) {
            case 0:
              device.config.bluetoothInvertChannel =
                  !device.config.bluetoothInvertChannel;
              communication.setBTInvert(device.config.bluetoothInvertChannel);
              break;
            case 1:
              device.config.bluetoothEQMute = !device.config.bluetoothEQMute;
              communication.setBTMute(device.config.bluetoothEQMute);
              break;
          }
          setState(() {});
        },
        children: [
          const Tooltip(
            message: "Invert one audio channel.",
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Icon(Icons.mic_off),
            ),
          ),
          Tooltip(
            message: "Mute Bluetooth audio.",
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Icon(device.config.bluetoothEQMute
                  ? Icons.volume_off
                  : Icons.volume_up),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildButtons(EQTenBandBT btEQ) {
    return [
      ElevatedButton(
          child: const Text("Reset"),
          onPressed: () {
            for (var param in btEQ.parameters) {
              param.value = 0;
              NuxDeviceControl.instance().sendParameter(param, false);
            }
            setState(() {});
          }),
      const SizedBox(width: 6),
      ElevatedButton(
          child: const Text("Save"),
          onPressed: () {
            communication.saveEQGroup(device.config.bluetoothGroup);
          })
    ];
  }

  @override
  Widget build(BuildContext context) {
    var btEQ = device.config.bluetoothEQ;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth EQ Settings"),
      ),
      body: ListTileTheme(
          minLeadingWidth: 0,
          iconColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isPortrait)
                ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: const Text("Bluetooth Settings"),
                  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildButtons(btEQ)),
                ),
              if (isPortrait)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildGroupWidget(),
                ),
              if (!isPortrait)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ..._buildGroupWidget(),
                    Row(children: _buildButtons(btEQ))
                  ],
                ),
              Expanded(
                child: StreamBuilder(
                    stream: (device.communication as PlugProCommunication)
                        .bluetoothEQStream,
                    builder: (context, AsyncSnapshot<List<int>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          _requestInProgress) {
                        btEQ.setupFromNuxPayload(snapshot.data!);
                        _requestInProgress = false;
                      }
                      return EqualizerEditor(
                        eqEffect: btEQ,
                        enabled: true,
                        onChanged: _changeEQValue,
                        onChangedFinal: (parameter, value, oldValue) =>
                            _changeEQValue(parameter, value, false),
                      );
                    }),
              )
            ],
          )),
    );
  }

  void _changeEQValue(Parameter parameter, double value, bool skip) {
    parameter.value = value;
    setState(() {
      if (!skip) NuxDeviceControl.instance().sendParameter(parameter, false);
    });
  }
}
