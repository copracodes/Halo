import 'tmdb_json.dart';

/// One hit from `search/movie` or `search/tv`.
///
/// Deliberately thin: matching a scanned file to a TMDB entry only needs the
/// title, the year, and enough popularity signal to break ties. Full details
/// are fetched once for the entry that wins.
class TmdbSearchResult {
  const TmdbSearchResult({
    required this.id,
    required this.title,
    required this.isMovie,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage = 0,
    this.voteCount = 0,
    this.popularity = 0,
  });

  final int id;

  /// `title` for movies, `name` for TV — normalised so callers don't branch.
  final String title;

  final bool isMovie;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;

  /// `release_date` (movies) or `first_air_date` (TV). Null when TMDB has none.
  final DateTime? releaseDate;

  final double voteAverage;
  final int voteCount;
  final double popularity;

  int? get year => releaseDate?.year;

  factory TmdbSearchResult.fromJson(
    Map<String, dynamic> json, {
    required bool isMovie,
  }) {
    return TmdbSearchResult(
      id: asInt(json['id']) ?? 0,
      title: asString(json[isMovie ? 'title' : 'name']) ?? '',
      isMovie: isMovie,
      originalTitle:
          asString(json[isMovie ? 'original_title' : 'original_name']),
      overview: asString(json['overview']),
      posterPath: asString(json['poster_path']),
      backdropPath: asString(json['backdrop_path']),
      releaseDate:
          asDate(json[isMovie ? 'release_date' : 'first_air_date']),
      voteAverage: asDouble(json['vote_average']) ?? 0,
      voteCount: asInt(json['vote_count']) ?? 0,
      popularity: asDouble(json['popularity']) ?? 0,
    );
  }

  @override
  String toString() => 'TmdbSearchResult($id, "$title", ${year ?? '-'})';
}

/// A page of search results. TMDB paginates everything; Halo only ever reads
/// the first page, but the totals are kept so a caller can tell "no matches"
/// from "many matches".
class TmdbSearchPage {
  const TmdbSearchPage({
    required this.results,
    this.page = 1,
    this.totalPages = 1,
    this.totalResults = 0,
  });

  final List<TmdbSearchResult> results;
  final int page;
  final int totalPages;
  final int totalResults;

  bool get isEmpty => results.isEmpty;

  factory TmdbSearchPage.fromJson(
    Map<String, dynamic> json, {
    required bool isMovie,
  }) {
    return TmdbSearchPage(
      results: asObjectList(json['results'])
          .map((item) => TmdbSearchResult.fromJson(item, isMovie: isMovie))
          .toList(),
      page: asInt(json['page']) ?? 1,
      totalPages: asInt(json['total_pages']) ?? 1,
      totalResults: asInt(json['total_results']) ?? 0,
    );
  }
}
