import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/media_with_progress.dart';
import '../media_display.dart';
import '../quality_label.dart';

/// One row in a season's episode list: still, number, name, overview, air date,
/// resume bar, watched mark, and the file name.
///
/// Everything from TMDB is optional. An unmatched show still lists its
/// episodes with file-derived labels — metadata enriches this row, it is never
/// a prerequisite for it.
class EpisodeTile extends StatelessWidget {
  const EpisodeTile({
    super.key,
    required this.file,
    required this.onTap,
    this.metadata,
    this.progress,
    this.watched = false,
  });

  final MediaFile file;
  final VoidCallback onTap;

  /// TMDB's record for this episode, when the show is matched.
  final EpisodeMetadataData? metadata;

  /// Saved progress, if it has been partly watched.
  final MediaWithProgress? progress;

  /// Watched to the end.
  final bool watched;

  static const double _stillWidth = 116;

  /// The leading number: the episode number when known, otherwise a dot.
  String get _number {
    final episode = file.parsedEpisode;
    return episode == null ? '•' : '$episode';
  }

  /// TMDB's episode name when matched; otherwise the number, and only the file
  /// name when there is nothing better.
  String get _title {
    final name = metadata?.name;
    if (name != null && name.isNotEmpty) return name;
    final episode = file.parsedEpisode;
    if (episode == null) return stripExtension(file.fileName);
    final end = file.parsedEpisodeEnd;
    return end == null ? 'Episode $episode' : 'Episodes $episode–$end';
  }

  String get _fileInfo {
    final runtimeMs = metadata?.runtimeMs ?? file.durationMs;
    return [
      if (metadata?.airDate != null) _formatDate(metadata!.airDate!),
      if (runtimeMs != null && runtimeMs > 0)
        FormatUtils.formatDuration(Duration(milliseconds: runtimeMs)),
      if (file.fileSize > 0) formatFileSize(file.fileSize),
    ].join(' · ');
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = this.progress;
    final overview = metadata?.overview;
    final fileInfo = _fileInfo;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Still(
              path: metadata?.localStillPath,
              number: _number,
              watched: watched,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (watched)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.check_circle,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  if (overview != null && overview.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (fileInfo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      fileInfo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    _EpisodeProgress(progress: progress),
                  ],
                  // Two rips of the same episode are otherwise identical rows,
                  // so the file name stays visible as the tie-breaker — dimmed
                  // and last, since it's for disambiguating rather than
                  // reading.
                  const SizedBox(height: 4),
                  Text(
                    file.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.55),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The episode still, or a numbered placeholder when there isn't one.
class _Still extends StatelessWidget {
  const _Still({
    required this.path,
    required this.number,
    required this.watched,
  });

  final String? path;
  final String number;
  final bool watched;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: EpisodeTile._stillWidth,
        height: EpisodeTile._stillWidth * 9 / 16,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.surface),
            if (path != null)
              Image(
                // Decoded at the row's own size; a list of full-resolution
                // stills is what makes long episode lists stutter.
                image: ResizeImage.resizeIfNeeded(
                  (EpisodeTile._stillWidth * devicePixelRatio).round(),
                  null,
                  FileImage(File(path)),
                ),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
              ),
            // The number stays legible over any still.
            Positioned(
              left: 5,
              bottom: 3,
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),
            if (watched)
              const Positioned.fill(
                child: ColoredBox(color: Color(0x66000000)),
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
