// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../widgets/scrollParent.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import '../../bluetooth/devices/presets/presetsStorage.dart';
import 'alertDialogs.dart';

class SavePresetDialog {
  static final _formKey = GlobalKey<FormState>();
  final categoryCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final parentScroll = ScrollController();
  final NuxDevice device;
  final Color? confirmColor;

  SavePresetDialog({required this.device, this.confirmColor}) {
    categoryCtrl.text = device.presetCategory;
    nameCtrl.text = device.presetName;
  }

  Widget buildDialog(NuxDevice device, BuildContext context) {
    List<String> categories = PresetsStorage().getCategories();
    var preset = device.presetToJson();
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final _height = MediaQuery.of(context).size.height * 0.25;
    final node = FocusScope.of(context);

    return StatefulBuilder(
      builder: (context, setState) {
        var dialog = AlertDialog(
          title: const Text('Save preset'),
          content: Container(
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
                      height: _height,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ScrollParent(
                        controller: parentScroll,
                        child: ListTileTheme(
                          child: ListView.builder(
                            physics: ClampingScrollPhysics(),
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
                      decoration: InputDecoration(labelText: "Category"),
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
                      decoration: InputDecoration(labelText: "Name"),
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
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  //save and pop

                  if (PresetsStorage().findPreset(
                          nameCtrl.value.text, categoryCtrl.value.text) !=
                      null) {
                    //overwriting preset
                    AlertDialogs.showConfirmDialog(context,
                        title: "Confirm",
                        description: "Overwrite existing preset?",
                        cancelButton: "Cancel",
                        confirmButton: "Overwrite",
                        confirmColor: Colors.red, onConfirm: (overwrite) {
                      if (overwrite) savePreset(preset, context);
                    });
                  } else {
                    savePreset(preset, context);
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

        if (isPortrait)
          return dialog;
        else
          return SingleChildScrollView(
            child: dialog,
          );
      },
    );
  }

  savePreset(preset, context) {
    device.presetName = nameCtrl.value.text;
    device.presetCategory = categoryCtrl.value.text;

    Navigator.of(context).pop();

    PresetsStorage()
        .savePreset(preset, device.presetName, device.presetCategory);
  }
}
