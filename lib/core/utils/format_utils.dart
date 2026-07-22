/// Small, pure formatting helpers used across the app.
class FormatUtils {
  const FormatUtils._();

  /// Formats a [Duration] as `H:MM:SS` (or `M:SS` when under an hour),
  /// suitable for video scrubbers and duration labels.
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$mm:$ss';
    }
    return '$minutes:$ss';
  }
}
