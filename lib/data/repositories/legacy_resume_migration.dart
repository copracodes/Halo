import 'package:shared_preferences/shared_preferences.dart';

import 'progress_repository.dart';

/// The SharedPreferences key prefix the Phase 1 resume store used.
const _legacyPrefix = 'resume_position:';

/// Set once the migration has run, so it never re-scans on later launches.
const _migratedFlag = 'resume_migrated_v1';

/// Moves any Phase 1 SharedPreferences resume positions into the drift-backed
/// [WatchProgress] table, then removes the old keys. Runs at most once (guarded
/// by [_migratedFlag]); calling it again is a cheap no-op.
///
/// The legacy store only kept a position, not a duration, so migrated rows get a
/// duration of 0 (unknown); the next real save during playback fills it in.
Future<void> migrateLegacyResume(ProgressRepository progress) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_migratedFlag) ?? false) return;

  for (final key in prefs.getKeys()) {
    if (!key.startsWith(_legacyPrefix)) continue;
    final path = key.substring(_legacyPrefix.length);
    final ms = prefs.getInt(key);
    if (path.isNotEmpty && ms != null) {
      await progress.savePosition(
        path,
        position: Duration(milliseconds: ms),
        duration: Duration.zero,
      );
    }
    await prefs.remove(key);
  }

  await prefs.setBool(_migratedFlag, true);
}
