import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/repositories/metadata_repository.dart';
import '../metadata/fix_match_flow.dart';
import '../metadata/metadata_providers.dart';
import '../player/play_media.dart';
import '../player/resume_behavior.dart';
import 'library_providers.dart';
import 'media_display.dart';
import 'movie_grouping.dart';
import 'quality_label.dart';
import 'widgets/backdrop_header.dart';
import 'widgets/library_states.dart';

/// Everything known about one film, and the place playback starts from.
///
/// Looked up by key on every build rather than passed in, so a metadata sync
/// finishing while this screen is open fills in the backdrop and overview in
/// place.
class MovieDetailScreen extends ConsumerStatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movieKey,
    this.heroTag,
  });

  final String movieKey;

  /// Matches the tag on the card that opened this screen, so its poster flies
  /// into the header.
  final Object? heroTag;

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  /// Which file plays, when a film exists in more than one quality. Held by
  /// path so the choice survives the list being rebuilt from a fresh stream.
  String? _selectedPath;

  MediaFile _selectedFile(MovieEntry entry) {
    final path = _selectedPath;
    if (path == null) return entry.primaryFile;
    return entry.files.where((f) => f.filePath == path).firstOrNull ??
        entry.primaryFile;
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(movieEntryProvider(widget.movieKey));
    final progressByPath = ref.watch(progressByPathProvider);

    return Scaffold(
      body: entryAsync.when(
        loading: () => const LibraryLoading(),
        error: (error, _) => LibraryMessage(
          icon: Icons.error_outline,
          title: 'Could not load this film.',
          detail: '$error',
        ),
        data: (entry) {
          if (entry == null) {
            return const LibraryMessage(
              icon: Icons.movie_outlined,
              title: 'This film is no longer in your library',
              detail: 'Its folder may have been removed.',
            );
          }

          final file = _selectedFile(entry);
          final progress = progressByPath[file.filePath];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: BackdropHeader(
                  imagePath: entry.backdropPath,
                  posterPath: entry.posterPath,
                  title: entry.title,
                  heroTag: widget.heroTag,
                  facts: _facts(entry),
                  actions: _menu(entry, file),
                ),
              ),
              SliverToBoxAdapter(
                child: _Actions(
                  entry: entry,
                  file: file,
                  resumeFrom: progress?.position,
                ),
              ),
              if (entry.overview != null)
                SliverToBoxAdapter(child: _Overview(text: entry.overview!)),
              SliverToBoxAdapter(
                child: _Versions(
                  entry: entry,
                  selected: file,
                  onSelected: (value) =>
                      setState(() => _selectedPath = value.filePath),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  /// The overflow menu shown over the backdrop: correct a wrong match, refresh
  /// it, or hide the file as "not a movie".
  Widget _menu(MovieEntry entry, MediaFile file) {
    final isMatched = entry.metadata?.tmdbId != null;
    final hasVersions = entry.hasVersions;

    return PopupMenuButton<_MovieAction>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      tooltip: 'More',
      onSelected: (action) => _onAction(action, entry, file),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _MovieAction.fixMatch,
          child: _MenuRow(icon: Icons.search, label: 'Fix match'),
        ),
        if (isMatched)
          const PopupMenuItem(
            value: _MovieAction.refresh,
            child: _MenuRow(icon: Icons.refresh, label: 'Refresh metadata'),
          ),
        PopupMenuItem(
          value: _MovieAction.hide,
          child: _MenuRow(
            icon: Icons.visibility_off_outlined,
            label: hasVersions ? 'Hide this version' : 'Not a movie — hide',
          ),
        ),
      ],
    );
  }

  Future<void> _onAction(
    _MovieAction action,
    MovieEntry entry,
    MediaFile file,
  ) async {
    switch (action) {
      case _MovieAction.fixMatch:
        await runFixMatch(
          context,
          ref,
          matchKey: entry.movieKey,
          parsedTitle: file.displayTitle,
          isMovie: true,
        );
      case _MovieAction.refresh:
        await runRefreshMetadata(
          context,
          ref,
          matchKey: entry.movieKey,
          isMovie: true,
        );
      case _MovieAction.hide:
        await _hide(entry, file);
    }
  }

  /// Hides [file] from the library. When it was the film's only file the whole
  /// entry vanishes, so the screen pops back rather than showing an empty shell.
  Future<void> _hide(MovieEntry entry, MediaFile file) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final wasLast = entry.files.length <= 1;

    await ref.read(libraryRepositoryProvider).setHidden(file.id, true);
    if (!mounted) return;

    if (wasLast) navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Hid “${file.fileName}”. Restore it from Settings › Hidden files.',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// The short facts line under the title: year, runtime, rating, genres.
  List<String> _facts(MovieEntry entry) {
    final genres = decodeGenres(entry.metadata?.genres);
    return [
      if (entry.year != null) '${entry.year}',
      if (entry.runtime != null) FormatUtils.formatDuration(entry.runtime!),
      if (entry.voteAverage > 0) '★ ${entry.voteAverage.toStringAsFixed(1)}',
      if (genres.isNotEmpty) genres.take(3).join(', '),
    ];
  }
}

/// Actions in the detail overflow menu.
enum _MovieAction { fixMatch, refresh, hide }

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

/// Play / Resume, and the discreet file line beneath.
class _Actions extends StatelessWidget {
  const _Actions({
    required this.entry,
    required this.file,
    required this.resumeFrom,
  });

  final MovieEntry entry;
  final MediaFile file;

  /// Saved position for the selected file, when there is one worth offering.
  final Duration? resumeFrom;

  @override
  Widget build(BuildContext context) {
    final resume = resumeFrom;
    final quality = qualityLabel(file.fileName);
    final size = file.fileSize > 0 ? formatFileSize(file.fileSize) : null;
    final fileFacts = [if (quality != null) quality, if (size != null) size];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => playMediaFile(
                context,
                file,
                // The label promised a specific behaviour; honour it exactly
                // rather than opening the prompt on top of it.
                behavior:
                    resume == null ? ResumeBehavior.restart : ResumeBehavior.resume,
              ),
              icon: Icon(resume == null ? Icons.play_arrow : Icons.play_circle),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              label: Text(
                resume == null
                    ? 'Play'
                    : 'Resume from ${FormatUtils.formatDuration(resume)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (resume != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => playMediaFile(
                  context,
                  file,
                  behavior: ResumeBehavior.restart,
                ),
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Start over'),
              ),
            ),
          ],
          if (fileFacts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              fileFacts.join(' · '),
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.75),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }
}

/// Selectable versions, shown only when the same film exists more than once.
class _Versions extends StatelessWidget {
  const _Versions({
    required this.entry,
    required this.selected,
    required this.onSelected,
  });

  final MovieEntry entry;
  final MediaFile selected;
  final ValueChanged<MediaFile> onSelected;

  @override
  Widget build(BuildContext context) {
    if (!entry.hasVersions) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Versions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (final file in entry.files)
            ListTile(
              dense: true,
              onTap: () => onSelected(file),
              leading: Icon(
                file.filePath == selected.filePath
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: file.filePath == selected.filePath
                    ? AppColors.accent
                    : AppColors.textSecondary,
                size: 20,
              ),
              title: Text(
                versionLabel(file),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                file.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
