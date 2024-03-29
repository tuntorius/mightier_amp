import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/common/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/UI/widgets/common/numberPicker.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';

import '../../bluetooth/devices/NuxConstants.dart';

enum midiMessage { ccMessage, sysExMessage }

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({Key? key}) : super(key: key);

  @override
  State createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  TextEditingController controller = TextEditingController(text: "");

  midiMessage msgType = midiMessage.ccMessage;
  List<int> data = [0, 0, 0, 0];

  bool sliderChanging = false;

  @override
  void initState() {
    super.initState();
    NuxDeviceControl.instance().onDataReceiveDebug = _onDataReceive;
    NuxDeviceControl.instance().developer = true;
  }

  void _onDataReceive(List<int> data) {
    setState(() {
      controller.text += "$data\n";
    });
  }

  Widget _buildCCPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "CC Message",
            style: TextStyle(fontSize: 18),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("CC Number"),
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
              const Text("Value (numeric)"),
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
                await Future.delayed(const Duration(milliseconds: 800));
                sliderChanging = false;
              },
              onChanged: (value) {
                data[1] = value.round();
                setState(() {});
              }),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Value (switch)"),
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
              child: const Text("Send")),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  controller.text = "";
                });
              },
              child: const Text("Clear console"))
        ],
      ),
    );
  }

  Widget _buildSysExPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "SysEx Request",
            style: TextStyle(fontSize: 18),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("SysEx number"),
              NumberPicker(
                axis: Axis.horizontal,
                minValue: 0,
                maxValue: 127,
                value: data[2],
                //hex: true,
                textStyle: TextStyle(color: Colors.grey[600]),
                itemWidth: 60,
                zeroPad: false,
                onChanged: (val) {
                  data[2] = val;
                  setState(() {});
                },
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Additional (-1 - no val)"),
              NumberPicker(
                axis: Axis.horizontal,
                minValue: -1,
                maxValue: 127,
                value: data[3],
                textStyle: TextStyle(color: Colors.grey[600]),
                //hex: true,
                itemWidth: 60,
                zeroPad: false,
                onChanged: (val) {
                  if (sliderChanging) return;
                  data[3] = val;
                  setState(() {});
                },
              ),
            ],
          ),
          Slider(
              min: -1,
              max: 127,
              label: "${data[1]}",
              value: data[1].toDouble(),
              onChangeStart: (value) => sliderChanging = true,
              onChangeEnd: (value) async {
                await Future.delayed(const Duration(milliseconds: 800));
                sliderChanging = false;
              },
              onChanged: (value) {
                data[3] = value.round();
                setState(() {});
              }),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Value (switch)"),
              value: data[3] != 0,
              onChanged: (value) {
                data[3] = value ? 127 : 0;
                setState(() {});
              }),
          ElevatedButton(
              onPressed: () {
                if (!NuxDeviceControl.instance().isConnected) return;

                List<int> msg = [];
                //create header
                msg.addAll([
                  0x80,
                  0x80,
                  MidiMessageValues.sysExStart,
                  0x43,
                  0x58,
                  SysexPrivacy.kSYSEX_PRIVATE,
                  data[2],
                  SyxDir.kSYXDIR_REQ,
                ]);

                if (data[3] >= 0) msg.add(data[3]);
                msg.addAll([0x80, MidiMessageValues.sysExEnd]);

                BLEMidiHandler.instance().sendData(msg);
              },
              child: const Text("Send")),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  controller.text = "";
                });
              },
              child: const Text("Clear console"))
        ],
      ),
    );
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
        body: Column(mainAxisSize: MainAxisSize.min, children: [
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
          SizedBox(
              height: 350,
              child: PageView(
                children: [_buildCCPage(), _buildSysExPage()],
              )),
        ]),
      ),
    );
  }
}
