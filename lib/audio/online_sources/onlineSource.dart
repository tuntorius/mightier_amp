import 'onlineTrack.dart';

abstract class OnlineSource {
  String get name;
  bool get hasSuggestions;

  Future<List<String>> getSuggestions(String query);

  Future<List<OnlineTrack>> getSearchResults(String query);

  Future<String> getTrackUrl(OnlineTrack track);
}
