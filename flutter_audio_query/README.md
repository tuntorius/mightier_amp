# Flutter Audio Query

A Flutter plugin, Android only at this moment, that allows you query for audio metadata info about artists, albums, songs audio files and genres available on device storage. All work is made using Android native [MediaStore API](https://developer.android.com/reference/android/provider/MediaStore) with [ContentResolver API](https://developer.android.com/reference/android/content/ContentResolver) and query methods run in background thread. AndroidX support it's OK!

Note: This plugin is under development, Works in Android devices only and some APIs are not available yet. Feedback, pull request, bug reports and suggestions are all welcome!

Feel free to help!

# Example app included

![](https://i.ibb.co/ypbxFLz/artists-anim.gif) |
![](https://i.ibb.co/0c8MpDZ/albums-anim.gif) |
![](https://i.ibb.co/CmYV3qR/genres-anim.gif) |
![](https://i.ibb.co/64qtVZC/songs-anim.gif) |
![](https://i.ibb.co/86VzvyT/playlists-anim.gif)


## Features
* Android permissions READ_EXTERNAL_STORAGE and READ_EXTERNAL_STORAGE built-in
* Get all artists audio info available on device storage
* Get artists available from a specific genre
* Search for artists matching a name
* Artist comes with some album Artwork cover if available
* Get all albums info available on device storage
* Get albums available from a specific artist
* Get albums available from a specific genre
* Search albums matching a name
* Album artwork included if available
* Get songs all songs available on device storage
* Get songs from a specific album
* Songs already comes with album artwork cover if available
* Get availables genre.
* Get all playlists available
* Create new playlists
* Remove playlist
* Add songs to playlist
* Remove song from playlist
* Multiple sort types for Artist, Album, Song, Genre, Playlist.

## TO DO
* Make this basic implementation for iOS.
* Allow change playlist songs order
* Streams support.
* Improvements in background tasks.
* More tests and probably bug fixes.

## Usage
To use this plugin, add `flutter_audio_query` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
  dependencies:
    flutter_audio_query: "^0.3.5+6"
```

## API

### FlutterAudioQuery
To get get audio files metadata info you just need `FlutterAudioQuery` object instance.

```dart
///you need include this file only.
import 'package:flutter_audio_query/flutter_audio_query.dart';
/// create a FlutterAudioQuery instance.
final FlutterAudioQuery audioQuery = FlutterAudioQuery();
```
#### Getting all artist available on device storage:
```dart
List<ArtistInfo> artists = await audioQuery.getArtists(); // returns all artists available

artists.forEach( (artist){
      print(artist); /// prints all artist property values
    } );
```
#### Getting albums data:
```dart
 /// getting all albums available on device storage
 List<AlbumInfo> albumList = await audioQuery.getAlbums();

/// getting all albums available from a specific artist
List<AlbumInfo> albums = await audioQuery.getAlbumsFromArtist(artist: artist.name);
    albums.forEach( (artistAlbum) {
      print(artistAlbum); //print all album property values
    });
```

#### Getting artwork on Android >= Q:
Since Android API level 29 ALBUM_ART constant is deprecated and plus
scoped storage approach we can't load artwork from absolute image path.
So if your app is running over Android API >= 29 you will get all artwork fields with null. To fetch images on these API levels you can use getArwork method.
 
```dart
 /// detecting, loading and displaying an artist artwork.
 
 ArtistInfo artist // assuming a non null instance

 // check if artistArtPath isn't available.

 (artist.artistArtPath == null)

    ? FutureBuilder<Uint8List>(
      future: audioQuery.getArtwork(

        type: ResourceType.ARTIST, id: artist.id),
        builder: (_, snapshot) {
          if (snapshot.data == null)
            return Container(
              height: 250.0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
            
            return CardItemWidget(
              height: 250.0,
              title: artist.name,
              subtitle: "Number of Albums: ${artist.numberOfAlbums}",
              infoText: "Number of Songs: ${artist.numberOfTracks}",
              // The image bytes
              // You can use Image.memory widget constructor 
              // or MemoryImage image provider class to load image from bytes
              // or a different approach.
              rawImage: snapshot.data,
            );
          }) :
          // or you can load image from File path if available.
          Image.file( File( artist.artistArtPath ) )

```


### Getting genre data
```dart
/// getting all genres available
 List<GenreInfo> genreList = audioQuery.getGenres();

 genreList.foreach( (genre){
   /// getting all artists available from specific genre.
   await audioQuery.getArtistsFromGenre(genre: genre.name);

   /// getting all albums which appears on genre [genre].
   await audioQuery.getAlbumsFromGenre(genre: genre.name);

   /// getting all songs which appears on genre [genre]
   await audioQuery.getSongsFromGenre(genre: genre.name);
 } );
 ```
 ### Getting songs data
 ```dart
 /// getting all songs available on device storage
List<SongInfo> songs = await audioQuery.getSongs();

albumList.foreach( (album){
  /// getting songs from specific album
  audioQuery.getSongsFromAlbum(album: album.name);
 } );
```

### Getting playlist data
```dart
    /// getting all playlist available
    List<PlaylistInfo> playlist = await audioQuery.getPlaylists();

    /// Getting playlist songs
    List<SongInfo> songs = await audioQuery.getSongsFromPlaylist(playlist: playlist[0]);

    /// adding songs into a specific playlist
    PlaylistInfo updatedPlaylist = await playlist[0].addSong(song: songs[2] );

    //removing song from a specific playlist
    updatedPlaylist = await updatedPlaylist.removeSong(song: songs[2]);
```

### Sorting queries
You can also define a sort query constraint to get the data already sorted using sort enums.ArtistSortType, AlbumSortType, SongSortType, GenreSortType, PlaylistSortType.

```dart
    /// Getting albums sorted by most recent year first
    audioQuery.getAlbums(sortType: AlbumSortType.MOST_RECENT_YEAR )

    /// getting artists sorted by number of songs
    audioQuery.getArtits(sortType: ArtistSortType.MORE_TRACKS_NUMBER_FIRST);
    /// and more...
```

### Searching
You can search using search methods.

```dart
    ///searching for albums that title starts with 'a'
    List<AlbumInfo> albums = await audioQuery.searchAlbums(query "a");

    /// searching for songs that title starts with 'la'
    List<SongInfo> songs = await audioQuery.searchSongs(query: "la");
```
## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT LICENSE](https://opensource.org/licenses/MIT)
