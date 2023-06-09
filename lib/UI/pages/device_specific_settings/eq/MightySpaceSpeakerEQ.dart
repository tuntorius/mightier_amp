// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/presets/effectEditors/EqualizerEditor.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightySpace.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/plugProCommunication.dart';
import '../../../../bluetooth/NuxDeviceControl.dart';
import '../../../../bluetooth/devices/effects/Processor.dart';
import '../../../../bluetooth/devices/effects/plug_pro/EQ.dart';
import 'eq_group.dart';

class SpaceSpeakerEQSettings extends StatefulWidget {
  const SpaceSpeakerEQSettings({Key? key}) : super(key: key);

  @override
  State createState() => _SpaceSpeakerEQSettingsState();
}

class _SpaceSpeakerEQSettingsState extends State<SpaceSpeakerEQSettings> {
  final device = NuxDeviceControl.instance().device as NuxMightySpace;
  final communication =
      NuxDeviceControl.instance().device.communication as PlugProCommunication;
  bool _requestInProgress = false;

  static const List<int> defaultSpeakerEQ = [
    0x32,
    0x49,
    0x4b,
    0x40,
    0x32,
    0x43,
    0x24,
    0x32,
    0x32,
    0x22,
    0x51
  ];

  @override
  void initState() {
    super.initState();
    _requestEQData(device.config.speakerEQGroup);
  }

  void _requestEQData(int index) {
    _requestInProgress = true;
    (device.communication as PlugProCommunication).requestSpeakerEQData(index);
  }

  Widget _buildGroupWidget() {
    return EQGroup(
      eqGroup: device.config.speakerEQGroup,
      onChanged: (int? value) {
        if (value != null) {
          //request another
          device.config.speakerEQGroup = value;
          communication.setSpeakerEq(value);
          _requestEQData(device.config.speakerEQGroup);
          setState(() {});
        }
      },
    );
  }

  List<Widget> _buildButtons(EQTenBandSpeaker btEQ) {
    return [
      ElevatedButton(
          child: const Text("Reset"),
          onPressed: () {
            for (int i = 0; i < btEQ.parameters.length; i++) {
              if (device.config.speakerEQGroup == 0) {
                btEQ.parameters[i].midiValue = defaultSpeakerEQ[i];
              } else {
                btEQ.parameters[i].value = 0;
              }

              NuxDeviceControl.instance()
                  .sendParameter(btEQ.parameters[i], false);
            }
            setState(() {});
          }),
      const SizedBox(width: 6),
      ElevatedButton(
          child: const Text("Save"),
          onPressed: () {
            communication.saveSpeakerEQGroup(device.config.speakerEQGroup);
          })
    ];
  }

  @override
  Widget build(BuildContext context) {
    var btEQ = device.config.speakerEQ;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speaker EQ Settings"),
      ),
      body: StreamBuilder(
          stream:
              (device.communication as PlugProCommunication).speakerEQStream,
          builder: (context, AsyncSnapshot<List<int>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                _requestInProgress) {
              btEQ.setupFromNuxPayload(snapshot.data!);
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
                        leading: const Icon(Icons.speaker),
                        title: const Text("Speaker Settings"),
                        trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _buildButtons(btEQ)),
                      ),
                    if (isPortrait) _buildGroupWidget(),
                    if (!isPortrait)
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildGroupWidget(),
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
