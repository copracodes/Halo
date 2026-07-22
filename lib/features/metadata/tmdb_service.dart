/// Client for enriching indexed media with TMDB metadata (Phase 3).
///
/// Placeholder. Will query The Movie Database for titles, posters, backdrops,
/// overviews, and episode data, matching against filenames parsed from the
/// library. Enrichment happens after indexing and is offline-tolerant:
/// missing metadata never blocks browsing or playback.
class TmdbService {
  const TmdbService();

  /// Looks up metadata for a parsed [title] (and optional [year]).
  /// Not yet implemented.
  Future<void> fetchMovie(String title, {int? year}) async {
    throw UnimplementedError('TMDB metadata arrives in Phase 3.');
  }
}
