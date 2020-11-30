import 'package:flutter/material.dart';

class AlertDialogs {
  static TextEditingController nameCtrl;

  static showInfoDialog(BuildContext context,
      {String title,
      String description,
      String confirmButton,
      Function(bool) onConfirm,
      Color confirmColor}) {
    // set up the buttons
    Widget continueButton = FlatButton(
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
    Widget cancel = FlatButton(
      child: Text(cancelButton),
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm?.call(false);
      },
    );
    Widget continueButton = FlatButton(
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
    Widget cancel = FlatButton(
      child: Text(cancelButton),
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm?.call(false, "");
      },
    );
    Widget continueButton = FlatButton(
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
}
