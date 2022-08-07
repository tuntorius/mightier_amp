import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/nestedWillPopScope.dart';
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

  bool sliderChanging = false;

  @override
  void initState() {
    super.initState();
    NuxDeviceControl.instance().onDataReceiveDebug = _onDataReceive;
    NuxDeviceControl.instance().developer = true;
  }

  void _onDataReceive(List<int> data) {
    setState(() {
      controller.text += data.toString() + "\n";
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (!NuxDeviceControl.instance().isConnected)
    //   return Center(
    //     child: Text("No device connected"),
    //   );
    return NestedWillPopScope(
      onWillPop: () {
        NuxDeviceControl.instance().developer = false;
        return Future.value(true);
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: AbsorbPointer(
                absorbing: !NuxDeviceControl.instance().developer,
                child: Opacity(
                  opacity: NuxDeviceControl.instance().developer ? 1 : 0.5,
                  child: SingleChildScrollView(
                    child: TextField(
                      enabled: NuxDeviceControl.instance().developer,
                      controller: controller,
                      maxLines: null,
                      readOnly: true,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /*RadioListTile(
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
                      }),*/
                  Text(
                    "CC Message",
                    style: TextStyle(fontSize: 18),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("CC Number"),
                      NumberPicker(
                        axis: Axis.horizontal,
                        minValue: 0,
                        maxValue: 127,
                        value: data[0],
                        //hex: true,
                        textStyle: TextStyle(color: Colors.grey[600]),
                        itemWidth: 60,
                        zeroPad: false,
                        onChanged: (val) {
                          data[0] = val;
                          setState(() {});
                        },
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Value (numeric)"),
                      NumberPicker(
                        axis: Axis.horizontal,
                        minValue: 0,
                        maxValue: 127,
                        value: data[1],
                        textStyle: TextStyle(color: Colors.grey[600]),
                        //hex: true,
                        itemWidth: 60,
                        zeroPad: false,
                        onChanged: (val) {
                          if (sliderChanging) return;
                          data[1] = val;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  Slider(
                      min: 0,
                      max: 127,
                      label: "${data[1]}",
                      value: data[1].toDouble(),
                      onChangeStart: (value) => sliderChanging = true,
                      onChangeEnd: (value) async {
                        await Future.delayed(Duration(milliseconds: 800));
                        sliderChanging = false;
                      },
                      onChanged: (value) {
                        data[1] = value.round();
                        setState(() {});
                      }),
                  SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Value (switch)"),
                      value: data[1] != 0,
                      onChanged: (value) {
                        data[1] = value ? 127 : 0;
                        setState(() {});
                      }),
                  ElevatedButton(
                      onPressed: () {
                        if (!NuxDeviceControl.instance().isConnected) return;
                        var msg = NuxDeviceControl.instance()
                            .createCCMessage(data[0], data[1]);
                        BLEMidiHandler.instance().sendData(msg);
                      },
                      child: Text("Send")),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          controller.text = "";
                        });
                      },
                      child: Text("Clear console"))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
