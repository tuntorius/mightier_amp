abstract class PresetStorageListener {
  void onPresetCreated(Map<String, dynamic> preset);
  void onPresetUpdated(Map<String, dynamic> preset);
  void onPresetDeleted(String uuid);
  void onCategoryReordered(int from, int to);
}
