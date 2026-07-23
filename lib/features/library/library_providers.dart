import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/repositories/media_with_progress.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/subtitle_repository.dart';
import 'folder_access/saf_folder_access.dart';
import 'library_scanner.dart';
import 'library_sort.dart';
import 'show_grouping.dart';

/// How many entries the home rows show before they stop growing.
const _homeRowLimit = 20;

/// Reactive list of the user's library folders.
final libraryFoldersProvider = StreamProvider<List<LibraryFolder>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchFolders();
});

/// The scanner, wired to the platform folder access and the library repository.
final libraryScannerProvider = Provider<LibraryScanner>((ref) {
  return LibraryScanner(
    ref.watch(folderAccessProvider),
    ref.watch(libraryRepositoryProvider),
    ref.watch(subtitleRepositoryProvider),
  );
});

// --- Movies -----------------------------------------------------------------

/// Every file the parser classified as a movie, unsorted.
final moviesProvider = StreamProvider<List<MediaFile>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchMediaOfType(MediaType.movie);
});

/// Files the parser couldn't classify. Surfaced in a collapsed "Other files"
/// section so nothing in the user's library is invisible.
final otherFilesProvider = StreamProvider<List<MediaFile>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.watchMediaOfType(MediaType.unknown);
});

/// Current ordering of the movies grid.
class LibrarySortNotifier extends Notifier<LibrarySort> {
  @override
  LibrarySort build() => LibrarySort.alphabetical;

  void select(LibrarySort sort) => state = sort;
}

final librarySortProvider =
    NotifierProvider<LibrarySortNotifier, LibrarySort>(LibrarySortNotifier.new);

/// The movies grid's contents: [moviesProvider] in the currently selected
/// order. Re-sorts when either the library or the sort changes.
final sortedMoviesProvider = Provider<AsyncValue<List<MediaFile>>>((ref) {
  final sort = ref.watch(librarySortProvider);
  return ref.watch(moviesProvider).whenData((movies) => sortMedia(movies, sort));
});

// --- TV shows ---------------------------------------------------------------

/// Every file the parser classified as an episode, ungrouped.
final episodesProvider = StreamProvider<List<MediaFile>>((ref) {
  return ref
      .watch(libraryRepositoryProvider)
      .watchMediaOfType(MediaType.episode);
});

/// The TV tab's contents: episode files collapsed into shows and seasons.
final showsProvider = Provider<AsyncValue<List<Show>>>((ref) {
  return ref.watch(episodesProvider).whenData(groupIntoShows);
});

/// A single show by its [Show.id], or null once it no longer exists (its files
/// were removed with their folder). Keeps the detail screen reactive.
final showByIdProvider = Provider.family<AsyncValue<Show?>, String>((ref, id) {
  return ref.watch(showsProvider).whenData(
        (shows) => shows.where((show) => show.id == id).firstOrNull,
      );
});

// --- Watch progress ---------------------------------------------------------

/// Every started-but-unfinished file, most recently watched first.
final inProgressProvider = StreamProvider<List<MediaWithProgress>>((ref) {
  return ref.watch(progressRepositoryProvider).watchInProgress();
});

/// The Continue Watching row: the most recent slice of [inProgressProvider].
final continueWatchingProvider =
    Provider<AsyncValue<List<MediaWithProgress>>>((ref) {
  return ref.watch(inProgressProvider).whenData(
        (items) => items.take(_homeRowLimit).toList(),
      );
});

/// Progress keyed by file path, for the bars on episode rows. Empty while the
/// stream is still loading — a missing bar is the right "unknown" rendering.
final progressByPathProvider = Provider<Map<String, MediaWithProgress>>((ref) {
  return ref.watch(inProgressProvider).maybeWhen(
        data: (items) => {for (final item in items) item.file.filePath: item},
        orElse: () => const <String, MediaWithProgress>{},
      );
});

// --- Recently added ---------------------------------------------------------

/// The Recently Added row: newest files in the library first.
final recentlyAddedProvider = StreamProvider<List<MediaFile>>((ref) {
  return ref
      .watch(libraryRepositoryProvider)
      .watchRecentlyAdded(limit: _homeRowLimit);
});
