import 'dart:convert';

import 'package:mighty_plug_manager/audio/online_sources/onlineSource.dart';
import 'package:mighty_plug_manager/audio/online_sources/onlineTrack.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

class BackingTracksCoSource extends OnlineSource {
  static const baseUrl = "https://www.backingtracks.co";
  //static const suggestionsPath = "/static/storage/gbt/search/suggestions/";
  static const searchPath = "/search.php?text=";

  @override
  bool get hasSuggestions => false;

  @override
  String get name => "Backing Tracks Co";

  @override
  Future<List<OnlineTrack>> getSearchResults(String query) async {
    //build search url
    var url = "$baseUrl$searchPath$query";
    var result = await http.get(Uri.parse(url));
    if (result.statusCode == 200) {
      var songs = <OnlineTrack>[];
      var doc = html.parse(result.body);
      var results = doc.querySelectorAll("div.pl-in");
      if (results.length > 0) {
        for (var i = 0; i < results.length; i++) {
          var item = results[i];
          var url = item.children[1].children[0].attributes['data-url'] ?? "";
          songs.add(OnlineTrack(
              artist: item.children[2].children[0].text.trim(),
              title: item.children[2].children[1].text.trim(),
              hasUrl: true,
              url: url,
              detailsUrl: "$baseUrl$url"));
        }
        return songs;
      }
    }

    return [];
  }

  @override
  Future<List<String>> getSuggestions(String query) async {
    return [];
  }

  @override
  Future<String> getTrackUrl(OnlineTrack track) async {
    return track.url;
  }
}
