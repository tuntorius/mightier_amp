import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'file_picker_method_channel.dart';

abstract class FilePickerPlatform extends PlatformInterface {
  /// Constructs a FilePickerPlatform.
  FilePickerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FilePickerPlatform _instance = MethodChannelFilePicker();

  /// The default instance of [FilePickerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFilePicker].
  static FilePickerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FilePickerPlatform] when
  /// they register themselves.
  static set instance(FilePickerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> readFile() {
    throw UnimplementedError('readFile() has not been implemented.');
  }

  Future saveFile(String fileName, String fileContents) {
    throw UnimplementedError('saveFile() has not been implemented.');
  }
}
