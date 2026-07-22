import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../metadata/metadata_providers.dart';
import '../player/play_media.dart';
import 'library_providers.dart';
import 'show_grouping.dart';
import 'widgets/backdrop_header.dart';
import 'widgets/episode_tile.dart';
import 'widgets/library_states.dart';

/// A show's seasons and episodes, enriched with TMDB names and stills.
///
/// The show is looked up by id on every build rather than passed in, so the
/// screen stays live: a rescan that adds episodes, a folder removal, or a
/// metadata sync landing mid-view is reflected here without leaving.
class ShowDetailScreen extends ConsumerStatefulWidget {
  const ShowDetailScreen({super.key, required this.showId, this.heroTag});

  final String showId;

  /// Matches the tag on the card that opened this screen.
  final Object? heroTag;

  @override
  ConsumerState<ShowDetailScreen> createState() => _ShowDetailScreenState();
}

class _ShowDetailScreenState extends ConsumerState<ShowDetailScreen> {
  /// Which season is showing, keyed by [_keyFor] so the selection survives the
  /// list being rebuilt from a fresh stream emission. Null until the user picks
  /// one, which means "the first season".
  String? _seasonKey;

  static String _keyFor(SeasonGroup season) => season.season?.toString() ?? '_';

  SeasonGroup _selected(List<SeasonGroup> seasons) {
    final key = _seasonKey;
    if (key == null) return seasons.first;
    return seasons.where((s) => _keyFor(s) == key).firstOrNull ?? seasons.first;
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(showEntryProvider(widget.showId));
    final progressByPath = ref.watch(progressByPathProvider);
    final finished = ref.watch(finishedPathsProvider).value ?? const <String>{};

    return Scaffold(
      body: entryAsync.when(
        loading: () => const LibraryLoading(),
        error: (error, _) => LibraryMessage(
          icon: Icons.error_outline,
          title: 'Could not load this show.',
          detail: '$error',
        ),
        data: (entry) {
          if (entry == null || entry.show.seasons.isEmpty) {
            return const LibraryMessage(
              icon: Icons.tv_off_outlined,
              title: 'This show is no longer in your library',
              detail: 'Its folder may have been removed.',
            );
          }

          final show = entry.show;
          final season = _selected(show.seasons);
          // Episode records are keyed by TMDB show id; an unmatched show simply
          // has none, and the rows fall back to their file-derived labels.
          final episodeMeta = entry.tmdbId == null
              ? const <String, dynamic>{}
              : ref.watch(episodeMetadataProvider(entry.tmdbId!)).value ??
                  const {};

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: BackdropHeader(
                  imagePath: entry.backdropPath,
                  posterPath: entry.posterPath,
                  title: entry.title,
                  heroTag: widget.heroTag,
                  facts: _facts(entry),
                ),
              ),
              if (entry.overview != null)
                SliverToBoxAdapter(child: _Overview(text: entry.overview!)),
              if (show.seasons.length > 1)
                SliverToBoxAdapter(
                  child: _SeasonSelector(
                    seasons: show.seasons,
                    selectedKey: _keyFor(season),
                    onSelected: (value) => setState(() => _seasonKey = value),
                  ),
                ),
              SliverList.builder(
                itemCount: season.episodes.length,
                itemBuilder: (context, index) {
                  final episode = season.episodes[index];
                  return EpisodeTile(
                    file: episode,
                    metadata: episodeMeta[episodeKey(
                      episode.parsedSeason,
                      episode.parsedEpisode,
                    )],
                    progress: progressByPath[episode.filePath],
                    watched: finished.contains(episode.filePath),
                    onTap: () => playMediaFile(context, episode),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  List<String> _facts(ShowEntry entry) {
    final show = entry.show;
    final episodes = show.episodeCount;
    final seasons = show.seasonCount;
    return [
      if (entry.metadata?.firstAirYear != null) '${entry.metadata!.firstAirYear}',
      if (seasons > 1) '$seasons seasons',
      '$episodes episode${episodes == 1 ? '' : 's'}',
    ];
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }
}

/// Horizontal row of season chips.
class _SeasonSelector extends StatelessWidget {
  const _SeasonSelector({
    required this.seasons,
    required this.selectedKey,
    required this.onSelected,
  });

  final List<SeasonGroup> seasons;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: seasons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final season = seasons[index];
          final key = season.season?.toString() ?? '_';
          final selected = key == selectedKey;

          return GestureDetector(
            onTap: () => onSelected(key),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                season.label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
