// (c) 2020 Dian Iliev (Tuntorius)
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
  NuxDevice device;

  SavePresetDialog({@required this.device}) {
    categoryCtrl.text = device.presetCategory ?? "";
    nameCtrl.text = device.presetName ?? "";
  }

  Widget buildDialog(NuxDevice device, BuildContext context) {
    List<String> categories = PresetsStorage().getCategories();
    var preset = device.presetToJson();

    final _height = MediaQuery.of(context).size.height * 0.35;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Save preset'),
          content: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: SingleChildScrollView(
              controller: parentScroll,
              child: Column(
                //mainAxisSize: MainAxisSize.max,
                //crossAxisAlignment: CrossAxisAlignment.start,
                //reverse: true,
                children: [
                  Text("Categories",
                      style: TextStyle(color: Theme.of(context).hintColor)),
                  Container(
                    height: _height,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]),
                    ),
                    child: ScrollParent(
                      controller: parentScroll,
                      child: ListView.builder(
                        shrinkWrap: true,
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
                  TextFormField(
                    decoration: InputDecoration(labelText: "Category"),
                    controller: categoryCtrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter preset category';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Name"),
                    controller: nameCtrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter preset name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
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
              textColor: Theme.of(context).primaryColor,
              child: Text('Save'),
            ),
          ],
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
