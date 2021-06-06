class OnlineTrack {
  String title;
  String artist;
  bool hasUrl;
  String url;
  String detailsUrl;

  OnlineTrack(
      {required this.title,
      required this.artist,
      required this.hasUrl,
      this.url = "",
      required this.detailsUrl});
}
