// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import '../../popups/savePreset.dart';
import '../../../bluetooth/devices/presets/Preset.dart';
import 'channelSelector.dart';
import '../../../bluetooth/devices/NuxDevice.dart';

class InstrumentSelector extends StatefulWidget {
  final NuxDevice device;

  InstrumentSelector(this.device);
  @override
  _InstrumentSelectorState createState() => _InstrumentSelectorState();
}

class _InstrumentSelectorState extends State<InstrumentSelector> {
  NuxDevice device;
  @override
  void initState() {
    super.initState();
    device = widget.device;
    device.addListener(onDeviceDataChanged);
  }

  @override
  void dispose() {
    super.dispose();
    device.removeListener(onDeviceDataChanged);
  }

  void onDeviceDataChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<bool> _instrumentSelection = [false, false];
    _instrumentSelection[device.selectedInstrument.index] = true;
    return Column(
      children: [
        Stack(alignment: Alignment.center, children: [
          ToggleButtons(
            fillColor: Colors.blue,
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(Icons.music_note),
                      Text("Guitar"),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [Icon(Icons.music_note_sharp), Text("Bass")],
                  ))
            ],
            isSelected: _instrumentSelection,
            onPressed: (int index) {
              setState(() {
                device.selectedInstrument = Instrument.values[index];
              });
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                child: Icon(Icons.save_alt),
                onPressed: () {
                  if (device.deviceControl.isConnected) {
                    AlertDialogs.showConfirmDialog(context,
                        title: "Save preset to device",
                        cancelButton: "Cancel",
                        confirmButton: "Save",
                        confirmColor: Colors.red,
                        description: "Are you sure?", onConfirm: (val) {
                      if (val) device.saveNuxPreset();
                    });
                  }
                },
              ),
              ElevatedButton(
                child: Icon(Icons.playlist_add),
                onPressed: () {
                  var saveDialog = SavePresetDialog(device: device);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        saveDialog.buildDialog(widget.device, context),
                  );
                },
              )
            ],
          ),
        ]),
        Expanded(
          child: ChannelSelector(device: widget.device),
        )
      ],
    );
  }
}
