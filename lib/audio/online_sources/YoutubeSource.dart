import 'package:mighty_plug_manager/audio/online_sources/onlineSource.dart';
import 'package:mighty_plug_manager/audio/online_sources/onlineTrack.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeSource extends OnlineSource {
  @override
  bool get hasSuggestions => false;

  @override
  String get name => "Youtube";

  @override
  Future<List<OnlineTrack>> getSearchResults(String query) async {
    var yt = YoutubeExplode();

    var results = await yt.search.getVideos(query);
    var songs = <OnlineTrack>[];

    for (var result in results) {
      songs.add(OnlineTrack(
          artist: result.author,
          title: result.title,
          hasUrl: false,
          id: result.id.value,
          detailsUrl: result.url,
          thumbnailUrl: result.thumbnails.standardResUrl));
    }

    return songs;
  }

  @override
  Future<List<String>> getSuggestions(String query) async {
    return [];
  }

  @override
  Future<String> getTrackUrl(OnlineTrack track) async {
    var yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(track.id);
    var stream = manifest.audioOnly.withHighestBitrate();
    return stream.url.toString();
  }
}
