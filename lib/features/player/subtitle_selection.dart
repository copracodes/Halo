import 'package:media_kit/media_kit.dart';

import 'external_subtitle.dart';
import 'track_matching.dart';

/// What to do about subtitles when a file opens.
enum SubtitleAction { leaveDefault, off, external, embedded }

/// A resolved subtitle decision, with the chosen track when there is one.
class SubtitleDecision {
  const SubtitleDecision._(this.action, {this.external, this.embedded});

  const SubtitleDecision.leaveDefault() : this._(SubtitleAction.leaveDefault);
  const SubtitleDecision.off() : this._(SubtitleAction.off);
  const SubtitleDecision.external(ExternalSubtitle sub)
      : this._(SubtitleAction.external, external: sub);
  const SubtitleDecision.embedded(SubtitleTrack track)
      : this._(SubtitleAction.embedded, embedded: track);

  final SubtitleAction action;
  final ExternalSubtitle? external;
  final SubtitleTrack? embedded;
}

/// Chooses the subtitle to apply on open, treating external subtitles as
/// first-class citizens (Phase 4.1b requirement 4):
///
/// 1. An explicit "off" wins outright.
/// 2. With no subtitle preference at all, leave the file's own default.
/// 3. Otherwise prefer an **external** track whose language matches, then any
///    single external track for this file, then a matching **embedded** track,
///    and finally leave the default.
SubtitleDecision chooseStartupSubtitle({
  required bool? enabled,
  required String? lang,
  required List<ExternalSubtitle> external,
  required List<SubtitleTrack> embedded,
}) {
  if (enabled == false) return const SubtitleDecision.off();

  final hasPreference = enabled == true || (lang != null && lang.isNotEmpty);
  if (!hasPreference) return const SubtitleDecision.leaveDefault();

  for (final subtitle in external) {
    if (languagesMatch(subtitle.lang, lang)) {
      return SubtitleDecision.external(subtitle);
    }
  }
  if (external.length == 1) {
    return SubtitleDecision.external(external.single);
  }

  final match = matchSubtitleTrack(embedded, TrackChoice(language: lang));
  if (match != null) return SubtitleDecision.embedded(match);

  return const SubtitleDecision.leaveDefault();
}
