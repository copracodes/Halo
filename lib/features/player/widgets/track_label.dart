import 'package:media_kit/media_kit.dart';

import '../external_subtitle.dart';
import '../track_matching.dart';

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

/// Label for an external subtitle, marked so it's clearly not embedded, e.g.
/// "English — external" or "Subtitle 2 — external".
String externalSubtitleLabel(ExternalSubtitle subtitle, int index) {
  final name = languageDisplayName(subtitle.lang);
  final base = name.isNotEmpty ? name : 'Subtitle ${index + 1}';
  return '$base — external';
}
