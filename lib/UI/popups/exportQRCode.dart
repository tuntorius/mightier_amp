import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/platform/fileSaver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

class QRExportDialog {
  final Image qrImage;
  final String presetName;
  QRExportDialog(this.qrImage, this.presetName);

  Widget buildDialog(BuildContext context) {
    ScreenshotController screenshotController = ScreenshotController();
    return AlertDialog(
        title: const Text("Export QR Code"),
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Screenshot(
              controller: screenshotController,
              child: ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        NuxDeviceControl().device.getProductNameVersion(
                            NuxDeviceControl().device.productVersion),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      qrImage,
                      Text(presetName,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                    onPressed: () async {
                      //var path = '$directory';
                      //fileSave
                      var data = await screenshotController.capture();
                      if (data != null) {
                        saveFile("image/png", presetName, data);
                      }
                    },
                    icon: Icon(Icons.save_alt),
                    label: Text("Save")),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                    onPressed: () async {
                      final storageDirectory =
                          await getExternalStorageDirectory();

                      var tracksPath =
                          path.join(storageDirectory?.path ?? "", "");

                      //var path = '$directory';

                      await screenshotController.captureAndSave(tracksPath,
                          fileName: "preset.png");

                      Share.shareFiles(['$tracksPath/preset.png'],
                          text: 'QR Code');
                    },
                    icon: Icon(Icons.share),
                    label: Text("Share"))
              ],
            ),
          ],
        ));
  }
}
