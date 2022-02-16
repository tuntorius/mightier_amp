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
  late NuxDevice device;

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
    device.removeListener(onDeviceDataChanged);
    device = NuxDeviceControl().device;
    device.addListener(onDeviceDataChanged);
    setState(() {});
  }

  void savePresetToDevice() {
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
  }

  void onDeviceDataChanged() {
    setState(() {});
  }

  Widget wrapContainer(bool isPortrait, List<Widget> children) {
    if (isPortrait) {
      return ConstrainedBox(
        child: Column(children: children),
        constraints: BoxConstraints(minHeight: 592),
      );
    } else
      return ListView(children: children);
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var vpHeight = MediaQuery.of(context).size.height;

    bool uploadPresetEnabled =
        device.deviceControl.isConnected && device.presetSaveSupport;

    return wrapContainer(isPortrait, [
      Column(children: [
        ButtonTheme(
          minWidth: 45,
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  MaterialButton(
                    onPressed: NuxDeviceControl().changes.canUndo
                        ? () {
                            var changes = NuxDeviceControl().changes;
                            if (changes.canUndo) changes.undo();
                            setState(() {});
                          }
                        : null,
                    color: Colors.blue,
                    child: Icon(Icons.undo),
                    //padding: EdgeInsets.zero,
                  ),
                  MaterialButton(
                    onPressed: NuxDeviceControl().changes.canRedo
                        ? () {
                            var changes = NuxDeviceControl().changes;
                            if (changes.canRedo) changes.redo();
                            setState(() {});
                          }
                        : null,
                    color: Colors.blue,
                    child: Icon(Icons.redo),
                    //padding: EdgeInsets.zero,
                  ),
                ],
              ),
              Row(
                children: [
                  ToggleButtons(
                    constraints: BoxConstraints(
                        minWidth: 55,
                        maxWidth: 55,
                        minHeight: 45,
                        maxHeight: 45),
                    children: [Icon(Icons.compare)],
                    isSelected: [!NuxDeviceControl().changes.canUndo],
                    selectedBorderColor: Colors.transparent,
                    borderColor: Colors.blue,
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white,
                    fillColor: Colors.blue,
                    disabledColor: Colors.grey,
                    onPressed: NuxDeviceControl().changes.canUndo ||
                            NuxDeviceControl().changes.canRedo
                        ? (val) {
                            var changes = NuxDeviceControl().changes;
                            if (changes.canUndo) {
                              //we can go back (that's bad though)
                              while (changes.canUndo) changes.undo();
                            } else
                              while (changes.canRedo) changes.redo();
                            setState(() {});
                          }
                        : null,
                  )
                ],
              ),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MaterialButton(
                        color: Colors.blue,
                        child: Icon(Icons.save_alt),
                        onPressed:
                            !uploadPresetEnabled ? null : savePresetToDevice,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      MaterialButton(
                        color: Colors.blue,
                        child: Icon(Icons.playlist_add),
                        onPressed: () {
                          var saveDialog = SavePresetDialog(
                              device: device, confirmColor: Colors.blue);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                saveDialog.buildDialog(device, context),
                          );
                        },
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ]),
      if (isPortrait)
        Flexible(child: ChannelSelector(device: device))
      else
        ChannelSelector(device: device)
    ]);
  }
}
