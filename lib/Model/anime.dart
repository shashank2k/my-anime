class Anime {
  final String animeId;
  final String episodeId;
  final String animeTitle;
  final String episodeNum;
  final String subOrDub;
  final String animeImg;
  final String episodeUrl;

  Anime({
    required this.animeId,
    required this.episodeId,
    required this.animeTitle,
    required this.episodeNum,
    required this.subOrDub,
    required this.animeImg,
    required this.episodeUrl,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      animeId: json['id'] ?? '',
      episodeId: json['episodeId'] ?? '',
      animeTitle: json['title'] ?? '',
      episodeNum: json['episodeNum'] ?? '',
      subOrDub: json['subOrDub'] ?? '',
      animeImg: json['image'] ?? '',
      episodeUrl: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animeId': animeId,
      'episodeId': episodeId,
      'animeTitle': animeTitle,
      'episodeNum': episodeNum,
      'subOrDub': subOrDub,
      'animeImg': animeImg,
      'episodeUrl': episodeUrl,
    };
  }
}
