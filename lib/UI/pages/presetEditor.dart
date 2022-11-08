// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import '../popups/savePreset.dart';
import '../utils.dart';
import '../widgets/presets/channelSelector.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../widgets/rounded_icon_button.dart';

class PresetEditor extends StatefulWidget {
  const PresetEditor();
  @override
  _PresetEditorState createState() => _PresetEditorState();
}

class _PresetEditorState extends State<PresetEditor> {
  late NuxDevice device;

  @override
  void initState() {
    super.initState();
    device = NuxDeviceControl.instance().device;
    device.addListener(onDeviceDataChanged);
    NuxDeviceControl.instance().addListener(onDeviceChanged);
  }

  @override
  void dispose() {
    super.dispose();
    device.removeListener(onDeviceDataChanged);
    NuxDeviceControl.instance().removeListener(onDeviceChanged);
  }

  void onDeviceChanged() {
    device.removeListener(onDeviceDataChanged);
    device = NuxDeviceControl.instance().device;
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

  Widget wrapContainer(bool isExpanded, List<Widget> children) {
    if (isExpanded) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 592),
        child: Column(children: children),
      );
    } else {
      return ListView(children: children);
    }
  }

  @override
  Widget build(BuildContext context) {
    var layout = getEditorLayoutMode(MediaQuery.of(context));

    bool uploadPresetEnabled =
        device.deviceControl.isConnected && device.presetSaveSupport;

    return SafeArea(
      child: wrapContainer(
        layout == EditorLayoutMode.expand,
        [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ButtonTheme(
              minWidth: 55,
              height: 45,
              buttonColor: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      RoundedIconButton(
                        onPressed: NuxDeviceControl.instance().changes.canUndo
                            ? () {
                                var changes =
                                    NuxDeviceControl.instance().changes;
                                if (changes.canUndo) changes.undo();
                                setState(() {});
                              }
                            : null,
                        tooltip: "Undo",
                        icon: const Icon(Icons.undo),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      RoundedIconButton(
                        onPressed: NuxDeviceControl.instance().changes.canRedo
                            ? () {
                                var changes =
                                    NuxDeviceControl.instance().changes;
                                if (changes.canRedo) changes.redo();
                                setState(() {});
                              }
                            : null,
                        icon: const Icon(Icons.redo),
                        tooltip: "Redo",
                        //padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ToggleButtons(
                        constraints: const BoxConstraints(
                            minWidth: 55,
                            maxWidth: 55,
                            minHeight: 45,
                            maxHeight: 45),
                        isSelected: [
                          !NuxDeviceControl.instance().changes.canUndo
                        ],
                        selectedBorderColor: Colors.transparent,
                        borderColor: Colors.blue,
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white,
                        fillColor: Colors.blue,
                        disabledColor: Colors.grey,
                        onPressed:
                            NuxDeviceControl.instance().changes.canUndo ||
                                    NuxDeviceControl.instance().changes.canRedo
                                ? (val) {
                                    var changes =
                                        NuxDeviceControl.instance().changes;
                                    if (changes.canUndo) {
                                      //we can go back (that's bad though)
                                      while (changes.canUndo) {
                                        changes.undo();
                                      }
                                    } else {
                                      while (changes.canRedo) {
                                        changes.redo();
                                      }
                                    }
                                    setState(() {});
                                  }
                                : null,
                        children: const [
                          Tooltip(
                              message: "Compare before/after",
                              child: Icon(Icons.compare))
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RoundedIconButton(
                            tooltip: "Save to device",
                            onPressed: !uploadPresetEnabled
                                ? null
                                : savePresetToDevice,
                            icon: const Icon(Icons.save_alt),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          RoundedIconButton(
                            icon: const Icon(Icons.playlist_add),
                            onPressed: () {
                              var saveDialog = SavePresetDialog(
                                  device: device,
                                  confirmColor: Theme.of(context).hintColor);
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
          ),
          if (layout == EditorLayoutMode.expand)
            Flexible(child: ChannelSelector(device: device))
          else
            ChannelSelector(device: device)
        ],
      ),
    );
  }
}
