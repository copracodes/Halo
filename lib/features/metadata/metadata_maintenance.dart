import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/repositories/metadata_repository.dart';
import '../library/media_display.dart';
import 'metadata_image_cache.dart';
import 'metadata_keys.dart';

/// Housekeeping for the metadata layer: reclaiming records a removed folder left
/// behind, and clearing the image cache.
///
/// Deliberately conservative about images. The cache is content-addressed (one
/// file per TMDB artwork URL, shared by every title that uses it), so it is
/// *not* torn down when a folder is removed — that keeps re-adding the same
/// folder a zero-download re-link. Image storage is reclaimed on the user's
/// terms instead, through [clearImageCache].
class MetadataMaintenance {
  MetadataMaintenance({
    required MetadataRepository metadata,
    required LibraryRepository library,
    required MetadataImageCache cache,
  })  : _metadata = metadata,
        _library = library,
        _cache = cache;

  final MetadataRepository _metadata;
  final LibraryRepository _library;
  final MetadataImageCache _cache;

  /// Deletes metadata records no library file maps to any more — what a folder
  /// removal leaves orphaned. Keyed by title (not by file), so a record is
  /// "live" as long as *any* indexed file, hidden or not, still resolves to its
  /// key; hiding a file is not the same as removing it.
  ///
  /// Returns the number of records pruned.
  Future<int> pruneOrphans() async {
    final files = await _library.allMedia();

    final liveMovieKeys = <String>{};
    final liveShowKeys = <String>{};
    for (final file in files) {
      final title = file.displayTitle;
      if (title.isEmpty) continue;
      switch (file.mediaType) {
        case MediaType.movie:
          liveMovieKeys.add(movieKeyFor(title, file.parsedYear));
        case MediaType.episode:
          liveShowKeys.add(showKeyFor(title));
        case MediaType.unknown:
          break;
      }
    }

    var pruned = 0;

    for (final movie in await _metadata.allMovies()) {
      if (!liveMovieKeys.contains(movie.movieKey)) {
        await _metadata.deleteMovie(movie.movieKey);
        pruned++;
      }
    }

    for (final show in await _metadata.allShows()) {
      if (!liveShowKeys.contains(show.showKey)) {
        final tmdbId = show.tmdbId;
        if (tmdbId != null) await _metadata.deleteEpisodesForShow(tmdbId);
        await _metadata.deleteShow(show.showKey);
        pruned++;
      }
    }

    return pruned;
  }

  /// Deletes the cached image files and forgets their stored paths, so the next
  /// sync re-downloads artwork. The TMDB records — matches, overviews, episode
  /// data — are untouched.
  Future<void> clearImageCache() async {
    await _cache.clear();
    await _metadata.clearAllLocalImagePaths();
  }

  /// Bytes of artwork currently on disk, for the storage figure in settings.
  Future<int> imageCacheSizeBytes() => _cache.currentSizeBytes();
}

final metadataMaintenanceProvider = Provider<MetadataMaintenance>((ref) {
  return MetadataMaintenance(
    metadata: ref.watch(metadataRepositoryProvider),
    library: ref.watch(libraryRepositoryProvider),
    cache: ref.watch(metadataImageCacheProvider),
  );
});

/// Current image-cache size, shown in settings. Invalidated after a clear so the
/// figure updates immediately.
final imageCacheSizeProvider = FutureProvider<int>((ref) {
  return ref.watch(metadataMaintenanceProvider).imageCacheSizeBytes();
});
