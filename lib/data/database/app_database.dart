import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_type.dart';

export 'media_type.dart' show MediaType;

part 'app_database.g.dart';

/// Library roots the user has added. On Android these are Storage Access
/// Framework tree URIs (see the `FolderAccess` interface); [path] holds that
/// URI (or a plain filesystem path on platforms that use one).
class LibraryFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  TextColumn get displayName => text()();
  DateTimeColumn get dateAdded => dateTime()();
}

/// Every indexed video file. Files opened ad hoc (via the picker, not part of an
/// indexed folder) also live here with a null [folderId] so their playback
/// progress has something to reference; the scanner later back-fills [folderId]
/// by matching the unique [filePath].
class MediaFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId => integer()
      .nullable()
      .references(LibraryFolders, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text().unique()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  DateTimeColumn get dateModified => dateTime().nullable()();
  DateTimeColumn get dateScanned => dateTime()();
  IntColumn get mediaType =>
      intEnum<MediaType>().withDefault(Constant(MediaType.unknown.index))();
  TextColumn get parsedTitle => text().nullable()();
  IntColumn get parsedYear => integer().nullable()();
  IntColumn get parsedSeason => integer().nullable()();
  IntColumn get parsedEpisode => integer().nullable()();

  /// Last episode for multi-episode files (e.g. S01E01E02); null for single
  /// episodes.
  IntColumn get parsedEpisodeEnd => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
}

/// Resume / continue-watching state, one row per media file. This is the single
/// source of truth for "resume where I left off" (migrated from the Phase 1
/// SharedPreferences store).
class WatchProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mediaFileId => integer()
      .unique()
      .references(MediaFiles, #id, onDelete: KeyAction.cascade)();
  IntColumn get positionMs => integer()();
  IntColumn get durationMs => integer()();
  DateTimeColumn get lastWatchedAt => dateTime()();
  BoolColumn get isFinished => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [LibraryFolders, MediaFiles, WatchProgress])
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database (Android/iOS). [executor] is injected by
  /// tests with an in-memory database.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'halo'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // v2 adds the multi-episode end column to existing installs.
          if (from < 2) {
            await m.addColumn(mediaFiles, mediaFiles.parsedEpisodeEnd);
          }
        },
        beforeOpen: (details) async {
          // Enforce the foreign keys we declared (off by default in SQLite),
          // so cascade deletes and referential integrity actually apply.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Returns the id of the [MediaFiles] row for [filePath], creating a minimal
  /// row (null folder, [MediaType.unknown]) if none exists yet. Shared by the
  /// library and progress repositories so a path maps to exactly one media id.
  Future<int> findOrCreateMediaFileByPath(String filePath) async {
    final existing = await (select(mediaFiles)
          ..where((f) => f.filePath.equals(filePath)))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    return into(mediaFiles).insert(
      MediaFilesCompanion.insert(
        filePath: filePath,
        fileName: _fileNameOf(filePath),
        dateScanned: DateTime.now(),
      ),
    );
  }

  static String _fileNameOf(String path) => path.split(RegExp(r'[/\\]')).last;
}

/// App-wide database. Held for the process lifetime; overridden in [main] so it
/// shares the instance used for the one-time legacy-resume migration.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
