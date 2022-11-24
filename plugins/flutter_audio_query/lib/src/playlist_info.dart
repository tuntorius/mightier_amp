part of flutter_audio_query;

class PlaylistInfo extends DataModel {
  /// Ids of songs that appears on this playlist.
  late List<String> _memberIds;

  PlaylistInfo._(Map<dynamic, dynamic> map) : super._(map) {
    _memberIds = List<String>.from(_data["memberIds"]);
  }

  /// The playlist name
  String get name => _data["name"];

  /// Returns a list with id's of SongInfo which are songs
  /// that appears in this playlist. You can retrieve SongInfo objects that
  /// appears in this playlist with getSongsFromPlayList method.
  /// The list is empty if there is no songs in this playlist.
  List<String> get memberIds => _memberIds;

  /// Returns a String with a number in milliseconds (ms) that represents the
  /// date which this playlist was created.
  String get creationDate => _data["date_added"];

  /// This method appends a [song] into [playlist] and returns a PlaylistInfo
  /// updated.
  Future<void> addSong({required final SongInfo song}) async {
    print("adding song ${song.id} to playlist ${this.id}");

    List<dynamic> updatedData =
        await FlutterAudioQuery.channel.invokeMethod("addSongToPlaylist", {
      FlutterAudioQuery.SOURCE_KEY: FlutterAudioQuery.SOURCE_PLAYLIST,
      FlutterAudioQuery.PLAYLIST_METHOD_TYPE: PlayListMethodType.WRITE.index,
      "playlist_id": this.id,
      "song_id": song.id
    });

    PlaylistInfo data = PlaylistInfo._(updatedData[0]);
    this._updatePlaylistData(data);
  }

  /// This method removes a specified [song] from this playlist.
  Future<void> removeSong({required SongInfo song}) async {
    List<dynamic> updatedPlaylist =
        await FlutterAudioQuery.channel.invokeMethod("removeSongFromPlaylist", {
      FlutterAudioQuery.SOURCE_KEY: FlutterAudioQuery.SOURCE_PLAYLIST,
      FlutterAudioQuery.PLAYLIST_METHOD_TYPE: PlayListMethodType.WRITE.index,
      "playlist_id": this.id,
      "song_id": song.id,
    });

    PlaylistInfo data = PlaylistInfo._(updatedPlaylist[0]);
    this._updatePlaylistData(data);
    //return PlaylistInfo._(updatedPlaylist);
  }

  /// This method updates the playlist itself.
  /// when some playlist data changes like songs order, or song members
  /// this method keep this playlist updated parsing updated data that comes
  /// from native side.
  void _updatePlaylistData(PlaylistInfo playlist) {
    _memberIds = List<String>.from(playlist._data["memberIds"]);
    this._data = playlist._data;
  }

  ///
  void moveSong({required int from, required int to}) async {
    if ((from >= 0 && from < (this._memberIds.length)) &&
        (to >= 0 && to < (this._memberIds.length))) {
      List<dynamic> updatedPlaylist =
          await FlutterAudioQuery.channel.invokeMethod("moveSong", {
        FlutterAudioQuery.SOURCE_KEY: FlutterAudioQuery.SOURCE_PLAYLIST,
        FlutterAudioQuery.PLAYLIST_METHOD_TYPE: PlayListMethodType.WRITE.index,
        "playlist_id": this.id,
        "from": from,
        "to": to,
      });

      PlaylistInfo data = PlaylistInfo._(updatedPlaylist[0]);
      this._updatePlaylistData(data);
    }
  }
}
