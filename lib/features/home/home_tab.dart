import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/media_with_progress.dart';
import '../library/library_providers.dart';
import '../library/media_display.dart';
import '../library/widgets/library_states.dart';
import '../library/widgets/media_carousel.dart';
import '../library/widgets/poster_card.dart';
import '../player/play_media.dart';

/// Card widths for the two shelves — continue-watching cards are wider because
/// they read as a still frame rather than a poster.
const _stillCardWidth = 200.0;
const _posterCardWidth = 118.0;

/// The landing tab: pick up where you left off, then what's newest. A fuller
/// Netflix-style home (genre rows, a featured hero) comes in a later phase.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueWatching = ref.watch(continueWatchingProvider);
    final recentlyAdded = ref.watch(recentlyAddedProvider);

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
                  progress: item.fraction,
                  aspectRatio: PosterCard.stillAspect,
                  icon: item.file.mediaType == MediaType.episode
                      ? Icons.tv_outlined
                      : Icons.movie_outlined,
                  // The tap is the decision to continue, so don't ask again.
                  onTap: () =>
                      playMediaFile(context, item.file, autoResume: true),
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
                  icon: file.mediaType == MediaType.episode
                      ? Icons.tv_outlined
                      : Icons.movie_outlined,
                  onTap: () => playMediaFile(context, file),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
