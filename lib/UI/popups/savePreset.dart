// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import '../widgets/scrollParent.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../platform/presetsStorage.dart';
import 'alertDialogs.dart';

class SavePresetDialog {
  static final _formKey = GlobalKey<FormState>();
  final categoryCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final parentScroll = ScrollController();
  final NuxDevice device;
  final Color? confirmColor;
  late NuxDeviceControl deviceControl;

  SavePresetDialog({required this.device, this.confirmColor}) {
    deviceControl = device.deviceControl;
    categoryCtrl.text = deviceControl.presetCategory;
    nameCtrl.text = deviceControl.presetName;
  }

  Widget buildDialog(NuxDevice device, BuildContext context) {
    List<String> categories = PresetsStorage().getCategories();

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final height = MediaQuery.of(context).size.height * 0.25;
    final node = FocusScope.of(context);

    return StatefulBuilder(
      builder: (context, setState) {
        var dialog = AlertDialog(
          title: const Text('Save preset'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              reverse: true,
              controller: parentScroll,
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  children: [
                    Text("Categories",
                        style: TextStyle(color: Theme.of(context).hintColor)),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ScrollParent(
                        controller: parentScroll,
                        child: ListTileTheme(
                          child: ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(categories[index]),
                                onTap: () {
                                  setState(() {
                                    categoryCtrl.text = categories[index];
                                  });
                                },
                              );
                            },
                            itemCount: categories.length,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Category"),
                      controller: categoryCtrl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter preset category';
                        }
                        return null;
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Name"),
                      controller: nameCtrl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter preset name';
                        }
                        return null;
                      },
                      onEditingComplete: () => node.unfocus(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  //save and pop

                  if (PresetsStorage().presetExists(
                      nameCtrl.value.text, categoryCtrl.value.text)) {
                    //overwriting preset
                    AlertDialogs.showConfirmDialog(context,
                        title: "Confirm",
                        description: "Overwrite existing preset?",
                        cancelButton: "Cancel",
                        confirmButton: "Overwrite",
                        confirmColor: Colors.red, onConfirm: (overwrite) {
                      if (overwrite) {
                        savePreset(context);
                        Navigator.of(context).pop();
                      }
                    });
                  } else {
                    savePreset(context);
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: confirmColor),
              ),
            ),
          ],
        );

        if (isPortrait) {
          return dialog;
        } else {
          return SingleChildScrollView(
            child: dialog,
          );
        }
      },
    );
  }

  savePreset(context) {
    var preset = device.presetToJson();
    deviceControl.presetName = nameCtrl.value.text;
    deviceControl.presetCategory = categoryCtrl.value.text;

    String uuid = PresetsStorage().savePreset(
        preset, deviceControl.presetName, deviceControl.presetCategory);

    deviceControl.presetUUID = uuid;
  }
}
