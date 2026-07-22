import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../player/play_media.dart';
import 'library_providers.dart';
import 'show_grouping.dart';
import 'widgets/episode_tile.dart';
import 'widgets/library_states.dart';

/// A show's seasons and episodes.
///
/// The show is looked up by id on every build rather than passed in, so the
/// screen stays live: a rescan that adds episodes, or a folder removal that
/// takes them away, is reflected here without leaving the screen.
class ShowDetailScreen extends ConsumerStatefulWidget {
  const ShowDetailScreen({super.key, required this.showId});

  final String showId;

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
    final showAsync = ref.watch(showByIdProvider(widget.showId));
    final progressByPath = ref.watch(progressByPathProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(showAsync.value?.title ?? 'Show'),
      ),
      body: showAsync.when(
        loading: () => const LibraryLoading(),
        error: (error, _) => LibraryMessage(
          icon: Icons.error_outline,
          title: 'Could not load this show.',
          detail: '$error',
        ),
        data: (show) {
          if (show == null || show.seasons.isEmpty) {
            return const LibraryMessage(
              icon: Icons.tv_off_outlined,
              title: 'This show is no longer in your library',
              detail: 'Its folder may have been removed.',
            );
          }

          final season = _selected(show.seasons);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _ShowHeader(show: show)),
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
                    progress: progressByPath[episode.filePath],
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
}

/// Title block above the episode list. The gradient panel is where a TMDB
/// backdrop will go in Phase 3; the layout is already sized for it.
class _ShowHeader extends StatelessWidget {
  const _ShowHeader({required this.show});

  final Show show;

  String get _summary {
    final episodes = show.episodeCount;
    final seasons = show.seasonCount;
    final episodeText = '$episodes episode${episodes == 1 ? '' : 's'}';
    if (seasons <= 1) return episodeText;
    return '$seasons seasons · $episodeText';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surface, AppColors.background],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            show.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _summary,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
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
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
