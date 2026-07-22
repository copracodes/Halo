import 'package:media_kit/media_kit.dart';

/// Human-readable label for an embedded audio/subtitle track, preferring the
/// track's title, then its language, then a positional fallback.
String trackLabel({
  required String? title,
  required String? language,
  required int index,
}) {
  final parts = <String>[
    if (title != null && title.trim().isNotEmpty) title.trim(),
    if (language != null && language.trim().isNotEmpty) language.trim(),
  ];
  if (parts.isEmpty) return 'Track ${index + 1}';
  return parts.join(' · ');
}

String audioTrackLabel(AudioTrack track, int index) =>
    trackLabel(title: track.title, language: track.language, index: index);

String subtitleTrackLabel(SubtitleTrack track, int index) =>
    trackLabel(title: track.title, language: track.language, index: index);
