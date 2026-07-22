import '../../data/database/app_database.dart';
import '../metadata/metadata_keys.dart';
import 'media_display.dart';
import 'quality_label.dart';

/// One movie in the library: every file that is the same film, plus whatever
/// TMDB knows about it.
///
/// The grid renders one card per entry, not per file — so a 720p and a 1080p
/// rip appear once, and the detail screen offers them as versions. This is the
/// same key the metadata layer matches on, so the card and its poster always
/// agree about which film they are.
class MovieEntry {
  const MovieEntry({
    required this.movieKey,
    required this.files,
    this.metadata,
  });

  final String movieKey;

  /// Every file for this movie, best quality first.
  final List<MediaFile> files;

  final MovieMetadataData? metadata;

  /// The file to play when the user just hits Play.
  MediaFile get primaryFile => files.first;

  bool get hasVersions => files.length > 1;

  /// TMDB's title once matched, otherwise what the parser read from disk.
  String get title {
    final matched = metadata?.title;
    if (matched != null && matched.isNotEmpty) return matched;
    return primaryFile.displayTitle;
  }

  int? get year => metadata?.year ?? primaryFile.parsedYear;

  /// Local artwork path, or null when nothing has been cached — the card then
  /// falls back to its placeholder tile.
  String? get posterPath => metadata?.localPosterPath;
  String? get backdropPath => metadata?.localBackdropPath;

  String? get overview => metadata?.overview;
  double get voteAverage => metadata?.voteAverage ?? 0;

  Duration? get runtime {
    final ms = metadata?.runtimeMs;
    return ms == null || ms <= 0 ? null : Duration(milliseconds: ms);
  }

  /// Caption under a card: the year, or nothing.
  String? get subtitleLabel => year?.toString();
}

/// Groups movie files into one entry per film.
///
/// Files are keyed exactly as the metadata layer keys them, so a card and its
/// metadata record can never disagree. Within an entry, files are ordered by
/// size descending — the biggest rip is almost always the best one, and it
/// becomes the default version to play.
List<MovieEntry> groupIntoMovies(
  List<MediaFile> files, {
  Map<String, MovieMetadataData> metadata = const {},
}) {
  final byKey = <String, List<MediaFile>>{};

  for (final file in files) {
    final title = file.displayTitle;
    if (title.isEmpty) continue;
    byKey
        .putIfAbsent(movieKeyFor(title, file.parsedYear), () => <MediaFile>[])
        .add(file);
  }

  final entries = byKey.entries.map((entry) {
    final sorted = [...entry.value]..sort(_bestFirst);
    return MovieEntry(
      movieKey: entry.key,
      files: sorted,
      metadata: metadata[entry.key],
    );
  }).toList();

  entries.sort(
    (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
  );
  return entries;
}

/// Largest file first, with the name as a tiebreaker so ordering is total and
/// the "default version" never changes between builds.
int _bestFirst(MediaFile a, MediaFile b) {
  final bySize = b.fileSize.compareTo(a.fileSize);
  if (bySize != 0) return bySize;
  return a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase());
}

/// A short description of one version, for the version picker.
String versionLabel(MediaFile file) {
  final quality = qualityLabel(file.fileName);
  final size = file.fileSize > 0 ? formatFileSize(file.fileSize) : null;
  final parts = [if (quality != null) quality, if (size != null) size];
  return parts.isEmpty ? file.fileName : parts.join(' · ');
}
