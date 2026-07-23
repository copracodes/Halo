import '../../data/database/app_database.dart';
import '../library/media_display.dart';
import '../metadata/metadata_keys.dart';

/// Which preference scope a file plays under: a show, a film, or nothing
/// (ad-hoc files, which read global defaults but don't persist changes).
class PlaybackScope {
  const PlaybackScope(this.type, this.key);

  final PrefScope type;
  final String key;

  /// The scope a library file belongs to. Episodes share their show's
  /// preferences (the same key the metadata layer groups them by); films get
  /// their own. Unclassified files have no scope.
  static PlaybackScope? forFile(MediaFile file) {
    final title = file.displayTitle;
    if (title.isEmpty) return null;
    switch (file.mediaType) {
      case MediaType.episode:
        return PlaybackScope(PrefScope.show, showKeyFor(title));
      case MediaType.movie:
        return PlaybackScope(PrefScope.movie, movieKeyFor(title, file.parsedYear));
      case MediaType.unknown:
        return null;
    }
  }
}

/// The preferences to apply to one file, after resolving scope over global over
/// hard defaults. Nullable audio/subtitle fields and a null [subtitlesEnabled]
/// all mean "leave the file's default" — the app only overrides what the viewer
/// actually expressed.
class ResolvedPlaybackPrefs {
  const ResolvedPlaybackPrefs({
    this.audioLang,
    this.audioTitle,
    this.subtitleLang,
    this.subtitlesEnabled,
    this.speed = 1.0,
    this.subtitleDelayMs = 0,
  });

  final String? audioLang;
  final String? audioTitle;
  final String? subtitleLang;

  /// null = no opinion (leave default); true = on; false = off.
  final bool? subtitlesEnabled;

  /// 1.0 means "no speed override".
  final double speed;

  /// Manual subtitle timing offset in milliseconds (positive = later).
  final int subtitleDelayMs;
}

/// Resolves [scope] over [global] over the built-in defaults.
///
/// Audio and subtitles resolve as *units* — if a scope expressed any audio
/// preference, its audio wins whole, rather than mixing a scope language with a
/// global title. That keeps a per-show choice coherent instead of a Frankenstein
/// of two levels.
ResolvedPlaybackPrefs resolvePlaybackPrefs({
  PlaybackPrefsData? scope,
  PlaybackPrefsData? global,
}) {
  final scopeHasAudio = scope != null &&
      (scope.preferredAudioLang != null ||
          scope.preferredAudioTrackTitle != null);
  final audio = scopeHasAudio ? scope : global;

  final scopeHasSubtitle = scope != null &&
      (scope.preferredSubtitleLang != null || scope.subtitlesEnabled != null);
  final subtitle = scopeHasSubtitle ? scope : global;

  final speed = scope?.preferredSpeed ?? global?.preferredSpeed ?? 1.0;
  final subtitleDelayMs =
      scope?.subtitleDelayMs ?? global?.subtitleDelayMs ?? 0;

  return ResolvedPlaybackPrefs(
    audioLang: audio?.preferredAudioLang,
    audioTitle: audio?.preferredAudioTrackTitle,
    subtitleLang: subtitle?.preferredSubtitleLang,
    subtitlesEnabled: subtitle?.subtitlesEnabled,
    speed: speed,
    subtitleDelayMs: subtitleDelayMs,
  );
}

/// Whether speed is remembered per show/movie at all — the global toggle,
/// defaulting to on.
bool rememberSpeedPerShow(PlaybackPrefsData? global) =>
    global?.rememberSpeedPerShow ?? true;
