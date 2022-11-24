part of flutter_audio_query;

/// Enum that define values used to sort genres.
enum GenreSortType {
  /// Returns the genre using the platform specific ordering mechanism.
  /// In android platform will return genre in alphabetical order
  /// using genre [name] property as sort param
  DEFAULT,
}
