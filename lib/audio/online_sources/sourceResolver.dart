import 'package:audio_picker/audio_picker.dart';
import 'package:mighty_plug_manager/audio/online_sources/YoutubeSource.dart';

class SourceResolver {
  static final Map<String, String> _pathCache = {};
  static Future<String> getSourceUrl(String sourceUri) async {
    if (sourceUri.startsWith("yt:")) {
      var id = sourceUri.substring(3);

      if (_pathCache.containsKey(id)) return _pathCache[id]!;
      //this is youtube source, parse the url
      String url = await YoutubeSource.getYoutubeUrlFromId(id);
      _pathCache[id] = url;
      return url;
    }
    else if (sourceUri.startsWith("iosbm:")) {
      var url = await AudioPicker().iosBookmarkToUrl(sourceUri);
      return url;
    }
    return sourceUri;
  }

  static void addToCache(String id, String url) {
    _pathCache[id] = url;
  }

  static String? getFromCache(String id) {
    return _pathCache[id];
  }
}
