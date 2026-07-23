import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../metadata/fix_match_flow.dart';
import '../metadata/metadata_keys.dart';
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
                  actions: _menu(entry),
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
                    onLongPress: () => _confirmHideEpisode(episode),
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

  /// The overflow menu over the backdrop: correct a wrong match or refresh it.
  /// (Hiding a junk episode file lives on a long-press of the episode row.)
  Widget _menu(ShowEntry entry) {
    final isMatched = entry.tmdbId != null;

    return PopupMenuButton<_ShowAction>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      tooltip: 'More',
      onSelected: (action) => _onAction(action, entry),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _ShowAction.fixMatch,
          child: _MenuRow(icon: Icons.search, label: 'Fix match'),
        ),
        if (isMatched)
          const PopupMenuItem(
            value: _ShowAction.refresh,
            child: _MenuRow(icon: Icons.refresh, label: 'Refresh metadata'),
          ),
      ],
    );
  }

  Future<void> _onAction(_ShowAction action, ShowEntry entry) async {
    final showKey = showKeyFor(entry.show.title);
    switch (action) {
      case _ShowAction.fixMatch:
        await runFixMatch(
          context,
          ref,
          matchKey: showKey,
          parsedTitle: entry.show.title,
          isMovie: false,
        );
      case _ShowAction.refresh:
        await runRefreshMetadata(
          context,
          ref,
          matchKey: showKey,
          isMovie: false,
        );
    }
  }

  /// Confirms, then hides one episode file — for a stray sample or a mislabelled
  /// clip that shouldn't be in the show.
  Future<void> _confirmHideEpisode(MediaFile episode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hide this file?'),
        content: Text(
          '“${episode.fileName}” will be hidden from your library. The file on '
          'disk is not touched, and you can restore it from Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hide'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    await ref.read(libraryRepositoryProvider).setHidden(episode.id, true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Hid “${episode.fileName}”. Restore it from Settings › Hidden files.',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Actions in the show detail overflow menu.
enum _ShowAction { fixMatch, refresh }

/// An icon-and-label row for a popup menu item, matching the dark theme.
class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      ],
    );
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
