import 'file_picker_platform_interface.dart';

class FilePicker {
  Future<String?> readFile() {
    return FilePickerPlatform.instance.readFile();
  }

  Future saveFile(String fileContents) {
    return FilePickerPlatform.instance.saveFile(fileContents);
  }
}
