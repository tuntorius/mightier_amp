part of flutter_audio_query;

/// ArtistInfo class holds all information about a specific artist.
class ArtistInfo extends DataModel {
  /// ArtistInfo  private constructor
  ArtistInfo._(Map<dynamic, dynamic> map) : super._(map);

  /// Returns the name of artist
  String get name => _data['artist'];

  /// Returns the number of tracks of current artist
  String get numberOfTracks => _data['number_of_tracks'];

  /// Returns the number of albums of current artist
  String get numberOfAlbums => _data['number_of_albums'];

  /// Returns the path from an image file that can be used as
  /// artist art or null if there is no one. The image file
  /// is the first artist album art work founded.
  String get artistArtPath => _data['artist_cover'];

  @override
  String toString() {
    return "\nId: $id\nName: $name\nNumber of tracks: $numberOfTracks\n"
        "Number of albums: $numberOfAlbums\nArt path: $artistArtPath";
  }
}
