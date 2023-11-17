class AnimeDetails {
  final String animeTitle;
  final String type;
  final String releasedDate;
  final String status;
  final List<String> genres;
  final String otherNames;
  final String synopsis;
  final String animeImg;
  final String totalEpisodes;
  final List<Episode> episodesList;

  AnimeDetails({
    this.animeTitle = '',
    this.type = '',
    this.releasedDate = '',
    this.status = '',
    this.genres = const [],
    this.otherNames = '',
    this.synopsis = '',
    this.animeImg = '',
    this.totalEpisodes = '',
    this.episodesList = const [],
  });

  factory AnimeDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> episodesData = json['episodesList'] ?? [];

    return AnimeDetails(
      animeTitle: json['animeTitle'] ?? '',
      type: json['type'] ?? '',
      releasedDate: json['releasedDate'] ?? '',
      status: json['status'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      otherNames: json['otherNames'] ?? '',
      synopsis: json['synopsis'] ?? '',
      animeImg: json['animeImg'] ?? '',
      totalEpisodes: json['totalEpisodes'] ?? '',
      episodesList: episodesData.map((episodeJson) => Episode.fromJson(episodeJson)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'animeTitle': animeTitle,
      'type': type,
      'releasedDate': releasedDate,
      'status': status,
      'genres': genres,
      'otherNames': otherNames,
      'synopsis': synopsis,
      'animeImg': animeImg,
      'totalEpisodes': totalEpisodes,
    };

    if (episodesList.isNotEmpty) {
      data['episodesList'] = episodesList.map((episode) => episode.toJson()).toList();
    }

    return data;
  }
}

class Episode {
  final String episodeId;
  final String episodeNum;
  final String episodeUrl;
  final bool isSubbed;
  final bool isDubbed;

  Episode({
    this.episodeId = '',
    this.episodeNum = '',
    this.episodeUrl = '',
    this.isSubbed = false,
    this.isDubbed = false,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    // print('in ep');
    return Episode(
      episodeId: json['episodeId'] ?? '',
      episodeNum: json['episodeNum'] ?? '',
      episodeUrl: json['episodeUrl'] ?? '',
      isSubbed: json['isSubbed'] ?? false,
      isDubbed: json['isDubbed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episodeId': episodeId,
      'episodeNum': episodeNum,
      'episodeUrl': episodeUrl,
      'isSubbed': isSubbed,
      'isDubbed': isDubbed,
    };
  }
}
