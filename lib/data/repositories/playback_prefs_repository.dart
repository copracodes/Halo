import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// Reads and writes sticky playback preferences. Each write is a *partial*
/// update of one scope's row — changing the audio track never disturbs the
/// remembered subtitle or speed — so the resolver can inherit unset fields from
/// the global row (see `resolvePlaybackPrefs`).
class PlaybackPrefsRepository {
  const PlaybackPrefsRepository(this._db);

  final AppDatabase _db;

  static const String _globalKey = '';

  Future<PlaybackPrefsData?> forScope(PrefScope type, String key) {
    return (_db.select(_db.playbackPrefs)
          ..where((p) => p.scopeType.equalsValue(type) & p.scopeKey.equals(key)))
        .getSingleOrNull();
  }

  Future<PlaybackPrefsData?> global() => forScope(PrefScope.global, _globalKey);

  /// The global row as a stream, for the settings screen to render live.
  Stream<PlaybackPrefsData?> watchGlobal() {
    return (_db.select(_db.playbackPrefs)
          ..where((p) =>
              p.scopeType.equalsValue(PrefScope.global) &
              p.scopeKey.equals(_globalKey)))
        .watchSingleOrNull();
  }

  /// Ensures a row exists for the scope, then writes only the columns in
  /// [values] — leaving every other remembered field untouched.
  Future<void> _upsert(
    PrefScope type,
    String key,
    PlaybackPrefsCompanion values,
  ) async {
    await _db.into(_db.playbackPrefs).insert(
          PlaybackPrefsCompanion.insert(scopeType: type, scopeKey: key),
          mode: InsertMode.insertOrIgnore,
        );
    await (_db.update(_db.playbackPrefs)
          ..where((p) => p.scopeType.equalsValue(type) & p.scopeKey.equals(key)))
        .write(values);
  }

  // --- Per-scope writes (from the player) ---------------------------------

  Future<void> saveAudioPref(
    PrefScope type,
    String key, {
    String? lang,
    String? title,
  }) {
    return _upsert(
      type,
      key,
      PlaybackPrefsCompanion(
        preferredAudioLang: Value(lang),
        preferredAudioTrackTitle: Value(title),
      ),
    );
  }

  Future<void> saveSubtitlePref(
    PrefScope type,
    String key, {
    String? lang,
    required bool enabled,
  }) {
    return _upsert(
      type,
      key,
      PlaybackPrefsCompanion(
        preferredSubtitleLang: Value(lang),
        subtitlesEnabled: Value(enabled),
      ),
    );
  }

  /// Turns subtitles off (or on) without disturbing the remembered language, so
  /// switching them back on returns to the same track.
  Future<void> saveSubtitlesEnabled(PrefScope type, String key, bool enabled) {
    return _upsert(
      type,
      key,
      PlaybackPrefsCompanion(subtitlesEnabled: Value(enabled)),
    );
  }

  Future<void> saveSpeed(PrefScope type, String key, double speed) {
    return _upsert(
      type,
      key,
      PlaybackPrefsCompanion(preferredSpeed: Value(speed)),
    );
  }

  Future<void> saveSubtitleDelay(PrefScope type, String key, int delayMs) {
    return _upsert(
      type,
      key,
      PlaybackPrefsCompanion(subtitleDelayMs: Value(delayMs)),
    );
  }

  // --- Global defaults (from settings) ------------------------------------

  Future<void> saveGlobalAudioLang(String? lang) => _upsert(
        PrefScope.global,
        _globalKey,
        PlaybackPrefsCompanion(preferredAudioLang: Value(lang)),
      );

  Future<void> saveGlobalSubtitleLang(String? lang) => _upsert(
        PrefScope.global,
        _globalKey,
        PlaybackPrefsCompanion(preferredSubtitleLang: Value(lang)),
      );

  Future<void> saveGlobalSubtitlesEnabled(bool enabled) => _upsert(
        PrefScope.global,
        _globalKey,
        PlaybackPrefsCompanion(subtitlesEnabled: Value(enabled)),
      );

  Future<void> saveRememberSpeed(bool remember) => _upsert(
        PrefScope.global,
        _globalKey,
        PlaybackPrefsCompanion(rememberSpeedPerShow: Value(remember)),
      );
}

final playbackPrefsRepositoryProvider = Provider<PlaybackPrefsRepository>((ref) {
  return PlaybackPrefsRepository(ref.watch(appDatabaseProvider));
});
