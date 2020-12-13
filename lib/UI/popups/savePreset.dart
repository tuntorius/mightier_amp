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

    final _height = MediaQuery.of(context).size.height * 0.25;
    final node = FocusScope.of(context);

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Save preset'),
          content: SingleChildScrollView(
            reverse: true,
            controller: parentScroll,
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
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
                      child: ListTileTheme(
                        textColor: Colors.black,
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
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter preset category';
                      }
                      return null;
                    },
                    onEditingComplete: () => node.nextFocus(),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Name"),
                    controller: nameCtrl,
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value.isEmpty) {
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
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
              textColor: Theme.of(context).primaryColor,
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
