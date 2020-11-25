// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../bluetooth/bleMidiHandler.dart';
import '../widgets/deviceList.dart';
import 'calibration.dart';

class Settings extends StatefulWidget {
  static String output = "";
  static void print(String value) {
    if (output.isNotEmpty) output += "\n";
    output += value;
  }

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  BLEMidiHandler midiHandler = BLEMidiHandler();

  Future<int> future;
  int value = 0;
  @override
  void initState() {
    super.initState();
    future = generateValue();
    //changeValue();
  }

  Future<int> generateValue() async {
    await Future.delayed(Duration(seconds: 1));
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    List<String> items =
        Settings.output != null ? Settings.output.split('\n') : List<String>();
    return Container(
      child: Center(
        child: Column(
          children: [
            FutureBuilder(
                future: future,
                builder: (context, AsyncSnapshot<int> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text("Waiting");
                    case ConnectionState.done:
                      return Text(value.toString());
                    default:
                      return Text("default");
                  }
                }),
            Expanded(
                child: ListView.builder(
              itemBuilder: (context, index) {
                return Text(items[index]);
              },
              itemCount: items.length,
            )),
            Expanded(
              child: StreamBuilder<midiSetupStatus>(
                  builder: (BuildContext context, snapshot) {
                    return DeviceList();
                  },
                  stream: midiHandler.status),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Calibration()));
              },
              child: Text("Calibrate"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  child: Text("Scan"),
                  onPressed: () {
                    midiHandler.startScanning();
                  },
                ),
                RaisedButton(
                  child: Text("Stop Scanning"),
                  onPressed: () {
                    midiHandler.stopScanning();
                  },
                ),
                RaisedButton(
                  child: Text("Disconnect"),
                  onPressed: () {
                    midiHandler.disconnectDevice();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
