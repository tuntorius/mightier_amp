import 'file_picker_platform_interface.dart';

class FilePicker {
  Future<String?> readFile() {
    return FilePickerPlatform.instance.readFile();
  }

  Future saveFile(String fileName, String fileContents) {
    return FilePickerPlatform.instance.saveFile(fileName, fileContents);
  }
}
