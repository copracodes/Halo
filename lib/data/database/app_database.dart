import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'match_status.dart';
import 'media_type.dart';

export 'match_status.dart' show MatchStatus, isAutoWritable;
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

/// TMDB metadata for a movie, keyed by [movieKey] rather than by media file.
///
/// One record serves every file that parses to the same title and year, so a
/// 720p and a 1080p rip of the same film share one poster, one overview, and
/// one match decision — which is also what stops them looking like duplicates
/// in the UI.
class MovieMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Normalised `title|year` (see `metadata_keys.dart`). Unique.
  TextColumn get movieKey => text().unique()();

  IntColumn get tmdbId => integer().nullable()();
  TextColumn get title => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get overview => text().nullable()();

  /// Runtime in milliseconds, matching how durations are stored elsewhere.
  IntColumn get runtimeMs => integer().nullable()();

  RealColumn get voteAverage => real().withDefault(const Constant(0))();

  /// JSON array of genre names.
  TextColumn get genres => text().nullable()();

  /// TMDB-relative artwork paths (`/abc.jpg`), kept so a different size can be
  /// re-derived later without searching again.
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();

  /// Absolute on-device paths. The UI reads only these — never the network.
  TextColumn get localPosterPath => text().nullable()();
  TextColumn get localBackdropPath => text().nullable()();

  /// 0–1 score from the matcher; 0 when nothing was accepted.
  RealColumn get matchConfidence => real().withDefault(const Constant(0))();

  IntColumn get matchStatus =>
      intEnum<MatchStatus>().withDefault(Constant(MatchStatus.pending.index))();

  DateTimeColumn get lastRefreshed => dateTime().nullable()();
}

/// TMDB metadata for a TV show, keyed by its normalised parsed title.
class ShowMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Normalised show title — the same key `groupIntoShows` groups files by.
  TextColumn get showKey => text().unique()();

  IntColumn get tmdbId => integer().nullable()();
  TextColumn get name => text().nullable()();
  IntColumn get firstAirYear => integer().nullable()();
  TextColumn get overview => text().nullable()();
  TextColumn get genres => text().nullable()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();
  TextColumn get localPosterPath => text().nullable()();
  TextColumn get localBackdropPath => text().nullable()();
  RealColumn get matchConfidence => real().withDefault(const Constant(0))();

  IntColumn get matchStatus =>
      intEnum<MatchStatus>().withDefault(Constant(MatchStatus.pending.index))();

  DateTimeColumn get lastRefreshed => dateTime().nullable()();
}

/// One episode's metadata, keyed by show + season + episode.
///
/// Keyed on [showTmdbId] rather than a row id so it survives a show being
/// re-matched, and so a season can be fetched independently of the show record.
class EpisodeMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get showTmdbId => integer()();
  IntColumn get season => integer()();
  IntColumn get episode => integer()();
  TextColumn get name => text().nullable()();
  TextColumn get overview => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
  TextColumn get stillPath => text().nullable()();
  TextColumn get localStillPath => text().nullable()();
  IntColumn get runtimeMs => integer().nullable()();
  DateTimeColumn get lastRefreshed => dateTime().nullable()();

  /// One row per episode of a show.
  @override
  List<Set<Column>> get uniqueKeys => [
        {showTmdbId, season, episode},
      ];
}

@DriftDatabase(
  tables: [
    LibraryFolders,
    MediaFiles,
    WatchProgress,
    MovieMetadata,
    ShowMetadata,
    EpisodeMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database (Android/iOS). [executor] is injected by
  /// tests with an in-memory database.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'halo'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // v2 adds the multi-episode end column to existing installs.
          if (from < 2) {
            await m.addColumn(mediaFiles, mediaFiles.parsedEpisodeEnd);
          }
          // v3 adds the TMDB metadata tables (Phase 3.2). Purely additive —
          // an existing library keeps its files and progress untouched and
          // simply arrives with nothing matched yet.
          if (from < 3) {
            await m.createTable(movieMetadata);
            await m.createTable(showMetadata);
            await m.createTable(episodeMetadata);
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
