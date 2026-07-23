import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'media_with_progress.dart';

/// The single source of truth for "resume where I left off" and
/// continue-watching state. The player writes progress here every few seconds
/// and reads its resume position from here on open. Keyed by file path for the
/// caller's convenience; internally each path maps to one [MediaFiles] row.
class ProgressRepository {
  const ProgressRepository(this._db);

  final AppDatabase _db;

  /// The saved resume position for [filePath], or null if there is none or the
  /// file was already watched to the end. The decision of whether a position is
  /// *worth offering* (min/end thresholds) lives in the player's ResumePolicy;
  /// this just returns the stored point.
  Future<Duration?> resumePositionFor(String filePath) async =>
      (await resumeStateFor(filePath))?.position;

  /// The saved resume point for [filePath] — the position *and* the duration
  /// observed when it was written — or null if there is none or the file was
  /// watched to the end.
  ///
  /// The duration comes back too so the player can judge whether a position is
  /// worth resuming from *before* it opens the file, when the real duration
  /// isn't known yet. That lets it start decoding at the resume point instead
  /// of seeking there afterwards.
  Future<({Duration position, Duration duration})?> resumeStateFor(
    String filePath,
  ) async {
    final row = await _rowForPath(filePath);
    if (row == null || row.isFinished) return null;
    return (
      position: Duration(milliseconds: row.positionMs),
      duration: Duration(milliseconds: row.durationMs),
    );
  }

  /// Reactive continue-watching feed: every started-but-unfinished file, joined
  /// to its media row, most recently watched first. Rows with no known duration
  /// are skipped — they can't be shown as a progress bar and were most likely
  /// written by [markFinished] before a duration was ever observed. Hidden files
  /// are skipped too, so marking something "not a movie" removes it from
  /// continue-watching as well as the grids.
  Stream<List<MediaWithProgress>> watchInProgress() {
    final query = _db.select(_db.watchProgress).join([
      innerJoin(
        _db.mediaFiles,
        _db.mediaFiles.id.equalsExp(_db.watchProgress.mediaFileId),
      ),
    ])
      ..where(_db.watchProgress.isFinished.equals(false) &
          _db.watchProgress.durationMs.isBiggerThanValue(0) &
          _db.mediaFiles.hidden.equals(false))
      ..orderBy([OrderingTerm.desc(_db.watchProgress.lastWatchedAt)]);

    return query.watch().map(
          (rows) => [
            for (final row in rows)
              MediaWithProgress(
                file: row.readTable(_db.mediaFiles),
                progress: row.readTable(_db.watchProgress),
              ),
          ],
        );
  }

  /// Paths of files watched to the end, for "you've seen this" marks.
  Stream<Set<String>> watchFinishedPaths() {
    final query = _db.select(_db.watchProgress).join([
      innerJoin(
        _db.mediaFiles,
        _db.mediaFiles.id.equalsExp(_db.watchProgress.mediaFileId),
      ),
    ])
      ..where(_db.watchProgress.isFinished.equals(true));

    return query.watch().map(
          (rows) => {
            for (final row in rows) row.readTable(_db.mediaFiles).filePath,
          },
        );
  }

  /// Upserts the current playback position for [filePath]. Overwrites any prior
  /// row (unique per media file) and clears the finished flag, since the user is
  /// actively watching again.
  Future<void> savePosition(
    String filePath, {
    required Duration position,
    required Duration duration,
  }) async {
    final mediaFileId = await _db.findOrCreateMediaFileByPath(filePath);
    await _upsertProgress(
      WatchProgressCompanion.insert(
        mediaFileId: mediaFileId,
        positionMs: position.inMilliseconds,
        durationMs: duration.inMilliseconds,
        lastWatchedAt: DateTime.now(),
        isFinished: const Value(false),
      ),
    );
  }

  /// Marks [filePath] as watched to the end so it is no longer offered for
  /// resume (and, later, can surface differently in continue-watching).
  Future<void> markFinished(String filePath) async {
    final mediaFileId = await _db.findOrCreateMediaFileByPath(filePath);
    await _upsertProgress(
      WatchProgressCompanion.insert(
        mediaFileId: mediaFileId,
        positionMs: 0,
        durationMs: 0,
        lastWatchedAt: DateTime.now(),
        isFinished: const Value(true),
      ),
    );
  }

  /// Upserts a progress row, keyed on the unique [WatchProgress.mediaFileId]
  /// (not the primary key), so each media file has exactly one row.
  Future<void> _upsertProgress(WatchProgressCompanion row) {
    return _db.into(_db.watchProgress).insert(
          row,
          onConflict:
              DoUpdate((_) => row, target: [_db.watchProgress.mediaFileId]),
        );
  }

  /// Drops any saved progress for [filePath] (e.g. the position is too close to
  /// the start or the end to be worth resuming).
  Future<void> clearProgress(String filePath) async {
    final media = await (_db.select(_db.mediaFiles)
          ..where((f) => f.filePath.equals(filePath)))
        .getSingleOrNull();
    if (media == null) return;
    await (_db.delete(_db.watchProgress)
          ..where((p) => p.mediaFileId.equals(media.id)))
        .go();
  }

  Future<WatchProgressData?> _rowForPath(String filePath) async {
    final media = await (_db.select(_db.mediaFiles)
          ..where((f) => f.filePath.equals(filePath)))
        .getSingleOrNull();
    if (media == null) return null;
    return (_db.select(_db.watchProgress)
          ..where((p) => p.mediaFileId.equals(media.id)))
        .getSingleOrNull();
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(appDatabaseProvider));
});
