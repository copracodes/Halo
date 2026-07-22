import 'models/tmdb_movie_details.dart';
import 'models/tmdb_search_result.dart';
import 'models/tmdb_season_details.dart';
import 'models/tmdb_tv_details.dart';
import 'tmdb_client.dart';
import 'tmdb_images.dart';
import 'tmdb_result.dart';

/// Typed TMDB endpoints, layered over [TmdbClient]'s transport.
///
/// Every method returns a [TmdbResult]; nothing throws. Decoding is lenient
/// (see `models/tmdb_json.dart`), so a single odd field costs that field rather
/// than the whole response.
class TmdbApi {
  TmdbApi(this._client);

  final TmdbClient _client;

  /// Cached image configuration. TMDB asks clients to read the base URL from
  /// `/configuration` rather than hardcode it, but it changes about never — so
  /// it is fetched once per session and falls back to the known host when the
  /// device is offline.
  TmdbImages? _images;

  bool get hasToken => _client.hasToken;

  /// Image URL builder. Uses the cached configuration once
  /// [loadConfiguration] has succeeded, and [TmdbImages.fallback] before that.
  TmdbImages get images => _images ?? TmdbImages.fallback;

  /// Fetches and caches `/configuration`.
  ///
  /// Failure is not fatal and is reported so a caller can retry later; artwork
  /// URLs keep working from the fallback host meanwhile.
  Future<TmdbResult<TmdbImages>> loadConfiguration() async {
    final cached = _images;
    if (cached != null) return TmdbSuccess(cached);

    final result = await _client.getJson('configuration');
    return result.map((json) {
      final images = TmdbImages.fromJson(json);
      _images = images;
      return images;
    });
  }

  /// `search/movie`. [year] filters on primary release year when known — the
  /// single most effective way to disambiguate remakes.
  Future<TmdbResult<TmdbSearchPage>> searchMovies(
    String query, {
    int? year,
    bool includeAdult = false,
  }) async {
    final result = await _client.getJson('search/movie', query: {
      'query': query,
      'include_adult': '$includeAdult',
      if (year != null) 'primary_release_year': '$year',
    });
    return result.map((json) => TmdbSearchPage.fromJson(json, isMovie: true));
  }

  /// `search/tv`. [year] filters on first air date year.
  Future<TmdbResult<TmdbSearchPage>> searchTv(
    String query, {
    int? year,
    bool includeAdult = false,
  }) async {
    final result = await _client.getJson('search/tv', query: {
      'query': query,
      'include_adult': '$includeAdult',
      if (year != null) 'first_air_date_year': '$year',
    });
    return result.map((json) => TmdbSearchPage.fromJson(json, isMovie: false));
  }

  /// `movie/{id}` with credits and images appended, so one request carries
  /// everything a detail screen needs.
  Future<TmdbResult<TmdbMovieDetails>> movieDetails(int id) async {
    final result = await _client.getJson('movie/$id', query: _detailQuery);
    return result.map(TmdbMovieDetails.fromJson);
  }

  /// `tv/{id}` with credits and images appended. The response carries the
  /// season list, but not their episodes — see [seasonDetails].
  Future<TmdbResult<TmdbTvDetails>> tvDetails(int id) async {
    final result = await _client.getJson('tv/$id', query: _detailQuery);
    return result.map(TmdbTvDetails.fromJson);
  }

  /// `tv/{id}/season/{n}` — episode names, overviews, air dates, and stills.
  Future<TmdbResult<TmdbSeasonDetails>> seasonDetails(
    int tvId,
    int seasonNumber,
  ) async {
    final result = await _client.getJson('tv/$tvId/season/$seasonNumber');
    return result.map(TmdbSeasonDetails.fromJson);
  }

  /// `include_image_language=en,null` keeps English artwork *and* the
  /// language-neutral posters, which are usually the cleanest.
  static const Map<String, String> _detailQuery = {
    'append_to_response': 'credits,images',
    'include_image_language': 'en,null',
  };
}
