import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../metadata/metadata_providers.dart';
import 'library_providers.dart';
import 'movie_detail_screen.dart';
import 'movie_grouping.dart';
import 'widgets/library_states.dart';
import 'widgets/media_carousel.dart';
import 'widgets/other_files_section.dart';
import 'widgets/poster_card.dart';
import 'widgets/poster_grid.dart';
import 'widgets/sort_toggle.dart';

/// Grid of every film in the library — one card per *film*, not per file, so a
/// title held in two qualities appears once. Tapping opens its detail screen.
class MoviesTab extends ConsumerWidget {
  const MoviesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(sortedMovieEntriesProvider);
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
                itemBuilder: (context, index) =>
                    MovieGridCard(entry: movies[index]),
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

/// A movie card that opens the detail screen, carrying its poster with it.
class MovieGridCard extends StatelessWidget {
  const MovieGridCard({super.key, required this.entry, this.heroPrefix = 'grid'});

  final MovieEntry entry;

  /// Hero tags must be unique across the screen, so each row that can show the
  /// same film prefixes its own.
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final tag = '$heroPrefix:${entry.movieKey}';

    return PosterCard(
      title: entry.title,
      subtitle: entry.subtitleLabel,
      imagePath: entry.posterPath,
      heroTag: tag,
      badge: entry.hasVersions ? '${entry.files.length} versions' : null,
      onTap: () => openMovieDetail(context, entry, heroTag: tag),
    );
  }
}

/// Pushes the detail screen for [entry].
Future<void> openMovieDetail(
  BuildContext context,
  MovieEntry entry, {
  Object? heroTag,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MovieDetailScreen(
        movieKey: entry.movieKey,
        heroTag: heroTag,
      ),
    ),
  );
}
