import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// Reads and writes TMDB metadata. Features watch its streams and call these
/// methods; they never touch the database directly.
class MetadataRepository {
  const MetadataRepository(this._db);

  final AppDatabase _db;

  // --- Movies -------------------------------------------------------------

  Stream<List<MovieMetadataData>> watchMovies() =>
      _db.select(_db.movieMetadata).watch();

  /// Metadata by movie key, for the grids to look up per card.
  Stream<Map<String, MovieMetadataData>> watchMoviesByKey() =>
      watchMovies().map(
        (rows) => {for (final row in rows) row.movieKey: row},
      );

  Future<MovieMetadataData?> movieByKey(String movieKey) =>
      (_db.select(_db.movieMetadata)
            ..where((m) => m.movieKey.equals(movieKey)))
          .getSingleOrNull();

  /// Creates a placeholder record for [movieKey] if none exists, so a scan can
  /// enqueue work without deciding anything about the match yet.
  Future<void> ensureMoviePending(String movieKey) async {
    // INSERT OR IGNORE: enqueueing runs on every scan, and re-enqueueing an
    // existing title must be a no-op rather than a constraint violation.
    await _db.into(_db.movieMetadata).insert(
          MovieMetadataCompanion.insert(movieKey: movieKey),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Writes the outcome of a match attempt.
  ///
  /// Refuses to overwrite a [MatchStatus.manual] record: a human decision
  /// outranks anything the scorer produces on a later pass.
  Future<void> saveMovieMatch(
    String movieKey,
    MovieMetadataCompanion values, {
    bool force = false,
  }) async {
    if (!force) {
      final existing = await movieByKey(movieKey);
      if (existing != null && !isAutoWritable(existing.matchStatus)) return;
    }
    await (_db.update(_db.movieMetadata)
          ..where((m) => m.movieKey.equals(movieKey)))
        .write(values);
  }

  /// Movie records a match pass should look at.
  ///
  /// An automatic pass takes only [MatchStatus.pending], so a title TMDB has
  /// already rejected isn't re-queried on every scan. [includeFailed] adds the
  /// previously unmatched and needs-review records — what an explicit "sync
  /// now" from the user should retry, since they may have just fixed a
  /// filename. Manual matches are never included either way.
  Future<List<MovieMetadataData>> moviesNeedingMatch({
    bool includeFailed = false,
  }) {
    return (_db.select(_db.movieMetadata)
          ..where(
            (m) => includeFailed
                ? m.matchStatus.equalsValue(MatchStatus.pending) |
                    m.matchStatus.equalsValue(MatchStatus.unmatched) |
                    m.matchStatus.equalsValue(MatchStatus.needsReview)
                : m.matchStatus.equalsValue(MatchStatus.pending),
          ))
        .get();
  }

  /// Matched movies whose artwork hasn't been downloaded yet.
  Future<List<MovieMetadataData>> moviesNeedingImages() {
    return (_db.select(_db.movieMetadata)
          ..where(
            (m) =>
                m.tmdbId.isNotNull() &
                (m.localPosterPath.isNull() | m.localBackdropPath.isNull()),
          ))
        .get();
  }

  Future<void> saveMovieImages(
    String movieKey, {
    String? localPosterPath,
    String? localBackdropPath,
  }) {
    return (_db.update(_db.movieMetadata)
          ..where((m) => m.movieKey.equals(movieKey)))
        .write(
      MovieMetadataCompanion(
        localPosterPath: Value.absentIfNull(localPosterPath),
        localBackdropPath: Value.absentIfNull(localBackdropPath),
      ),
    );
  }

  // --- Shows --------------------------------------------------------------

  Stream<List<ShowMetadataData>> watchShows() =>
      _db.select(_db.showMetadata).watch();

  Stream<Map<String, ShowMetadataData>> watchShowsByKey() => watchShows().map(
        (rows) => {for (final row in rows) row.showKey: row},
      );

  Future<ShowMetadataData?> showByKey(String showKey) =>
      (_db.select(_db.showMetadata)..where((s) => s.showKey.equals(showKey)))
          .getSingleOrNull();

  Future<void> ensureShowPending(String showKey) async {
    await _db.into(_db.showMetadata).insert(
          ShowMetadataCompanion.insert(showKey: showKey),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> saveShowMatch(
    String showKey,
    ShowMetadataCompanion values, {
    bool force = false,
  }) async {
    if (!force) {
      final existing = await showByKey(showKey);
      if (existing != null && !isAutoWritable(existing.matchStatus)) return;
    }
    await (_db.update(_db.showMetadata)
          ..where((s) => s.showKey.equals(showKey)))
        .write(values);
  }

  /// See [moviesNeedingMatch] for what [includeFailed] means.
  Future<List<ShowMetadataData>> showsNeedingMatch({
    bool includeFailed = false,
  }) {
    return (_db.select(_db.showMetadata)
          ..where(
            (s) => includeFailed
                ? s.matchStatus.equalsValue(MatchStatus.pending) |
                    s.matchStatus.equalsValue(MatchStatus.unmatched) |
                    s.matchStatus.equalsValue(MatchStatus.needsReview)
                : s.matchStatus.equalsValue(MatchStatus.pending),
          ))
        .get();
  }

  Future<List<ShowMetadataData>> showsNeedingImages() {
    return (_db.select(_db.showMetadata)
          ..where(
            (s) =>
                s.tmdbId.isNotNull() &
                (s.localPosterPath.isNull() | s.localBackdropPath.isNull()),
          ))
        .get();
  }

  Future<void> saveShowImages(
    String showKey, {
    String? localPosterPath,
    String? localBackdropPath,
  }) {
    return (_db.update(_db.showMetadata)
          ..where((s) => s.showKey.equals(showKey)))
        .write(
      ShowMetadataCompanion(
        localPosterPath: Value.absentIfNull(localPosterPath),
        localBackdropPath: Value.absentIfNull(localBackdropPath),
      ),
    );
  }

  /// All matched shows, for deciding which seasons still need fetching.
  Future<List<ShowMetadataData>> matchedShows() {
    return (_db.select(_db.showMetadata)..where((s) => s.tmdbId.isNotNull()))
        .get();
  }

  // --- Episodes -----------------------------------------------------------

  Stream<List<EpisodeMetadataData>> watchEpisodesForShow(int showTmdbId) {
    return (_db.select(_db.episodeMetadata)
          ..where((e) => e.showTmdbId.equals(showTmdbId))
          ..orderBy([
            (e) => OrderingTerm.asc(e.season),
            (e) => OrderingTerm.asc(e.episode),
          ]))
        .watch();
  }

  Future<void> upsertEpisode(EpisodeMetadataCompanion values) {
    return _db.into(_db.episodeMetadata).insert(
          values,
          onConflict: DoUpdate(
            (_) => values,
            target: [
              _db.episodeMetadata.showTmdbId,
              _db.episodeMetadata.season,
              _db.episodeMetadata.episode,
            ],
          ),
        );
  }

  /// Which seasons of [showTmdbId] already have episodes stored, so a sync
  /// fetches each season once rather than on every pass.
  Future<Set<int>> storedSeasons(int showTmdbId) async {
    final rows = await (_db.selectOnly(_db.episodeMetadata, distinct: true)
          ..addColumns([_db.episodeMetadata.season])
          ..where(_db.episodeMetadata.showTmdbId.equals(showTmdbId)))
        .get();
    return rows
        .map((row) => row.read(_db.episodeMetadata.season))
        .whereType<int>()
        .toSet();
  }

  Future<List<EpisodeMetadataData>> episodesNeedingStills() {
    return (_db.select(_db.episodeMetadata)
          ..where((e) => e.stillPath.isNotNull() & e.localStillPath.isNull()))
        .get();
  }

  Future<void> saveEpisodeStill(int id, String localStillPath) {
    return (_db.update(_db.episodeMetadata)..where((e) => e.id.equals(id)))
        .write(EpisodeMetadataCompanion(
      localStillPath: Value(localStillPath),
    ));
  }
}

/// Genres are stored as a JSON array in one column — they are only ever read
/// and displayed whole, so a join table would buy nothing.
String encodeGenres(List<String> genres) => jsonEncode(genres);

List<String> decodeGenres(String? encoded) {
  if (encoded == null || encoded.isEmpty) return const [];
  try {
    final decoded = jsonDecode(encoded);
    if (decoded is! List) return const [];
    return decoded.whereType<String>().toList();
  } on FormatException {
    return const [];
  }
}

final metadataRepositoryProvider = Provider<MetadataRepository>((ref) {
  return MetadataRepository(ref.watch(appDatabaseProvider));
});
