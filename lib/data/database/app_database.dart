import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'match_status.dart';
import 'media_type.dart';
import 'pref_scope.dart';
import 'subtitle_source.dart';

export 'match_status.dart' show MatchStatus, isAutoWritable;
export 'media_type.dart' show MediaType;
export 'pref_scope.dart' show PrefScope;
export 'subtitle_source.dart' show SubtitleSource;

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

  /// Hidden from the library UI without leaving the database. Set when the user
  /// marks a file "not a movie" (a sample clip, a trailer) so it stops cluttering
  /// the grids, matching, and continue-watching — but stays restorable from the
  /// Hidden files list in settings. Excluded everywhere the UI reads media.
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
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

/// Sticky playback preferences, one row per scope (a show, a film, or the
/// app-wide global fallback). Written silently as the viewer changes tracks or
/// speed during playback, and resolved on the next open: show/movie level →
/// global → file defaults.
///
/// The inheritable fields are nullable so "not set at this scope" is
/// distinguishable from "set to a value" — that is what lets a per-show choice
/// override the global default one field at a time, without a partial write at
/// one scope clobbering the others.
@DataClassName('PlaybackPrefsData')
class PlaybackPrefs extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get scopeType => intEnum<PrefScope>()();

  /// The show key or movie key; empty string for the single global row.
  TextColumn get scopeKey => text()();

  /// Preferred audio by language code (`en`, `eng`, `jpn`, …) and, as a
  /// fallback for untagged tracks, by track title.
  TextColumn get preferredAudioLang => text().nullable()();
  TextColumn get preferredAudioTrackTitle => text().nullable()();

  TextColumn get preferredSubtitleLang => text().nullable()();

  /// Whether subtitles are on. Null means "inherit"; the global row's value is
  /// the app-wide default.
  BoolColumn get subtitlesEnabled => boolean().nullable()();

  /// Playback speed. Null means "inherit"; resolves to 1.0 when nothing is set.
  RealColumn get preferredSpeed => real().nullable()();

  /// Whether speed is remembered per show/movie at all. Meaningful only on the
  /// global row; null reads as true (on by default).
  BoolColumn get rememberSpeedPerShow => boolean().nullable()();

  /// Manual subtitle timing offset in milliseconds. Positive shows subtitles
  /// later, negative earlier. Remembered per show/movie so a source's timing
  /// quirk stays corrected across episodes. Null reads as no offset.
  IntColumn get subtitleDelayMs => integer().nullable()();

  /// One row per scope.
  @override
  List<Set<Column>> get uniqueKeys => [
        {scopeType, scopeKey},
      ];
}

/// External subtitle files associated with a video: sidecars found next to it
/// during a scan, or files the user loaded by hand. Embedded subtitle tracks
/// live inside the video and aren't stored here — this is only for the separate
/// files that sit alongside it.
@DataClassName('SubtitleFileData')
class SubtitleFiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get mediaFileId => integer()
      .references(MediaFiles, #id, onDelete: KeyAction.cascade)();

  /// The subtitle file's stable handle: a SAF `content://` URI (or a plain path
  /// on platforms that use one).
  TextColumn get uri => text()();

  /// Language code parsed from the filename (`en`, `eng`), or null when the name
  /// carried none.
  TextColumn get languageCode => text().nullable()();

  IntColumn get source => intEnum<SubtitleSource>()();

  /// The one external subtitle the viewer last chose for this video, so
  /// reopening it re-activates exactly that track. At most one row per video is
  /// selected at a time.
  BoolColumn get selected => boolean().withDefault(const Constant(false))();

  /// One association per (video, subtitle file), so a rescan re-links rather
  /// than duplicates.
  @override
  List<Set<Column>> get uniqueKeys => [
        {mediaFileId, uri},
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
    PlaybackPrefs,
    SubtitleFiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database (Android/iOS). [executor] is injected by
  /// tests with an in-memory database.
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'halo'));

  @override
  int get schemaVersion => 8;

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
          // v4 adds the per-file "hidden" flag (Phase 3.4). Additive and
          // defaulted to false, so an existing library keeps every file visible.
          if (from < 4) {
            await m.addColumn(mediaFiles, mediaFiles.hidden);
          }
          // v5 adds sticky playback preferences (Phase 4.1). A new table only —
          // existing installs simply start with no preferences and learn them.
          if (from < 5) {
            await m.createTable(playbackPrefs);
          }
          // v6 adds external subtitle associations (Phase 4.1b). New table only;
          // the next scan populates sidecars for the existing library.
          if (from < 6) {
            await m.createTable(subtitleFiles);
          }
          // v7 adds the manual subtitle-timing offset (Phase 4.1b). Additive and
          // defaulted to no offset.
          if (from < 7) {
            await m.addColumn(playbackPrefs, playbackPrefs.subtitleDelayMs);
          }
          // v8 remembers which external subtitle was chosen per video, so it
          // re-activates automatically. Additive, defaulted to not-selected.
          if (from < 8) {
            await m.addColumn(subtitleFiles, subtitleFiles.selected);
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
