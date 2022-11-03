import 'dart:convert';

import 'package:mighty_plug_manager/audio/online_sources/onlineSource.dart';
import 'package:mighty_plug_manager/audio/online_sources/onlineTrack.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

class GuitarBackingTracksSource extends OnlineSource {
  static const baseUrl = "https://www.guitarbackingtrack.com";
  static const suggestionsPath = "/static/storage/gbt/search/suggestions/";
  static const searchPath = "/search.php?query=";

  @override
  bool get hasSuggestions => true;

  @override
  String get name => "Guitar Backing Tracks";

  @override
  Future<List<OnlineTrack>> getSearchResults(String query) async {
    //build search url
    var url = "$baseUrl$searchPath$query";
    var result = await http.get(Uri.parse(url));
    if (result.statusCode == 200) {
      var songs = <OnlineTrack>[];
      var doc = html.parse(result.body);
      var results = doc.querySelectorAll(".gbt-b-section--table-row");
      if (results.length > 1) {
        for (var i = 1; i < results.length; i++) {
          var item = results[i];
          var url = item.children[1].children[0].attributes['href'];
          songs.add(OnlineTrack(
              artist: item.children[0].children[0].text.trim(),
              title: item.children[1].children[0].text.trim(),
              hasUrl: false,
              detailsUrl: "$baseUrl$url"));
        }
        return songs;
      }
    }

    return [];
  }

  @override
  Future<List<String>> getSuggestions(String query) async {
    //build suggestion path
    query = query.split(' ')[0];
    if (query.isNotEmpty) {
      var url = "$baseUrl$suggestionsPath${query[0]}/$query.js";
      var result = await http.get(Uri.parse(url));
      if (result.statusCode == 200) {
        List<dynamic> _res = jsonDecode(result.body)['suggestions'];
        return _res.map((e) => e.toString()).toList();
      }
    }

    return [];
  }

  @override
  Future<String> getTrackUrl(OnlineTrack track) async {
    var result = await http.get(Uri.parse(track.detailsUrl));
    if (result.statusCode == 200) {
      var doc = html.parse(result.body);
      var item = doc.querySelector("audio.js-audio");
      if (item != null) {
        return "$baseUrl${item.attributes["src"].toString()}";
      }
    }
    return "";
  }
}
