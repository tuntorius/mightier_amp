import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum PresetQRError { Ok, UnsupportedFormat, WrongDevice, WrongFWVersion }

class QrUtils {
  static const nuxQRPrefix = "nux://MightyAmp:";
  static const QRMessages = [
    "Imported Successfully",
    "Error! Unsupported Format!",
    "Error! This preset is for different amp model!",
    "Error! This preset is for different firmware version!"
  ];
  static const MethodChannel _channel =
      const MethodChannel('com.aeologic.adhoc.qr_utils');

  // Returns Future<String> after scanning QR code
  static Future<String?> get scanQR async {
    final String? qrContent = await _channel.invokeMethod('scanQR');
    return qrContent;
  }

  static Future<String?> scanImageFromData(List<int> data) async {
    final String? qrContent =
        await _channel.invokeMethod('scanImage', {"data": data});
    return qrContent;
  }

  static Future<String?> scanImage() async {
    final String? qrContent = await _channel.invokeMethod('scanImage');
    return qrContent;
  }

  // Returns Future<Image> after generating QR Image
  static Future<Image> generateQR(String content) async {
    final Uint8List uInt8list =
        await _channel.invokeMethod('generateQR', {"content": content});
    return imageFromUInt8List(uInt8list);
  }

  // Returns Future<Image> after generating QR Image
  static Future<Uint8List> generateQRByteArray(String content) async {
    final Uint8List uInt8list =
        await _channel.invokeMethod('generateQR', {"content": content});
    return uInt8list;
  }

  // Returns Image from base64
  static Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  // Returns Uint8List from base64
  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  // Returns String from Uint8List
  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  // Returns Image from Uint8List
  static Image imageFromUInt8List(Uint8List data) {
    return Image.memory(data);
  }
}
