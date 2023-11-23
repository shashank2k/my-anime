class MovieModel {
  String id;
  String title;
  List<String> otherNames;
  String image;
  String description;
  String releaseDate;
  List<EpisodeModel> episodes;

  MovieModel({
    required this.id,
    required this.title,
    required this.otherNames,
    required this.image,
    required this.description,
    required this.releaseDate,
    required this.episodes,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      otherNames: List<String>.from(json['otherNames'] ?? []),
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      episodes: List<EpisodeModel>.from((json['episodes'] ?? []).map((episode) => EpisodeModel.fromJson(episode))).reversed.toList(),
    );
  }
}

class EpisodeModel {
  String id;
  String title;
  int episode;
  String subType;
  String releaseDate;
  String url;

  EpisodeModel({
    required this.id,
    required this.title,
    required this.episode,
    required this.subType,
    required this.releaseDate,
    required this.url,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      episode: json['episode'] ?? 0,
      subType: json['subType'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
