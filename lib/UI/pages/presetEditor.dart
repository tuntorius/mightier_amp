// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import '../popups/savePreset.dart';
import '../widgets/presets/channelSelector.dart';
import '../../bluetooth/devices/NuxDevice.dart';

class PresetEditor extends StatefulWidget {
  PresetEditor();
  @override
  _PresetEditorState createState() => _PresetEditorState();
}

class _PresetEditorState extends State<PresetEditor> {
  NuxDevice device;

  @override
  void initState() {
    super.initState();
    device = NuxDeviceControl().device;
    device.addListener(onDeviceDataChanged);
    NuxDeviceControl().addListener(onDeviceChanged);
  }

  @override
  void dispose() {
    super.dispose();
    device.removeListener(onDeviceDataChanged);
    NuxDeviceControl().removeListener(onDeviceChanged);
  }

  void onDeviceChanged() {
    if (device != null) device.removeListener(onDeviceDataChanged);
    device = NuxDeviceControl().device;
    device.addListener(onDeviceDataChanged);
    setState(() {});
  }

  void onDeviceDataChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<bool> _instrumentSelection =
        List<bool>.filled(device.groupsCount, false);
    _instrumentSelection[device.selectedGroup] = true;
    return ListView(
      children: [
        Column(children: [
          ListTile(
            title: Text("Preset Editor"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (device.presetSaveSupport)
                  ElevatedButton(
                    child: Icon(Icons.save_alt),
                    onPressed: () {
                      //TODO: move to method
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
                SizedBox(
                  width: 2,
                ),
                ElevatedButton(
                  child: Icon(Icons.playlist_add),
                  onPressed: () {
                    var saveDialog = SavePresetDialog(device: device);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          saveDialog.buildDialog(device, context),
                    );
                  },
                )
              ],
            ),
          ),
          ToggleButtons(
            fillColor: Colors.blue,
            children: [
              for (int i = 0; i < device.groupsCount; i++)
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(device.groupsName[i])),
            ],
            isSelected: _instrumentSelection,
            onPressed: (int index) {
              setState(() {
                device.selectedGroup = index;
              });
            },
          ),
        ]),
        ChannelSelector(device: device)
      ],
    );
  }
}
