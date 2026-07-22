import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_providers.dart';
import 'show_detail_screen.dart';
import 'show_grouping.dart';
import 'widgets/library_states.dart';
import 'widgets/media_carousel.dart';
import 'widgets/poster_card.dart';
import 'widgets/poster_grid.dart';

/// Grid of TV *shows*, not episode files: every episode that shares a title is
/// collapsed into one card. Tapping a card opens the show's seasons.
class TvShowsTab extends ConsumerWidget {
  const TvShowsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showsAsync = ref.watch(showsProvider);

    return showsAsync.when(
      loading: () => const LibraryLoading(),
      error: (error, _) => LibraryMessage(
        icon: Icons.error_outline,
        title: 'Could not load your shows.',
        detail: '$error',
      ),
      data: (shows) {
        if (shows.isEmpty) {
          return const LibraryMessage(
            icon: Icons.tv_outlined,
            title: 'No TV shows yet',
            detail: 'Episodes named like “Show S01E01” are grouped into shows '
                'automatically.',
          );
        }

        return CustomScrollView(
          key: const PageStorageKey<String>('tv-tab'),
          slivers: [
            const SliverToBoxAdapter(child: SectionHeader(title: 'TV Shows')),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: PosterSliverGrid(
                itemCount: shows.length,
                itemBuilder: (context, index) {
                  final show = shows[index];
                  return PosterCard(
                    title: show.title,
                    subtitle: _episodeSummary(show),
                    badge: show.seasonCount > 1
                        ? '${show.seasonCount} seasons'
                        : null,
                    icon: Icons.tv_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ShowDetailScreen(showId: show.id),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }

  static String _episodeSummary(Show show) {
    final count = show.episodeCount;
    return '$count episode${count == 1 ? '' : 's'}';
  }
}
