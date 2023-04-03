import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'file_picker_platform_interface.dart';

/// An implementation of [FilePickerPlatform] that uses method channels.
class MethodChannelFilePicker extends FilePickerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('file_picker');

  @override
  Future<String?> readFile() async {
    final data = await methodChannel.invokeMethod<String>('readFile');
    return data;
  }

  @override
  Future saveFile(String fileContents) async {
    final version = await methodChannel
        .invokeMethod<String>('saveToFile', {'fileContents': fileContents});
    return version;
  }
}
