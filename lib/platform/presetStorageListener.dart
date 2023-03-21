abstract class PresetStorageListener {
  void onPresetCreated(Map<String, dynamic> preset);
  void onPresetUpdated(Map<String, dynamic> preset);
  void onPresetDeleted(String uuid);
}
