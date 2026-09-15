import "dart:io" as io;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class PlatformUtils {
  static get isMobile {
    return !kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS);
  }

  static get isWeb => kIsWeb;

  static get isAndroid => !kIsWeb && io.Platform.isAndroid;
  static get isIOS => !kIsWeb && io.Platform.isIOS;

  static get isWindows => !kIsWeb && io.Platform.isWindows;
  static get isLinux => !kIsWeb && io.Platform.isLinux;
  static get isMacOS => !kIsWeb && io.Platform.isMacOS;

  static Future<io.Directory?> getAppDataDirectory() async {
    if (PlatformUtils.isAndroid) {
      return getExternalStorageDirectory();
    } else if (PlatformUtils.isIOS) {
      return getApplicationDocumentsDirectory();
    } else if (PlatformUtils.isMacOS) {
      return getApplicationSupportDirectory();
    }
    return Future.error("getAppDataDirectory(): Platform not supported");
  }
}
