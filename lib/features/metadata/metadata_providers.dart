import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/metadata_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../library/library_providers.dart';
import '../library/movie_grouping.dart';
import '../library/library_sort.dart';
import '../library/media_display.dart';
import '../library/show_grouping.dart';
import 'metadata_keys.dart';
import 'metadata_sync.dart';

/// Movies as the UI sees them: one entry per film, with its metadata attached.
///
/// This is where grouping finally shows up on screen — two rips of one film
/// become a single card, which is what the shared metadata key was for.
final movieEntriesProvider = Provider<AsyncValue<List<MovieEntry>>>((ref) {
  final metadata = ref.watch(movieMetadataByKeyProvider).value ??
      const <String, MovieMetadataData>{};

  return ref.watch(moviesProvider).whenData(
        (files) => groupIntoMovies(files, metadata: metadata),
      );
});

/// The movies grid's contents, in the chosen order.
final sortedMovieEntriesProvider = Provider<AsyncValue<List<MovieEntry>>>((ref) {
  final sort = ref.watch(librarySortProvider);

  return ref.watch(movieEntriesProvider).whenData((entries) {
    final sorted = [...entries];
    switch (sort) {
      case LibrarySort.alphabetical:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case LibrarySort.recentlyAdded:
        // Newest file in the group decides where the group sits.
        DateTime newest(MovieEntry entry) => entry.files
            .map((f) => f.dateScanned)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        sorted.sort((a, b) => newest(b).compareTo(newest(a)));
    }
    return sorted;
  });
});

/// One movie entry by key, kept live so a sync landing while the detail screen
/// is open fills in its poster and overview without a reopen.
final movieEntryProvider =
    Provider.family<AsyncValue<MovieEntry?>, String>((ref, movieKey) {
  return ref.watch(movieEntriesProvider).whenData(
        (entries) =>
            entries.where((entry) => entry.movieKey == movieKey).firstOrNull,
      );
});

/// A show grouped from files, paired with its TMDB record.
class ShowEntry {
  const ShowEntry({required this.show, this.metadata});

  final Show show;
  final ShowMetadataData? metadata;

  String get id => show.id;

  /// TMDB's name once matched, otherwise the parsed title.
  String get title {
    final matched = metadata?.name;
    if (matched != null && matched.isNotEmpty) return matched;
    return show.title;
  }

  String? get posterPath => metadata?.localPosterPath;
  String? get backdropPath => metadata?.localBackdropPath;
  String? get overview => metadata?.overview;
  int? get tmdbId => metadata?.tmdbId;
}

final showEntriesProvider = Provider<AsyncValue<List<ShowEntry>>>((ref) {
  final metadata = ref.watch(showMetadataByKeyProvider).value ??
      const <String, ShowMetadataData>{};

  return ref.watch(showsProvider).whenData(
        (shows) => [
          for (final show in shows)
            ShowEntry(show: show, metadata: metadata[showKeyFor(show.title)]),
        ],
      );
});

final showEntryProvider =
    Provider.family<AsyncValue<ShowEntry?>, String>((ref, showId) {
  return ref.watch(showEntriesProvider).whenData(
        (entries) => entries.where((entry) => entry.id == showId).firstOrNull,
      );
});

/// Episode metadata for one show, keyed by `season:episode` so a row can look
/// up its own record in constant time while scrolling.
final episodeMetadataProvider =
    StreamProvider.family<Map<String, EpisodeMetadataData>, int>(
        (ref, showTmdbId) {
  return ref
      .watch(metadataRepositoryProvider)
      .watchEpisodesForShow(showTmdbId)
      .map((rows) => {
            for (final row in rows) episodeKey(row.season, row.episode): row,
          });
});

/// Lookup key for [episodeMetadataProvider].
String episodeKey(int? season, int? episode) => '${season ?? 0}:${episode ?? 0}';

/// Paths of files watched to the end, for the checkmarks on episode rows.
final finishedPathsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(progressRepositoryProvider).watchFinishedPaths();
});

/// Genre rows for the home tab.
///
/// Only genres with enough matched films make a row: a "shelf" of one poster
/// looks broken rather than curated.
const int minimumGenreRowSize = 3;

final genreRowsProvider = Provider<List<({String genre, List<MovieEntry> movies})>>(
  (ref) {
    final entries = ref.watch(movieEntriesProvider).value ?? const <MovieEntry>[];

    final byGenre = <String, List<MovieEntry>>{};
    for (final entry in entries) {
      // Only matched films carry genres, and only artwork makes a row worth
      // looking at.
      if (entry.posterPath == null) continue;
      for (final genre in decodeGenres(entry.metadata?.genres)) {
        byGenre.putIfAbsent(genre, () => <MovieEntry>[]).add(entry);
      }
    }

    final rows = byGenre.entries
        .where((e) => e.value.length >= minimumGenreRowSize)
        .map((e) => (genre: e.key, movies: e.value))
        .toList()
      // Biggest shelves first, then alphabetically so the order is stable.
      ..sort((a, b) {
        final bySize = b.movies.length.compareTo(a.movies.length);
        return bySize != 0 ? bySize : a.genre.compareTo(b.genre);
      });

    return rows;
  },
);

/// The poster to show for an arbitrary library file — used by rows that mix
/// movies and episodes, like Continue Watching and Recently Added.
String? artworkPathForFile(
  MediaFile file, {
  required Map<String, MovieMetadataData> movies,
  required Map<String, ShowMetadataData> shows,
}) {
  if (file.mediaType == MediaType.episode) {
    return shows[showKeyFor(file.displayTitle)]?.localPosterPath;
  }
  return movies[movieKeyFor(file.displayTitle, file.parsedYear)]
      ?.localPosterPath;
}
