import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../player/play_media.dart';
import 'library_providers.dart';
import 'media_display.dart';
import 'widgets/library_states.dart';
import 'widgets/media_carousel.dart';
import 'widgets/other_files_section.dart';
import 'widgets/poster_card.dart';
import 'widgets/poster_grid.dart';
import 'widgets/sort_toggle.dart';

/// Grid of every indexed movie, plus a collapsed shelf of files that couldn't
/// be identified. Tapping a card plays it with the usual resume prompt.
class MoviesTab extends ConsumerWidget {
  const MoviesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(sortedMoviesProvider);
    // Unclassified files ride along in this tab, so a failure to load them
    // shouldn't take the grid down with it.
    final other = ref.watch(otherFilesProvider).value ?? const <MediaFile>[];

    return moviesAsync.when(
      loading: () => const LibraryLoading(),
      error: (error, _) => LibraryMessage(
        icon: Icons.error_outline,
        title: 'Could not load your movies.',
        detail: '$error',
      ),
      data: (movies) {
        if (movies.isEmpty && other.isEmpty) {
          return const LibraryMessage(
            icon: Icons.movie_outlined,
            title: 'No movies yet',
            detail: 'Scan a folder of films and they’ll show up here.',
          );
        }

        return CustomScrollView(
          key: const PageStorageKey<String>('movies-tab'),
          slivers: [
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Movies',
                trailing: movies.isEmpty ? null : const SortToggle(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: PosterSliverGrid(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return PosterCard(
                    title: movie.displayTitle,
                    subtitle: movie.subtitleLabel,
                    onTap: () => playMediaFile(context, movie),
                  );
                },
              ),
            ),
            if (other.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: OtherFilesSection(files: other),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }
}
