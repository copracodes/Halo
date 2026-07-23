import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// External subtitle associations: the sidecar files a scan finds next to a
/// video, and the files a user loads by hand. The player reads these to offer
/// external subtitles alongside the embedded tracks.
class SubtitleRepository {
  const SubtitleRepository(this._db);

  final AppDatabase _db;

  /// All external subtitles for a video, sidecars and manual alike.
  Future<List<SubtitleFileData>> forMedia(int mediaFileId) {
    return (_db.select(_db.subtitleFiles)
          ..where((s) => s.mediaFileId.equals(mediaFileId)))
        .get();
  }

  /// Replaces the *sidecar* associations for [mediaFileId] with [subs].
  ///
  /// Only sidecars are touched: a rescan re-derives them from disk, so a sidecar
  /// that was renamed or deleted silently drops out. Manual and downloaded
  /// associations are left alone — the scan can't see whether those still exist.
  Future<void> replaceSidecars(
    int mediaFileId,
    List<({String uri, String? lang})> subs,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.subtitleFiles)
            ..where((s) =>
                s.mediaFileId.equals(mediaFileId) &
                s.source.equalsValue(SubtitleSource.sidecar)))
          .go();
      for (final sub in subs) {
        await _db.into(_db.subtitleFiles).insert(
              SubtitleFilesCompanion.insert(
                mediaFileId: mediaFileId,
                uri: sub.uri,
                source: SubtitleSource.sidecar,
                languageCode: Value(sub.lang),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  /// Marks [uri] as the chosen external subtitle for [mediaFileId], clearing any
  /// previous choice, so reopening the video re-activates exactly this track.
  Future<void> setSelected(int mediaFileId, String uri) {
    return _db.transaction(() async {
      await (_db.update(_db.subtitleFiles)
            ..where((s) => s.mediaFileId.equals(mediaFileId)))
          .write(const SubtitleFilesCompanion(selected: Value(false)));
      await (_db.update(_db.subtitleFiles)
            ..where(
                (s) => s.mediaFileId.equals(mediaFileId) & s.uri.equals(uri)))
          .write(const SubtitleFilesCompanion(selected: Value(true)));
    });
  }

  /// Forgets the chosen external subtitle for [mediaFileId] (subtitles off, or
  /// an embedded track chosen instead).
  Future<void> clearSelected(int mediaFileId) {
    return (_db.update(_db.subtitleFiles)
          ..where((s) => s.mediaFileId.equals(mediaFileId)))
        .write(const SubtitleFilesCompanion(selected: Value(false)));
  }

  /// Records a hand-loaded subtitle, remembered for this file. Keyed by
  /// (video, uri) so loading the same file twice doesn't duplicate it.
  Future<void> addManual(
    int mediaFileId, {
    required String uri,
    String? lang,
  }) {
    return _db.into(_db.subtitleFiles).insert(
          SubtitleFilesCompanion.insert(
            mediaFileId: mediaFileId,
            uri: uri,
            source: SubtitleSource.manual,
            languageCode: Value(lang),
          ),
          onConflict: DoUpdate(
            (_) => SubtitleFilesCompanion(languageCode: Value(lang)),
            target: [_db.subtitleFiles.mediaFileId, _db.subtitleFiles.uri],
          ),
        );
  }
}

final subtitleRepositoryProvider = Provider<SubtitleRepository>((ref) {
  return SubtitleRepository(ref.watch(appDatabaseProvider));
});
