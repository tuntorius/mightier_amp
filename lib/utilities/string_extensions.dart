extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      toLowerCase().contains(secondString.toLowerCase());
}
