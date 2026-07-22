import '../database/app_database.dart';

/// A media file paired with its saved watch progress — the shape the
/// continue-watching feed and the episode progress bars are built from.
class MediaWithProgress {
  const MediaWithProgress({required this.file, required this.progress});

  final MediaFile file;
  final WatchProgressData progress;

  Duration get position => Duration(milliseconds: progress.positionMs);
  Duration get duration => Duration(milliseconds: progress.durationMs);
  Duration get remaining => duration - position;

  /// How far through the file the viewer is, as 0–1. Zero when the duration
  /// isn't known yet, so a bar never renders a nonsense fill.
  double get fraction {
    if (progress.durationMs <= 0) return 0;
    return (progress.positionMs / progress.durationMs).clamp(0.0, 1.0);
  }
}
