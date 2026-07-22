import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/media_with_progress.dart';
import '../library/library_providers.dart';
import '../library/media_display.dart';
import '../library/movies_tab.dart';
import '../library/show_detail_screen.dart';
import '../library/show_grouping.dart';
import '../library/widgets/library_states.dart';
import '../library/widgets/media_carousel.dart';
import '../library/widgets/poster_card.dart';
import '../metadata/metadata_keys.dart';
import '../metadata/metadata_providers.dart';
import '../metadata/metadata_sync.dart';
import '../player/play_media.dart';
import '../player/resume_behavior.dart';

/// Card widths for the shelves — continue-watching cards are wider because
/// they read as a still frame rather than a poster.
const _stillCardWidth = 200.0;
const _posterCardWidth = 118.0;

/// The landing tab: pick up where you left off, what's newest, then shelves by
/// genre once enough of the library is matched.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueWatching = ref.watch(continueWatchingProvider);
    final recentlyAdded = ref.watch(recentlyAddedProvider);
    final genreRows = ref.watch(genreRowsProvider);

    // Artwork for rows that mix films and episodes.
    final movieMeta = ref.watch(movieMetadataByKeyProvider).value ??
        const <String, MovieMetadataData>{};
    final showMeta = ref.watch(showMetadataByKeyProvider).value ??
        const <String, ShowMetadataData>{};

    // Both shelves come from the same library, so treat "still loading" as one
    // state rather than flashing half a screen.
    if (continueWatching.isLoading && recentlyAdded.isLoading) {
      return const LibraryLoading();
    }

    final inProgress = continueWatching.value ?? const <MediaWithProgress>[];
    final recent = recentlyAdded.value ?? const <MediaFile>[];

    if (inProgress.isEmpty && recent.isEmpty) {
      return const LibraryMessage(
        icon: Icons.local_movies_outlined,
        title: 'Nothing here yet',
        detail: 'Once your folders are scanned, what you’re watching and what’s '
            'newest will show up here.',
      );
    }

    String? artwork(MediaFile file) => artworkPathForFile(
          file,
          movies: movieMeta,
          shows: showMeta,
        );

    return SingleChildScrollView(
      key: const PageStorageKey<String>('home-tab'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (inProgress.isNotEmpty)
            MediaCarousel(
              title: 'Continue Watching',
              storageKey: 'continue-watching',
              cardWidth: _stillCardWidth,
              aspectRatio: PosterCard.stillAspect,
              itemCount: inProgress.length,
              itemBuilder: (context, index) {
                final item = inProgress[index];
                return PosterCard(
                  title: item.file.displayTitle,
                  subtitle: item.file.subtitleLabel,
                  imagePath: artwork(item.file),
                  progress: item.fraction,
                  aspectRatio: PosterCard.stillAspect,
                  icon: item.file.mediaType == MediaType.episode
                      ? Icons.tv_outlined
                      : Icons.movie_outlined,
                  // The tap is the decision to continue, so don't ask again.
                  onTap: () => playMediaFile(
                    context,
                    item.file,
                    behavior: ResumeBehavior.resume,
                  ),
                );
              },
            ),
          if (recent.isNotEmpty)
            MediaCarousel(
              title: 'Recently Added',
              storageKey: 'recently-added',
              cardWidth: _posterCardWidth,
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final file = recent[index];
                return PosterCard(
                  title: file.displayTitle,
                  subtitle: file.subtitleLabel,
                  imagePath: artwork(file),
                  icon: file.mediaType == MediaType.episode
                      ? Icons.tv_outlined
                      : Icons.movie_outlined,
                  onTap: () => _openDetail(context, ref, file),
                );
              },
            ),
          // Genre shelves come last: they only exist once enough of the library
          // is matched, and they shouldn't push the personal rows down.
          for (final row in genreRows)
            MediaCarousel(
              title: row.genre,
              storageKey: 'genre-${row.genre}',
              cardWidth: _posterCardWidth,
              itemCount: row.movies.length,
              itemBuilder: (context, index) => MovieGridCard(
                entry: row.movies[index],
                // Hero tags must be unique on screen, and the same film can
                // appear in several shelves.
                heroPrefix: 'genre-${row.genre}',
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Opens the right detail screen for a file, whichever kind it is.
  void _openDetail(BuildContext context, WidgetRef ref, MediaFile file) {
    if (file.mediaType == MediaType.episode) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              ShowDetailScreen(showId: normalizeShowTitle(file.displayTitle)),
        ),
      );
      return;
    }

    final key = movieKeyFor(file.displayTitle, file.parsedYear);
    final entry = ref
        .read(movieEntriesProvider)
        .value
        ?.where((e) => e.movieKey == key)
        .firstOrNull;

    if (entry != null) {
      openMovieDetail(context, entry);
    } else {
      // Unclassified or not yet grouped — playing it is still the right
      // outcome, and better than a dead tap.
      playMediaFile(context, file);
    }
  }
}
