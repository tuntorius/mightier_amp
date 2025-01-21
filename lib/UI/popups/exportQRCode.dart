import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/platform/fileSaver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

import '../../bluetooth/devices/NuxDevice.dart';
import '../../platform/platformUtils.dart';

class QRExportDialog {
  final Image qrImage;
  final String presetName;
  final NuxDevice device;
  QRExportDialog(this.qrImage, this.presetName, this.device);

  Widget buildDialog(BuildContext context) {
    ScreenshotController screenshotController = ScreenshotController();
    return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                icon: Icon(
                  Icons.adaptive.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop()),
            const Text("Share QR Code", style: TextStyle(color: Colors.white)),
          ],
        ),
        insetPadding: EdgeInsets.zero,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        content: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Screenshot(
                controller: screenshotController,
                child: ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          device.getProductNameForQR(device.productVersion),
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        qrImage,
                        Text(presetName,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!PlatformUtils.isIOS)
                    ElevatedButton.icon(
                        onPressed: () async {
                          //var path = '$directory';
                          //fileSave
                          var data = await screenshotController.capture();
                          if (data != null) {
                            saveFile("image/png", presetName, data);
                          }
                        },
                        icon: const Icon(
                          Icons.save_alt,
                          color: Colors.white,
                        ),
                        label: const Text("Save")),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        Directory? storageDirectory;
                        if (PlatformUtils.isAndroid) {
                          storageDirectory =
                              await getExternalStorageDirectory();
                        } else if (PlatformUtils.isIOS) {
                          storageDirectory =
                              await getApplicationDocumentsDirectory();
                        }
                        var tracksPath =
                            path.join(storageDirectory?.path ?? "", "");

                        //var path = '$directory';

                        await screenshotController.captureAndSave(tracksPath,
                            fileName: "preset.png");

                        Share.shareXFiles([XFile('$tracksPath/preset.png')],
                            text: 'QR Code',
                            sharePositionOrigin: Rect.fromCenter(
                                center: const Offset(100, 100),
                                width: 100,
                                height: 100));
                      },
                      icon: Icon(
                        Icons.adaptive.share,
                        color: Colors.white,
                      ),
                      label: const Text("Share"))
                ],
              ),
            ],
          ),
        ));
  }
}
