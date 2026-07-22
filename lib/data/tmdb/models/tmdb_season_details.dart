import 'tmdb_json.dart';

/// One episode from `tv/{id}/season/{n}` — the record that finally gives a
/// scanned file a real name instead of "Episode 5".
class TmdbEpisode {
  const TmdbEpisode({
    required this.episodeNumber,
    required this.name,
    this.id,
    this.seasonNumber = 0,
    this.overview,
    this.stillPath,
    this.airDate,
    this.runtime,
    this.voteAverage = 0,
  });

  final int episodeNumber;
  final String name;
  final int? id;
  final int seasonNumber;
  final String? overview;

  /// Frame grab for this episode; the artwork an episode row shows.
  final String? stillPath;

  final DateTime? airDate;
  final Duration? runtime;
  final double voteAverage;

  factory TmdbEpisode.fromJson(Map<String, dynamic> json) {
    return TmdbEpisode(
      episodeNumber: asInt(json['episode_number']) ?? 0,
      name: asString(json['name']) ?? '',
      id: asInt(json['id']),
      seasonNumber: asInt(json['season_number']) ?? 0,
      overview: asString(json['overview']),
      stillPath: asString(json['still_path']),
      airDate: asDate(json['air_date']),
      runtime: asMinutes(json['runtime']),
      voteAverage: asDouble(json['vote_average']) ?? 0,
    );
  }

  @override
  String toString() => 'TmdbEpisode(S$seasonNumber E$episodeNumber "$name")';
}

/// A season with its episodes.
class TmdbSeasonDetails {
  const TmdbSeasonDetails({
    required this.seasonNumber,
    required this.name,
    this.id,
    this.overview,
    this.posterPath,
    this.airDate,
    this.episodes = const [],
  });

  final int seasonNumber;
  final String name;
  final int? id;
  final String? overview;
  final String? posterPath;
  final DateTime? airDate;

  /// Ascending by episode number.
  final List<TmdbEpisode> episodes;

  /// The episode with this number, or null when TMDB doesn't list it — which
  /// happens with mis-numbered rips and is not an error.
  TmdbEpisode? episode(int number) =>
      episodes.where((episode) => episode.episodeNumber == number).firstOrNull;

  factory TmdbSeasonDetails.fromJson(Map<String, dynamic> json) {
    return TmdbSeasonDetails(
      seasonNumber: asInt(json['season_number']) ?? 0,
      name: asString(json['name']) ?? '',
      id: asInt(json['id']),
      overview: asString(json['overview']),
      posterPath: asString(json['poster_path']),
      airDate: asDate(json['air_date']),
      episodes: asObjectList(json['episodes'])
          .map(TmdbEpisode.fromJson)
          .toList()
        ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber)),
    );
  }
}
