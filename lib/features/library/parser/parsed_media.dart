import '../../../data/database/media_type.dart';

/// The structured result of parsing a media filename. Pure data, no Flutter.
class ParsedMedia {
  const ParsedMedia({
    required this.mediaType,
    required this.title,
    this.year,
    this.season,
    this.episode,
    this.episodeEnd,
  });

  final MediaType mediaType;
  final String title;

  /// Release year for movies (1900–2030), or null.
  final int? year;

  /// Season number for episodes; null for anime absolute numbering or movies.
  final int? season;

  /// (First) episode number for episodes; null for movies.
  final int? episode;

  /// Last episode for multi-episode files (e.g. S01E01E02); null otherwise.
  final int? episodeEnd;

  @override
  bool operator ==(Object other) =>
      other is ParsedMedia &&
      other.mediaType == mediaType &&
      other.title == title &&
      other.year == year &&
      other.season == season &&
      other.episode == episode &&
      other.episodeEnd == episodeEnd;

  @override
  int get hashCode =>
      Object.hash(mediaType, title, year, season, episode, episodeEnd);

  @override
  String toString() => 'ParsedMedia(${mediaType.name}, "$title", '
      'year: $year, season: $season, episode: $episode, '
      'episodeEnd: $episodeEnd)';
}
