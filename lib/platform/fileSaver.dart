import 'package:flutter/services.dart';

Future<String> saveFile(String mime, String name, String data) async {
  const platform =
      MethodChannel("com.msvcode.filesaver/files"); //unique channel identifier
  try {
    final result = await platform.invokeMethod("saveFile", {
      "mime": mime,
      "name": name,
      "data": data,
    }); //name in native code

    return result;
  } on PlatformException catch (e) {
    //fails native call
    //handle error
    return null;
  }
}

Future<String> openFile(String mime) async {
  const platform =
      MethodChannel("com.msvcode.filesaver/files"); //unique channel identifier
  try {
    final result = await platform
        .invokeMethod("openFile", {"mime": mime}); //name in native code

    return result;
  } on PlatformException catch (e) {
    //fails native call
    //handle error
    return null;
  }
}
