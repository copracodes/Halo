import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// Mediates all library reads/writes between features and drift. Features watch
/// the exposed streams and call these methods; they never touch the database
/// directly (see CLAUDE.md: features → repositories → database).
class LibraryRepository {
  const LibraryRepository(this._db);

  final AppDatabase _db;

  // --- Library folders ----------------------------------------------------

  /// Reactive list of library roots, newest first.
  Stream<List<LibraryFolder>> watchFolders() {
    return (_db.select(_db.libraryFolders)
          ..orderBy([(f) => OrderingTerm.desc(f.dateAdded)]))
        .watch();
  }

  Future<List<LibraryFolder>> allFolders() {
    return (_db.select(_db.libraryFolders)
          ..orderBy([(f) => OrderingTerm.desc(f.dateAdded)]))
        .get();
  }

  /// Adds a library root (its SAF tree URI or path). If the same [path] was
  /// already added, its display name is refreshed and the existing id returned.
  Future<int> addFolder({required String path, required String displayName}) {
    final row = LibraryFoldersCompanion.insert(
      path: path,
      displayName: displayName,
      dateAdded: DateTime.now(),
    );
    return _db.into(_db.libraryFolders).insert(
          row,
          onConflict: DoUpdate((_) => row, target: [_db.libraryFolders.path]),
        );
  }

  /// Removes a library root. Its indexed media files (and their progress)
  /// cascade away via the foreign keys.
  Future<void> removeFolder(int folderId) {
    return (_db.delete(_db.libraryFolders)..where((f) => f.id.equals(folderId)))
        .go();
  }

  // --- Media files --------------------------------------------------------

  /// Reactive list of every indexed media file, newest scan first.
  Stream<List<MediaFile>> watchAllMedia() {
    return (_db.select(_db.mediaFiles)
          ..orderBy([(f) => OrderingTerm.desc(f.dateScanned)]))
        .watch();
  }

  /// Reactive list of indexed library files of one [MediaType] — the movies
  /// grid, the episode pool the TV grid groups into shows, and the unclassified
  /// leftovers each watch one of these. Ad-hoc opened files (null folder) are
  /// excluded: the library shows what was scanned. Files the user hid ("not a
  /// movie") are excluded too — they drop out of the grids, matching, and every
  /// derived view at once, and only reappear in the Hidden files list.
  Stream<List<MediaFile>> watchMediaOfType(MediaType type) {
    return (_db.select(_db.mediaFiles)
          ..where((f) =>
              f.folderId.isNotNull() &
              f.mediaType.equalsValue(type) &
              f.hidden.equals(false))
          ..orderBy([(f) => OrderingTerm.asc(f.fileName)]))
        .watch();
  }

  /// Reactive list of hidden files, for the Hidden files list in settings where
  /// the user can restore them. Newest scan first.
  Stream<List<MediaFile>> watchHiddenMedia() {
    return (_db.select(_db.mediaFiles)
          ..where((f) => f.hidden.equals(true))
          ..orderBy([(f) => OrderingTerm.desc(f.dateScanned)]))
        .watch();
  }

  /// Hides or restores a single media file. Hidden files stay in the database
  /// (their playback progress and metadata are untouched) but disappear from
  /// every library view until restored.
  Future<void> setHidden(int id, bool hidden) {
    return (_db.update(_db.mediaFiles)..where((f) => f.id.equals(id)))
        .write(MediaFilesCompanion(hidden: Value(hidden)));
  }

  /// The most recently indexed library files, newest first.
  /// [MediaFiles.dateScanned] is written only when a row is first inserted (see
  /// [upsertMediaFile]), so this really is "recently added" and not "recently
  /// rescanned".
  Stream<List<MediaFile>> watchRecentlyAdded({int limit = 20}) {
    return (_db.select(_db.mediaFiles)
          ..where((f) => f.folderId.isNotNull() & f.hidden.equals(false))
          ..orderBy([(f) => OrderingTerm.desc(f.dateScanned)])
          ..limit(limit))
        .watch();
  }

  /// Reactive list of the media files under a single library folder.
  Stream<List<MediaFile>> watchMediaInFolder(int folderId) {
    return (_db.select(_db.mediaFiles)
          ..where((f) => f.folderId.equals(folderId))
          ..orderBy([(f) => OrderingTerm.asc(f.fileName)]))
        .watch();
  }

  Future<MediaFile?> mediaByPath(String filePath) {
    return (_db.select(_db.mediaFiles)
          ..where((f) => f.filePath.equals(filePath)))
        .getSingleOrNull();
  }

  /// The media-file id for [filePath], creating a minimal row if none exists —
  /// so the player can attach subtitle associations to a file even before a scan
  /// has indexed it (an ad-hoc opened file).
  Future<int> findOrCreateMediaId(String filePath) =>
      _db.findOrCreateMediaFileByPath(filePath);

  /// All indexed media files (used by reparse).
  Future<List<MediaFile>> allMedia() => _db.select(_db.mediaFiles).get();

  /// Overwrites just the parsed/classification fields of a media row, without
  /// re-reading the file from disk. Used by the reparse action.
  Future<void> updateParsed(
    int id, {
    required MediaType mediaType,
    required String? parsedTitle,
    required int? parsedYear,
    required int? parsedSeason,
    required int? parsedEpisode,
    required int? parsedEpisodeEnd,
  }) {
    return (_db.update(_db.mediaFiles)..where((f) => f.id.equals(id))).write(
      MediaFilesCompanion(
        mediaType: Value(mediaType),
        parsedTitle: Value(parsedTitle),
        parsedYear: Value(parsedYear),
        parsedSeason: Value(parsedSeason),
        parsedEpisode: Value(parsedEpisode),
        parsedEpisodeEnd: Value(parsedEpisodeEnd),
      ),
    );
  }

  /// Inserts or updates the media row for a scanned file, matched by its unique
  /// [filePath]. Used by the Phase 2 scanner to index files in place.
  ///
  /// On update, `dateScanned` is deliberately left alone so it keeps meaning
  /// "when this file first entered the library" — otherwise every rescan would
  /// reshuffle the Recently Added row. A known `durationMs` is likewise
  /// preserved when the caller doesn't supply one.
  Future<int> upsertMediaFile({
    required int folderId,
    required String filePath,
    required String fileName,
    int fileSize = 0,
    DateTime? dateModified,
    MediaType mediaType = MediaType.unknown,
    String? parsedTitle,
    int? parsedYear,
    int? parsedSeason,
    int? parsedEpisode,
    int? parsedEpisodeEnd,
    int? durationMs,
  }) {
    final row = MediaFilesCompanion.insert(
      folderId: Value(folderId),
      filePath: filePath,
      fileName: fileName,
      fileSize: Value(fileSize),
      dateModified: Value(dateModified),
      dateScanned: DateTime.now(),
      mediaType: Value(mediaType),
      parsedTitle: Value(parsedTitle),
      parsedYear: Value(parsedYear),
      parsedSeason: Value(parsedSeason),
      parsedEpisode: Value(parsedEpisode),
      parsedEpisodeEnd: Value(parsedEpisodeEnd),
      durationMs: Value(durationMs),
    );
    final onUpdate = MediaFilesCompanion(
      folderId: Value(folderId),
      fileName: Value(fileName),
      fileSize: Value(fileSize),
      dateModified: Value(dateModified),
      mediaType: Value(mediaType),
      parsedTitle: Value(parsedTitle),
      parsedYear: Value(parsedYear),
      parsedSeason: Value(parsedSeason),
      parsedEpisode: Value(parsedEpisode),
      parsedEpisodeEnd: Value(parsedEpisodeEnd),
      durationMs: Value.absentIfNull(durationMs),
    );
    return _db.into(_db.mediaFiles).insert(
          row,
          onConflict:
              DoUpdate((_) => onUpdate, target: [_db.mediaFiles.filePath]),
        );
  }

  Future<void> deleteMediaFile(int id) {
    return (_db.delete(_db.mediaFiles)..where((f) => f.id.equals(id))).go();
  }

  /// Deletes media rows in [folderId] whose path is not in [keepUris] — the
  /// files that vanished since the last scan. With an empty [keepUris], every
  /// file in the folder is removed.
  Future<int> removeMissingMediaFiles(int folderId, Set<String> keepUris) {
    final query = _db.delete(_db.mediaFiles)
      ..where((f) => f.folderId.equals(folderId));
    if (keepUris.isNotEmpty) {
      query.where((f) => f.filePath.isNotIn(keepUris.toList()));
    }
    return query.go();
  }
}

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.watch(appDatabaseProvider));
});
