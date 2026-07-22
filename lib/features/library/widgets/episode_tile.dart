import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/media_with_progress.dart';
import '../media_display.dart';

/// One row in a season's episode list: number, name, file info, and — when the
/// episode has been started — how far in the viewer got.
class EpisodeTile extends StatelessWidget {
  const EpisodeTile({
    super.key,
    required this.file,
    required this.onTap,
    this.progress,
  });

  final MediaFile file;
  final VoidCallback onTap;

  /// Saved progress for this file, if it has been partly watched.
  final MediaWithProgress? progress;

  /// The leading number badge: the episode number when known, otherwise a dot.
  String get _number {
    final episode = file.parsedEpisode;
    return episode == null ? '•' : '$episode';
  }

  /// The row's headline.
  ///
  /// Real episode names arrive with TMDB in Phase 3 and will slot in here.
  /// Until then the episode number is the most honest label available — the raw
  /// filename is not, because it drags release junk (`_720p`, codec and group
  /// tags) into a list that every other surface shows cleanly. Files with no
  /// episode number have nothing better, so they keep their name.
  String get _title {
    final episode = file.parsedEpisode;
    if (episode == null) return stripExtension(file.fileName);
    final end = file.parsedEpisodeEnd;
    return end == null ? 'Episode $episode' : 'Episodes $episode–$end';
  }

  String get _fileInfo {
    final parts = <String>[
      if (file.fileSize > 0) _formatSize(file.fileSize),
      if (file.durationMs != null)
        FormatUtils.formatDuration(Duration(milliseconds: file.durationMs!)),
    ];
    return parts.join(' · ');
  }

  static String _formatSize(int bytes) {
    const gb = 1024 * 1024 * 1024;
    const mb = 1024 * 1024;
    if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(1)} GB';
    return '${(bytes / mb).round()} MB';
  }

  @override
  Widget build(BuildContext context) {
    final progress = this.progress;
    final fileInfo = _fileInfo;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                _number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                  if (fileInfo.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      fileInfo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  // Two rips of the same episode are otherwise identical rows,
                  // so the file name stays visible as the tie-breaker — dimmed
                  // and last, since it's for disambiguating rather than
                  // reading. Once TMDB episode names land this is the natural
                  // thing to put behind a setting.
                  const SizedBox(height: 2),
                  Text(
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.55),
                      fontSize: 10,
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    _EpisodeProgress(progress: progress),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Slim resume bar plus the time left, shown only on started episodes.
class _EpisodeProgress extends StatelessWidget {
  const _EpisodeProgress({required this.progress});

  final MediaWithProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.fraction,
              minHeight: 3,
              backgroundColor: AppColors.surface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${FormatUtils.formatDuration(progress.remaining)} left',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
