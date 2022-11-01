// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AlertDialogs {
  static TextEditingController? nameCtrl;

  static final _inputFormKey = GlobalKey<FormState>();

  static showInfoDialog(BuildContext context,
      {required String title,
      required String description,
      required String confirmButton,
      Function()? onConfirm,
      Color? confirmColor}) {
    // set up the buttons
    Widget continueButton = TextButton(
      child: Text(
        confirmButton,
        style: TextStyle(color: confirmColor),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm?.call();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showConfirmDialog(BuildContext context,
      {required String title,
      required String description,
      required String confirmButton,
      required String cancelButton,
      Function(bool)? onConfirm,
      Color? confirmColor}) {
    // set up the buttons
    Widget cancel = TextButton(
      child: Text(cancelButton),
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm?.call(false);
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        confirmButton,
        style: TextStyle(color: confirmColor),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm?.call(true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        cancel,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showInputDialog(BuildContext context,
      {required String title,
      required String description,
      String confirmButton = "OK",
      String cancelButton = "Cancel",
      required String value,
      bool selectAll = false,
      Function(String)? onConfirm,
      bool Function(String)? validation,
      TextInputType? keyboardType,
      String validationErrorMessage = "",
      Color? confirmColor}) {
    final nameCtrl = TextEditingController(text: value);

    if (selectAll)
      nameCtrl.selection =
          TextSelection(baseOffset: 0, extentOffset: value.length);
    // set up the buttons
    Widget cancel = TextButton(
      child: Text(cancelButton),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        confirmButton,
        style: TextStyle(color: confirmColor),
      ),
      onPressed: () {
        if (_inputFormKey.currentState!.validate()) {
          Navigator.of(context).pop();
          onConfirm?.call(nameCtrl.text);
        } else {
          //error
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _inputFormKey,
        child: TextFormField(
          decoration: InputDecoration(labelText: description),
          controller: nameCtrl,
          autofocus: true,
          keyboardType: keyboardType,
          //style: TextStyle(color: Colors.black),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter name';
            }
            if (validation != null && !validation(value)) {
              return validationErrorMessage;
            }
            return null;
          },
        ),
      ),
      actions: [
        cancel,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showOptionDialog(BuildContext context,
      {required String title,
      required String confirmButton,
      required String cancelButton,
      required List<String> options,
      required int value,
      required Function(bool, int) onConfirm,
      Color? confirmColor}) {
    int selected = value;
    // set up the buttons
    return StatefulBuilder(builder: (context, setState) {
      Widget continueButton = TextButton(
        child: Text(
          confirmButton,
          style: TextStyle(color: confirmColor),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onConfirm.call(true, selected);
        },
      );
      Widget closeButton = TextButton(
        child: Text(cancelButton),
        onPressed: () {
          Navigator.of(context).pop();
          onConfirm.call(false, 0);
        },
      );
      var widgets = <RadioListTile>[];
      for (int i = 0; i < options.length; i++) {
        widgets.add(
          RadioListTile(
            value: i,
            groupValue: selected,
            title: Text(options[i]),
            onChanged: (currentUser) {
              setState(() {
                selected = i;
              });
            },
            selected: selected == i,
            activeColor: Theme.of(context).hintColor,
          ),
        );
      }

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text(title),
        content: Container(
          width: double.maxFinite,
          child: ListTileTheme(
            iconColor: Colors.white,
            child: ListView(
              shrinkWrap: true,
              children: widgets,
            ),
          ),
        ),
        actions: [
          closeButton,
          continueButton,
        ],
      );

      return alert;
    });
  }

  static showLocationPrompt(
      BuildContext context, bool skipPrompt, Function? onPromptFinished) {
    if (skipPrompt) {
      _askLocation(onPromptFinished);
      return;
    }
    AlertDialogs.showConfirmDialog(context,
        title: "Location is required for Bluetooth",
        description:
            "Please, consider granting location permission. It is required for Bluetooth connection to work.",
        confirmButton: "Grant",
        cancelButton: "Keep denying", onConfirm: (val) {
      if (val) _askLocation(onPromptFinished);
    });
  }

  static _askLocation(Function? onPromptFinished) async {
    var status = await Permission.location.request();
    if (status.isPermanentlyDenied) await openAppSettings();
    onPromptFinished?.call();
  }
}
