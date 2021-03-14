// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';

class AlertDialogs {
  static TextEditingController nameCtrl;

  static showInfoDialog(BuildContext context,
      {String title,
      String description,
      String confirmButton,
      Function() onConfirm,
      Color confirmColor}) {
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
      {String title,
      String description,
      String confirmButton,
      String cancelButton,
      Function(bool) onConfirm,
      Color confirmColor}) {
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
      {String title,
      String description,
      String confirmButton,
      String cancelButton,
      String value,
      Function(bool, String) onConfirm,
      Color confirmColor}) {
    nameCtrl = TextEditingController(text: value);
    // set up the buttons
    Widget cancel = TextButton(
      child: Text(cancelButton),
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm?.call(false, "");
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        confirmButton,
        style: TextStyle(color: confirmColor),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm?.call(true, nameCtrl.text);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Form(
        child: TextFormField(
          decoration: InputDecoration(labelText: description),
          controller: nameCtrl,
          style: TextStyle(color: Colors.black),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter preset name';
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
      {String title,
      String confirmButton,
      String cancelButton,
      List<String> options,
      int value,
      Function(bool, int) onConfirm,
      Color confirmColor}) {
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
          onConfirm?.call(true, selected);
        },
      );
      Widget closeButton = TextButton(
        child: Text(cancelButton),
        onPressed: () {
          Navigator.of(context).pop();
          onConfirm?.call(false, 0);
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
            activeColor: Colors.blue,
          ),
        );
      }

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text(title),
        content: ListTileTheme(
          textColor: Colors.black,
          child: ListView(
            shrinkWrap: true,
            children: widgets,
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
}
