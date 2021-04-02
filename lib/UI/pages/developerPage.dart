import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/numberPicker.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';

enum midiMessage { ccMessage, sysExMessage }

class DeveloperPage extends StatefulWidget {
  @override
  _DeveloperPageState createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  TextEditingController controller = TextEditingController(text: "");

  midiMessage msgType = midiMessage.ccMessage;
  List<int> data = [0, 0];
  @override
  void initState() {
    super.initState();
    NuxDeviceControl().onDataReceiveDebug = _onDataReceive;
  }

  void _onDataReceive(List<int> data) {
    setState(() {
      controller.text += data.toString() + "\n";
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (!NuxDeviceControl().isConnected)
    //   return Center(
    //     child: Text("No device connected"),
    //   );
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: AbsorbPointer(
            absorbing: !NuxDeviceControl().developer,
            child: Opacity(
              opacity: NuxDeviceControl().developer ? 1 : 0.5,
              child: SingleChildScrollView(
                child: TextField(
                  enabled: NuxDeviceControl().developer,
                  controller: controller,
                  maxLines: null,
                  readOnly: true,
                ),
              ),
            ),
          ),
        ),
        Expanded(
            flex: 3,
            child: Column(
              children: [
                SwitchListTile(
                    title: Text("Enable Developer Mode"),
                    dense: true,
                    value: NuxDeviceControl().developer,
                    onChanged: (value) {
                      setState(() {
                        NuxDeviceControl().developer = value;
                      });
                    }),
                RadioListTile(
                    title: Text("CC Message"),
                    dense: true,
                    value: midiMessage.ccMessage,
                    groupValue: msgType,
                    onChanged: (msg) {
                      setState(() {
                        msgType = midiMessage.ccMessage;
                      });
                    }),
                RadioListTile(
                    title: Text("SysEx Message"),
                    dense: true,
                    value: midiMessage.sysExMessage,
                    groupValue: msgType,
                    onChanged: (msg) {
                      setState(() {
                        msgType = midiMessage.sysExMessage;
                      });
                    }),
                Row(
                  children: [
                    NumberPicker(
                      minValue: 0,
                      maxValue: 127,
                      value: data[0],
                      //hex: true,
                      zeroPad: true,
                      onChanged: (val) {
                        data[0] = val;
                        setState(() {});
                      },
                    ),
                    NumberPicker(
                      minValue: 0,
                      maxValue: 127,
                      value: data[1],
                      //hex: true,
                      zeroPad: true,
                      onChanged: (val) {
                        data[1] = val;
                        setState(() {});
                      },
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (!NuxDeviceControl().isConnected) return;
                          var msg = NuxDeviceControl()
                              .createCCMessage(data[0], data[1]);
                          BLEMidiHandler().sendData(msg);
                        },
                        child: Text("Send")),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            controller.text = "";
                          });
                        },
                        child: Text("Clear"))
                  ],
                )
              ],
            ))
      ],
    );
  }
}
