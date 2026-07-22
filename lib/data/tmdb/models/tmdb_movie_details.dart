import 'tmdb_credits.dart';
import 'tmdb_json.dart';

/// Full movie record from `movie/{id}` with `credits` and `images` appended.
class TmdbMovieDetails {
  const TmdbMovieDetails({
    required this.id,
    required this.title,
    this.originalTitle,
    this.tagline,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.runtime,
    this.genres = const [],
    this.voteAverage = 0,
    this.voteCount = 0,
    this.credits = TmdbCredits.empty,
    this.images = TmdbImageSet.empty,
    this.imdbId,
  });

  final int id;
  final String title;
  final String? originalTitle;
  final String? tagline;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? releaseDate;

  /// Null when TMDB doesn't know it (it reports 0, which isn't a runtime).
  final Duration? runtime;

  final List<String> genres;
  final double voteAverage;
  final int voteCount;
  final TmdbCredits credits;
  final TmdbImageSet images;
  final String? imdbId;

  int? get year => releaseDate?.year;

  factory TmdbMovieDetails.fromJson(Map<String, dynamic> json) {
    return TmdbMovieDetails(
      id: asInt(json['id']) ?? 0,
      title: asString(json['title']) ?? '',
      originalTitle: asString(json['original_title']),
      tagline: asString(json['tagline']),
      overview: asString(json['overview']),
      posterPath: asString(json['poster_path']),
      backdropPath: asString(json['backdrop_path']),
      releaseDate: asDate(json['release_date']),
      runtime: asMinutes(json['runtime']),
      genres: asNames(json['genres']),
      voteAverage: asDouble(json['vote_average']) ?? 0,
      voteCount: asInt(json['vote_count']) ?? 0,
      credits: switch (asObject(json['credits'])) {
        final credits? => TmdbCredits.fromJson(credits),
        null => TmdbCredits.empty,
      },
      images: switch (asObject(json['images'])) {
        final images? => TmdbImageSet.fromJson(images),
        null => TmdbImageSet.empty,
      },
      imdbId: asString(json['imdb_id']),
    );
  }

  @override
  String toString() => 'TmdbMovieDetails($id, "$title", ${year ?? '-'})';
}
