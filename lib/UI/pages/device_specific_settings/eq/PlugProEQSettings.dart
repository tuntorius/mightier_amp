// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/device_specific_settings/eq/bt_audio_options.dart';
import 'package:mighty_plug_manager/UI/widgets/presets/effectEditors/EqualizerEditor.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/plugProCommunication.dart';
import '../../../../bluetooth/NuxDeviceControl.dart';
import '../../../../bluetooth/devices/effects/Processor.dart';
import '../../../../bluetooth/devices/effects/plug_pro/EQ.dart';
import 'eq_group.dart';

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

  @override
  void initState() {
    super.initState();
    _requestEQData(device.config.bluetoothGroup);
  }

  void _requestEQData(int index) {
    _requestInProgress = true;
    (device.communication as PlugProCommunication).requestBTEQData(index);
  }

  List<Widget> _buildGroupWidget() {
    return [
      EQGroup(
        eqGroup: device.config.bluetoothGroup,
        onChanged: (int? value) {
          if (value != null) {
            //request another
            device.config.bluetoothGroup = value;
            communication.setBTEq(value);
            _requestEQData(device.config.bluetoothGroup);
            setState(() {});
          }
        },
      ),
      BTAudioOptions(
          btInvertChannel: device.config.bluetoothInvertChannel,
          btEQMute: device.config.bluetoothEQMute,
          onInvert: (invert) {
            device.config.bluetoothInvertChannel = invert;
            communication.setBTInvert(device.config.bluetoothInvertChannel);
          },
          onMute: (mute) {
            device.config.bluetoothEQMute = mute;
            communication.setBTMute(device.config.bluetoothEQMute);
          })
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
            communication.saveBTEQGroup(device.config.bluetoothGroup);
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
      body: StreamBuilder(
          stream:
              (device.communication as PlugProCommunication).bluetoothEQStream,
          builder: (context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                _requestInProgress) {
              btEQ.setupFromNuxPayload(snapshot.data!);
              device.config.bluetoothInvertChannel = snapshot.data![12] > 0;
              device.config.bluetoothEQMute = snapshot.data![13] > 0;
              _requestInProgress = false;
            }
            return ListTileTheme(
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
                      child: EqualizerEditor(
                        eqEffect: btEQ,
                        enabled: true,
                        onChanged: _changeEQValue,
                        onChangedFinal: (parameter, value, oldValue) =>
                            _changeEQValue(parameter, value, false),
                      ),
                    )
                  ],
                ));
          }),
    );
  }

  void _changeEQValue(Parameter parameter, double value, bool skip) {
    parameter.value = value;
    setState(() {
      if (!skip) NuxDeviceControl.instance().sendParameter(parameter, false);
    });
  }
}
