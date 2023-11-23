class AnimeDetails {
  final String animeTitle;
  final String type;
  final String releasedDate;
  final String status;
  final String description;
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
    this.description = '',
    this.genres = const [],
    this.otherNames = '',
    this.synopsis = '',
    this.animeImg = '',
    this.totalEpisodes = '',
    this.episodesList = const [],
  });

  factory AnimeDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> episodesData = json['episodes'] ?? [];

    return AnimeDetails(
      animeTitle: json['title'] ?? '',
      type: json['type'] ?? '',
      releasedDate: json['releasedDate'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      otherNames: json['otherNames'] == null ? '' : json['otherNames'].toString() ?? '',
      synopsis: json['synopsis'] ?? '',
      animeImg: json['image'] ?? '',
      totalEpisodes: json['totalEpisodes'].toString() ?? '',
      // episodesList: episodesData.map((episodeJson) => Episode.fromJson(episodeJson)).toList(),
      episodesList: episodesData.map((episodeJson) => Episode.fromJson(episodeJson)).toList().reversed.toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'animeTitle': animeTitle,
      'type': type,
      'releasedDate': releasedDate,
      'status': status,
      'description':description,
      'genres': genres,
      'otherNames': otherNames,
      'synopsis': synopsis,
      'animeImg': animeImg,
      'totalEpisodes': totalEpisodes,
    };

    if (episodesList.isNotEmpty) {
      data['episodesList'] = episodesList.map((episode) => episode.toJson()).toList();
    }

    print(data);

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
      episodeId: json['id'] ?? '',
      episodeNum: json['number'].toString() ?? '',
      episodeUrl: json['url'] ?? '',
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
