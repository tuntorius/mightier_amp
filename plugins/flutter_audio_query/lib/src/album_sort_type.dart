part of flutter_audio_query;

/// Enum that define values used to sort Albums.
enum AlbumSortType {
  /// Returns the albums using the platform specific ordering mechanism.
  /// In android platform will return albms in alphabetical order
  /// using album [title] property as sort param.
  DEFAULT,

  /// Returns the albums sorted in alphabetic order using the album [artist]
  /// property as sort parameter
  ALPHABETIC_ARTIST_NAME,

  /// Returns the albums sorted using [numberOfSongs] property as sort
  /// parameter. In This case the albums with greater number of songs will
  /// come first.
  MORE_SONGS_NUMBER_FIRST,

  /// Returns the albums sorted using [numberOfSongs] property as sort
  /// parameter. In This case the albums with smaller number of songs will
  /// come first.
  LESS_SONGS_NUMBER_FIRST,

  /// Returns the albums sorted using [lastYear] property as sort param.
  /// In this case the albums with more recent year value will come first.
  MOST_RECENT_YEAR,

  /// Returns the albums sorted using [lastYear] property as sort param.
  /// In this case the albums with more oldest year value will come first.
  OLDEST_YEAR,

  /// Return the songs sorted by Ids using the same order that IDs appears
  /// in IDs query argument list.
  CURRENT_IDs_ORDER
}
