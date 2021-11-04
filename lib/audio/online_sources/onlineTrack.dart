class OnlineTrack {
  String title;
  String artist;
  bool hasUrl;
  String url;
  String id;
  String detailsUrl;
  String thumbnailUrl;

  OnlineTrack(
      {required this.title,
      required this.artist,
      required this.hasUrl,
      this.url = "",
      this.id = "",
      required this.detailsUrl,
      this.thumbnailUrl = ""});
}
