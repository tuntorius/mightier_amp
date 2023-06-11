import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qr_utils/qr_utils.dart';

import '../../../../bluetooth/NuxDeviceControl.dart';
import '../../../popups/alertDialogs.dart';
import '../../../popups/exportQRCode.dart';

class PresetListMethods {
  static void exportQR(Map<String, dynamic> preset, BuildContext context) {
    var dev = NuxDeviceControl.instance().getDeviceFromId(preset["product_id"]);
    var pVersion = preset["version"] ?? 0;
    if (dev != null) {
      int? originalVersion;
      if (dev.productVersion != pVersion) {
        originalVersion = dev.productVersion;
        dev.setFirmwareVersionByIndex(pVersion);
      }
      var qr = dev.jsonToQR(preset);
      if (qr != null) {
        QrUtils.generateQR(qr).then((Image img) {
          var qrExport = QRExportDialog(img, preset["name"], dev);
          showDialog(
            context: context,
            builder: (BuildContext context) => qrExport.buildDialog(context),
          ).then((value) {
            if (originalVersion != null) {
              dev.setFirmwareVersionByIndex(originalVersion);
            }
          });
        });
      }
    }
  }

  static void saveFileIos(String name, String data, BuildContext context) {
    AlertDialogs.showInputDialog(context,
        title: "Backup",
        description: "Enter backup name:",
        cancelButton: "Cancel",
        confirmButton: "Backup",
        value: name,
        validation: (String newName) {
          RegExp regex = RegExp(r'[<>:"/\\|?*\x00-\x1F\x7F]+');
          return !regex.hasMatch(newName);
        },
        validationErrorMessage: "The file name contains invalid characters.",
        confirmColor: Theme.of(context).hintColor,
        onConfirm: (newName) async {
          await FilePicker().saveFile(newName, data);
        });
  }
}
