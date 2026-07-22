/// Domain models for enriched media metadata (Phase 3).
///
/// Placeholder. Will define immutable models (movies, shows, seasons,
/// episodes) decoded from TMDB responses and persisted via drift.
class MediaMetadata {
  const MediaMetadata({
    required this.title,
    this.overview,
    this.posterUrl,
    this.year,
  });

  final String title;
  final String? overview;
  final String? posterUrl;
  final int? year;
}
