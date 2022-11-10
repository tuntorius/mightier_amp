import 'package:mighty_plug_manager/audio/online_sources/onlineSource.dart';
import 'package:mighty_plug_manager/audio/online_sources/onlineTrack.dart';
import 'package:mighty_plug_manager/audio/online_sources/sourceResolver.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeSource extends OnlineSource {
  @override
  bool get hasSuggestions => false;

  @override
  String get name => "Youtube";

  @override
  Future<List<OnlineTrack>> getSearchResults(String query) async {
    var yt = YoutubeExplode();

    var results = await yt.search.search(query);
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
  Future<String> getTrackUri(OnlineTrack track) async {
    return "yt:${track.id}";
  }

  @override
  Future<String> getPreviewUrl(OnlineTrack track) async {
    var urlCache = SourceResolver.getFromCache(track.id);
    if (urlCache != null) return urlCache;

    return getYoutubeUrlFromId(track.id);
  }

  static Future<String> getYoutubeUrlFromId(String id) async {
    var yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var stream = manifest.audioOnly.withHighestBitrate();
    SourceResolver.addToCache(id, stream.url.toString());
    return stream.url.toString();
  }
}
