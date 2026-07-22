import '../../data/database/app_database.dart';

/// Presentation helpers shared by every surface that shows a media file: the
/// grids, the continue-watching row, the episode list, and the player title.
/// Pure string work — no Flutter, no I/O — so it stays unit-testable and the
/// widgets stay free of formatting logic.
extension MediaFileDisplay on MediaFile {
  /// The parsed title when the parser found one, otherwise the bare filename
  /// with its extension stripped. Never empty.
  String get displayTitle {
    final parsed = parsedTitle?.trim();
    if (parsed != null && parsed.isNotEmpty) return parsed;
    return stripExtension(fileName);
  }

  /// `S01E05`, `S01E05-E06` (multi-episode files), or `E05` when the season
  /// couldn't be determined. Null for anything that isn't an episode.
  String? get episodeCode {
    if (mediaType != MediaType.episode) return null;
    final episode = parsedEpisode;
    if (episode == null) return null;
    final end = parsedEpisodeEnd;
    final range =
        end == null ? 'E${_pad(episode)}' : 'E${_pad(episode)}-E${_pad(end)}';
    final season = parsedSeason;
    return season == null ? range : 'S${_pad(season)}$range';
  }

  /// The one-line label under a card: the episode code for episodes, the
  /// release year for movies, and nothing when neither is known.
  String? get subtitleLabel =>
      mediaType == MediaType.episode ? episodeCode : parsedYear?.toString();

  /// What the player's top bar shows. Episodes get their show name and code
  /// together ("Breaking Bad · S01E05") so the file is identifiable in
  /// full-screen, where there is no surrounding context.
  String get playerTitle {
    final code = episodeCode;
    return code == null ? displayTitle : '$displayTitle · $code';
  }
}

/// Drops the final `.ext` from a filename, leaving dotless names untouched.
String stripExtension(String fileName) {
  final dot = fileName.lastIndexOf('.');
  return dot > 0 ? fileName.substring(0, dot) : fileName;
}

String _pad(int n) => n.toString().padLeft(2, '0');
