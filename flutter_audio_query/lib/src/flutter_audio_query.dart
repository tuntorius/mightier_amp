//The MIT License
//
//Copyright (C) <2019>  <Marcos Antonio Boaventura Feitoza> <scavenger.gnu@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

part of flutter_audio_query;

/// Playlist enum that define values to describe what kind of method
/// it's.
enum PlayListMethodType {
  /// Value used to describe READ methods.
  READ,

  /// Value used to describe WRITE methods.
  WRITE
}

enum ResourceType { ARTIST, ALBUM, SONG }

/// This class provides an interface for access audio data info.
class FlutterAudioQuery {
  static const String _CHANNEL_NAME =
      "boaventura.com.devel.br.flutteraudioquery";
  static const MethodChannel channel = const MethodChannel(_CHANNEL_NAME);

  /// key used for delegate type param.
  static const String SOURCE_KEY = "source";
  static const String QUERY_KEY = "query";
  static const String SOURCE_ARTIST = 'artist';
  static const String SOURCE_ALBUM = 'album';
  static const String SOURCE_SONGS = 'song';
  static const String SOURCE_GENRE = 'genre';
  static const String SOURCE_ARTWORK = 'artwork';
  static const String SORT_TYPE = "sort_type";
  static const String PLAYLIST_METHOD_TYPE = "method_type";
  static const String SOURCE_PLAYLIST = 'playlist';

  /// This method returns all artists info available on device storage
  Future<List<ArtistInfo>> getArtists(
      {ArtistSortType sortType = ArtistSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod('getArtists', {
      SOURCE_KEY: SOURCE_ARTIST,
      SORT_TYPE: sortType.index,
    });
    return _parseArtistDataList(dataList);
  }

  /// Fetch artist by IDs.
  /// To return data sorted in the same order that ids appears on [ids] list
  /// parameter use [sortType] param with ArtistSortType.CURRENT_IDs_ORDER value.
  Future<List<ArtistInfo>> getArtistsById(
      {required final List<String> ids,
      ArtistSortType sortType = ArtistSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("getArtistsById", {
      SOURCE_KEY: SOURCE_ARTIST,
      'artist_ids': ids,
      SORT_TYPE: sortType.index,
    });

    return _parseArtistDataList(dataList);
  }

  ///This method returns a list with all artists that appears on specific genre.
  ///
  /// [genre] Genre name that we want fetch artists. Must not be null
  Future<List<ArtistInfo>> getArtistsFromGenre(
      {required final String genre,
      ArtistSortType sortType = ArtistSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod('getArtistsFromGenre', {
      SOURCE_KEY: SOURCE_ARTIST,
      'genre_name': genre,
      SORT_TYPE: sortType.index,
    });
    return _parseArtistDataList(dataList);
  }

  /// This method search for artists which [name] property starts or match with [query] param.
  /// It returns a List of [ArtistInfo] instances or an empty list if no results.
  ///
  /// [query] String used to make the search
  Future<List<ArtistInfo>> searchArtists(
      {required String query,
      ArtistSortType sortType = ArtistSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("searchArtistsByName", {
      SOURCE_KEY: SOURCE_ARTIST,
      SORT_TYPE: sortType.index,
      QUERY_KEY: query
    });
    return _parseArtistDataList(dataList);
  }

  /// This method returns a list of albums with all albums available in device storage.
  /// [sortType] The type sorting.The default type is AlbumSortType.DEFAULT
  Future<List<AlbumInfo>> getAlbums(
      {AlbumSortType sortType = AlbumSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod('getAlbums', {
      SOURCE_KEY: SOURCE_ALBUM,
      SORT_TYPE: sortType.index,
    });
    return _parseAlbumDataList(dataList);
  }

  /// Fetch album by IDs.
  /// To return data sorted in the same order that ids appears on [ids] list
  /// parameter use [sortType] param with AlbumSortType.CURRENT_IDs_ORDER value.
  Future<List<AlbumInfo>> getAlbumsById(
      {required final List<String> ids,
      AlbumSortType sortType = AlbumSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("getAlbumsById", {
      SOURCE_KEY: SOURCE_ALBUM,
      SORT_TYPE: sortType.index,
      "album_ids": ids,
    });

    return _parseAlbumDataList(dataList);
  }

  ///This method returns a list with all albums that appears on specific [genre]
  ///
  /// [genre] Genre name that we want fetch albums. Genre must not be null.
  Future<List<AlbumInfo>> getAlbumsFromGenre(
      {required final String genre,
      AlbumSortType sortType = AlbumSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod('getAlbumsFromGenre', {
      SOURCE_KEY: SOURCE_ALBUM,
      'genre_name': genre,
      SORT_TYPE: sortType.index,
    });
    return _parseAlbumDataList(dataList);
  }

  /// This method returns all albums info from a specific artist
  /// using his name.
  /// [artist] Artist name must be non null.
  Future<List<AlbumInfo>> getAlbumsFromArtist(
      {required final String artist,
      AlbumSortType sortType = AlbumSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod('getAlbumsFromArtist', {
      'artist': artist,
      SOURCE_KEY: SOURCE_ALBUM,
      SORT_TYPE: sortType.index,
    });
    return _parseAlbumDataList(dataList);
  }

  /// This method search for Albums which album [title] property starts or match with [query] param.
  /// It returns a List of [AlbumInfo] instances or an empty list if no results.
  ///
  /// [query] String used to make the search
  Future<List<AlbumInfo>> searchAlbums(
      {required final String query,
      AlbumSortType sortType = AlbumSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod('searchAlbums', {
      SOURCE_KEY: SOURCE_ALBUM,
      SORT_TYPE: sortType.index,
      QUERY_KEY: query,
    });
    return _parseAlbumDataList(dataList);
  }

  /// This method returns a list with all songs available on device storage.
  Future<List<SongInfo>> getSongs(
      {SongSortType sortType = SongSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("getSongs", {
      SOURCE_KEY: SOURCE_SONGS,
      SORT_TYPE: sortType.index,
    });
    return _parseSongDataList(dataList);
  }

  /// This method returns list with  all songs info from a specific artist.
  /// using his name.
  /// [artistId] Artist id must be non null
  Future<List<SongInfo>> getSongsFromArtist(
      {required final String artistId,
      SongSortType sortType = SongSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("getSongsFromArtist", {
      'artist': artistId,
      SOURCE_KEY: SOURCE_SONGS,
      SORT_TYPE: sortType.index,
    });

    return _parseSongDataList(dataList);
  }

  /// This method returns a list of SongInfo with all songs that appears in
  /// specified[album]. If you want to show all songs that
  /// appears on [album] no matter what artist it belongs you should use this method.
  /// But if you have an album that has multiple songs for multiple artists and you wanna
  /// fetch only that songs that belongs to an specified [artist] you should use
  /// getSongsFromArtistAlbum call.
  ///
  /// [album] Represents the album that we want to fetch all songs. Must be non null.
  Future<List<SongInfo>> getSongsFromAlbum(
      {required final String albumId,
      SongSortType sortType = SongSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("getSongsFromAlbum", {
      'album_id': albumId,
      SOURCE_KEY: SOURCE_SONGS,
      SORT_TYPE: sortType.index,
    });
    return _parseSongDataList(dataList);
  }

  /// This method should be used when we want to fetch [artist] specific songs
  /// that appears in [album]. Sometimes we can have an album with multiple artists
  /// songs if make senses show only the songs for a specific artist that appears on
  /// [album] so this is the appropriated method. If you want to show all songs that
  /// appears on [album] no matter what artist it belongs you should use getSongsFromAlbum method.
  ///
  /// [artist] The artist name which that appears on [album]. Must be non null.
  /// [album] The album. Must be non null.
  Future<List<SongInfo>> getSongsFromArtistAlbum(
      {required final String albumId,
      required final String artist,
      SongSortType sortType = SongSortType.DEFAULT}) async {
    List<dynamic> dataList =
        await channel.invokeMethod("getSongsFromArtistAlbum", {
      'album_id': albumId,
      'artist': artist,
      SOURCE_KEY: SOURCE_SONGS,
      SORT_TYPE: sortType.index,
    });
    return _parseSongDataList(dataList);
  }

  /// This method returns a list fo songs info which all songs are from
  /// specified [genre] name.
  ///
  /// [genre] Genre name must be non null.
  Future<List<SongInfo>> getSongsFromGenre(
      {required final String genre,
      SongSortType sortType = SongSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("getSongsFromGenre", {
      SOURCE_KEY: SOURCE_SONGS,
      'genre_name': genre,
      SORT_TYPE: sortType.index,
    });
    return _parseSongDataList(dataList);
  }

  // TODO possible go to PlaylistInfo class
  /// This method return a List with SongInfo instances that appears in playlist.
  /// The song order is the same that the playlist defines.
  /// An empty list is returned if the playlist has no songs.
  Future<List<SongInfo>> getSongsFromPlaylist(
      {required final PlaylistInfo playlist}) async {
    List<dynamic> dataList = await channel.invokeMethod("getSongsFromPlaylist",
        {SOURCE_KEY: SOURCE_SONGS, 'memberIds': playlist.memberIds});

    return _parseSongDataList(dataList);
  }

  /// This method fetch songs by Id.
  /// To return data sorted in the same order that ids appears on [ids] list
  /// parameter use [sortType] param with SongSortType.CURRENT_IDs_ORDER value.
  ///
  /// [ids] List of IDs.
  /// [sortType] Data sort Type.
  Future<List<SongInfo>> getSongsById(
      {required List<String> ids,
      SongSortType sortType = SongSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("getSongsById", {
      SOURCE_KEY: SOURCE_SONGS,
      SORT_TYPE: sortType.index,
      'song_ids': ids,
    });
    return _parseSongDataList(dataList);
  }

  /// This method search for songs which [title] property starts or match with [query] string.
  /// It returns a List of [SongInfo] objects or an empty list if no results.
  ///
  /// [query] String used to make the search
  Future<List<SongInfo>> searchSongs(
      {required String query,
      SongSortType sortType = SongSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("searchSongs", {
      SOURCE_KEY: SOURCE_SONGS,
      SORT_TYPE: sortType.index,
      QUERY_KEY: query
    });
    return _parseSongDataList(dataList);
  }

  /// This method returns a list of genre info with all genres available in device storage.
  Future<List<GenreInfo>> getGenres(
      {GenreSortType sortType = GenreSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod('getGenres', {
      SOURCE_KEY: SOURCE_GENRE,
      SORT_TYPE: sortType.index,
    });
    return _parseGenreDataList(dataList);
  }

  /// This method search for genres which [name] property starts or match with [query] param.
  /// It returns a List of [GenreInfo] instances or an empty list if no results.
  ///
  /// [query] String used to make the search
  Future<List<GenreInfo>> searchGenres(
      {required final String query,
      GenreSortType sortType = GenreSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("searchGenres", {
      SOURCE_KEY: SOURCE_GENRE,
      SORT_TYPE: sortType.index,
      QUERY_KEY: query,
    });

    return _parseGenreDataList(dataList);
  }

  /// This method returns a list of PlaylistInfo with all playlists available
  /// in device storage.
  Future<List<PlaylistInfo>> getPlaylists(
      {PlaylistSortType sortType = PlaylistSortType.DEFAULT}) async {
    List<dynamic>? dataList = await channel.invokeListMethod("getPlaylists", {
      SOURCE_KEY: SOURCE_PLAYLIST,
      PLAYLIST_METHOD_TYPE: PlayListMethodType.READ.index,
      SORT_TYPE: sortType.index
    });
    if (dataList == null) return [];
    return _parsePlaylistsDataList(dataList);
  }

  /// This method search for playlist which [name] property starts or match with [query] param.
  /// It returns a List of [PlaylistInfo] instances or an empty list if no results.
  ///
  /// [query] String used to make the search
  Future<List<PlaylistInfo>> searchPlaylists(
      {required final String query,
      PlaylistSortType sortType = PlaylistSortType.DEFAULT}) async {
    List<dynamic> dataList = await channel.invokeMethod("searchPlaylists", {
      SOURCE_KEY: SOURCE_PLAYLIST,
      PLAYLIST_METHOD_TYPE: PlayListMethodType.READ.index,
      QUERY_KEY: query,
      SORT_TYPE: sortType.index,
    });

    return _parsePlaylistsDataList(dataList);
  }

  /// This method fetchs an artowrk for ARSTIS, ALBUM or SONG based on content id.
  /// It must be used on Android >= Q as scoped storage does not allow load images
  /// using absolute file path.
  ///
  /// It returns an Uint8List with the bitmap bytes or empty list if no image was found.
  ///
  /// [type] The resource type you want to fetch an image. The values can be:
  /// ResourceType.ARTIST, ResourceType.ALBUM OR ResourceType.SONG. It must be non null.
  ///
  /// [id] The content id you want an artwork image.
  ///
  /// [size] The image dimensions. The default value is Size(250, 250)
  ///
  Future<Uint8List> getArtwork({
    required final ResourceType type,
    required final String id,
    final Size? size,
  }) async {
    final data = await channel.invokeMethod("getArtwork", {
      SOURCE_KEY: SOURCE_ARTWORK,
      "resource": type.index,
      "id": id,
      "width": size?.width.round() ?? 250,
      "height": size?.height.round() ?? 250,
    });

    Map<String, dynamic> dataMap = Map<String, dynamic>.from(data);
    if (dataMap["image"] != null) {
      final imageBytes = Uint8List.fromList(List<int>.from(dataMap["image"]));
      return imageBytes;
    }
    return Uint8List.fromList([]);
  }

  /// This method creates a new empty playlist named [playlistName].
  /// If already exist a playlist with same name as [playlistName] an
  /// exception is throw.
  static Future<PlaylistInfo> createPlaylist(
      {required final String playlistName}) async {
    dynamic data =
        await FlutterAudioQuery.channel.invokeMethod("createPlaylist", {
      FlutterAudioQuery.SOURCE_KEY: FlutterAudioQuery.SOURCE_PLAYLIST,
      FlutterAudioQuery.PLAYLIST_METHOD_TYPE: PlayListMethodType.WRITE.index,
      "playlist_name": playlistName,
    });
    return PlaylistInfo._(data);
  }

  /// Removes an specific playlist.
  /// [playlist] playlist to be removed.
  static Future<void> removePlaylist({required PlaylistInfo playlist}) async {
    await channel.invokeMethod("removePlaylist", {
      SOURCE_KEY: SOURCE_PLAYLIST,
      FlutterAudioQuery.PLAYLIST_METHOD_TYPE: PlayListMethodType.WRITE.index,
      "playlist_id": playlist.id
    });
  }

  List<ArtistInfo> _parseArtistDataList(List<dynamic> dataList) {
    return dataList
        .map<ArtistInfo>((dynamic item) => ArtistInfo._(item))
        .toList();
  }

  List<AlbumInfo> _parseAlbumDataList(List<dynamic> dataList) {
    return dataList
        .map<AlbumInfo>((dynamic item) => AlbumInfo._(item))
        .toList();
  }

  List<SongInfo> _parseSongDataList(List<dynamic> dataList) {
    return dataList.map<SongInfo>((dynamic item) => SongInfo._(item)).toList();
  }

  List<GenreInfo> _parseGenreDataList(List<dynamic> dataList) {
    return dataList
        .map<GenreInfo>((dynamic item) => GenreInfo._(item))
        .toList();
  }

  List<PlaylistInfo> _parsePlaylistsDataList(List<dynamic> dataList) {
    return dataList
        .map<PlaylistInfo>((dynamic item) => PlaylistInfo._(item))
        .toList();
  }
}
