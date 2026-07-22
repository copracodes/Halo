import 'tmdb_credits.dart';
import 'tmdb_json.dart';

/// A season as summarised in a show's details. Episode data needs a separate
/// `tv/{id}/season/{n}` call — see [TmdbSeasonDetails].
class TmdbSeasonSummary {
  const TmdbSeasonSummary({
    required this.seasonNumber,
    required this.name,
    this.id,
    this.episodeCount = 0,
    this.overview,
    this.posterPath,
    this.airDate,
  });

  /// Season 0 is TMDB's convention for specials.
  final int seasonNumber;

  final String name;
  final int? id;
  final int episodeCount;
  final String? overview;
  final String? posterPath;
  final DateTime? airDate;

  bool get isSpecials => seasonNumber == 0;

  factory TmdbSeasonSummary.fromJson(Map<String, dynamic> json) {
    return TmdbSeasonSummary(
      seasonNumber: asInt(json['season_number']) ?? 0,
      name: asString(json['name']) ?? '',
      id: asInt(json['id']),
      episodeCount: asInt(json['episode_count']) ?? 0,
      overview: asString(json['overview']),
      posterPath: asString(json['poster_path']),
      airDate: asDate(json['air_date']),
    );
  }
}

/// Full show record from `tv/{id}`, including its season list.
class TmdbTvDetails {
  const TmdbTvDetails({
    required this.id,
    required this.name,
    this.originalName,
    this.tagline,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
    this.lastAirDate,
    this.numberOfSeasons = 0,
    this.numberOfEpisodes = 0,
    this.genres = const [],
    this.networks = const [],
    this.seasons = const [],
    this.voteAverage = 0,
    this.voteCount = 0,
    this.status,
    this.credits = TmdbCredits.empty,
    this.images = TmdbImageSet.empty,
  });

  final int id;
  final String name;
  final String? originalName;
  final String? tagline;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final List<String> genres;
  final List<String> networks;

  /// Ordered by season number, specials (season 0) last — matching how Halo
  /// already groups scanned episodes.
  final List<TmdbSeasonSummary> seasons;

  final double voteAverage;
  final int voteCount;

  /// "Returning Series", "Ended", "Canceled", …
  final String? status;

  final TmdbCredits credits;
  final TmdbImageSet images;

  int? get year => firstAirDate?.year;

  /// The seasons that carry regular episodes.
  List<TmdbSeasonSummary> get regularSeasons =>
      seasons.where((season) => !season.isSpecials).toList();

  factory TmdbTvDetails.fromJson(Map<String, dynamic> json) {
    final seasons = asObjectList(json['seasons'])
        .map(TmdbSeasonSummary.fromJson)
        .toList()
      ..sort((a, b) {
        // Specials last; everything else ascending.
        if (a.isSpecials != b.isSpecials) return a.isSpecials ? 1 : -1;
        return a.seasonNumber.compareTo(b.seasonNumber);
      });

    return TmdbTvDetails(
      id: asInt(json['id']) ?? 0,
      name: asString(json['name']) ?? '',
      originalName: asString(json['original_name']),
      tagline: asString(json['tagline']),
      overview: asString(json['overview']),
      posterPath: asString(json['poster_path']),
      backdropPath: asString(json['backdrop_path']),
      firstAirDate: asDate(json['first_air_date']),
      lastAirDate: asDate(json['last_air_date']),
      numberOfSeasons: asInt(json['number_of_seasons']) ?? 0,
      numberOfEpisodes: asInt(json['number_of_episodes']) ?? 0,
      genres: asNames(json['genres']),
      networks: asNames(json['networks']),
      seasons: seasons,
      voteAverage: asDouble(json['vote_average']) ?? 0,
      voteCount: asInt(json['vote_count']) ?? 0,
      status: asString(json['status']),
      credits: switch (asObject(json['credits'])) {
        final credits? => TmdbCredits.fromJson(credits),
        null => TmdbCredits.empty,
      },
      images: switch (asObject(json['images'])) {
        final images? => TmdbImageSet.fromJson(images),
        null => TmdbImageSet.empty,
      },
    );
  }

  @override
  String toString() => 'TmdbTvDetails($id, "$name", ${year ?? '-'})';
}
