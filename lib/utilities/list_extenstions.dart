extension ListStringExtension on List<String> {
  bool containsPartial(String partialString) {
    for (var str in this) {
      if (partialString.contains(str)) {
        return true;
      }
    }
    return false;
  }
}
