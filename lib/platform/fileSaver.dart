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
    return Future.error("Error saving file");
  }
}

Future<String> openFileString(String mime) async {
  const platform =
      MethodChannel("com.msvcode.filesaver/files"); //unique channel identifier
  try {
    final result = await platform.invokeMethod(
        "openFile", {"mime": mime, "byte_array": false}); //name in native code

    return result;
  } on PlatformException catch (e) {
    //fails native call
    //handle error
    return Future.error("Can't open file");
  }
}

Future<List<int>> openFile(String mime) async {
  const platform =
      MethodChannel("com.msvcode.filesaver/files"); //unique channel identifier
  try {
    final result = await platform.invokeMethod(
        "openFile", {"mime": mime, "byte_array": true}); //name in native code

    return result;
  } on PlatformException catch (e) {
    //fails native call
    //handle error
    return Future.error("Can't open file");
  }
}
