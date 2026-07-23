import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/repositories/metadata_repository.dart';
import '../../data/tmdb/tmdb_api.dart';
import '../../data/tmdb/tmdb_providers.dart';
import '../../data/tmdb/tmdb_result.dart';
import '../library/media_display.dart';
import 'metadata_image_cache.dart';
import 'metadata_keys.dart';
import 'metadata_matcher.dart';

/// How a manual match or refresh ended, so the UI can react appropriately —
/// most importantly, telling offline (retry later) apart from a real failure.
enum ManualMatchStatus {
  /// The chosen entry was fetched and stored.
  applied,

  /// No network. The caller shows a friendly "you're offline" message rather
  /// than a failure — these actions simply need connectivity.
  offline,

  /// No TMDB token configured, so nothing can be fetched.
  notConfigured,

  /// Nothing to refresh (the record has no TMDB id yet).
  nothingToRefresh,

  /// A non-network failure — a bad response, or the record vanished mid-flight.
  failed;

  /// A short line to show the user for this outcome.
  String get message => switch (this) {
        ManualMatchStatus.applied => 'Match updated.',
        ManualMatchStatus.offline =>
          'You’re offline — connect to the internet and try again.',
        ManualMatchStatus.notConfigured =>
          'No TMDB token configured, so metadata is unavailable.',
        ManualMatchStatus.nothingToRefresh => 'Nothing to refresh yet.',
        ManualMatchStatus.failed => 'Couldn’t update the match. Try again.',
      };
}

/// Applies user-chosen and user-requested metadata changes: correcting a wrong
/// match, and refreshing an existing one.
///
/// Every write here forces past the "manual outranks the scorer" guard and lands
/// as [MatchStatus.manual] (for a correction) or keeps the record's current
/// status (for a refresh). A later automatic sync then leaves it alone — that is
/// the whole point of manual control (see [MetadataRepository.saveMovieMatch]).
class ManualMatchService {
  ManualMatchService({
    required TmdbApi api,
    required MetadataRepository metadata,
    required LibraryRepository library,
    required MetadataImageCache cache,
  })  : _api = api,
        _metadata = metadata,
        _library = library,
        _cache = cache;

  final TmdbApi _api;
  final MetadataRepository _metadata;
  final LibraryRepository _library;
  final MetadataImageCache _cache;

  // --- Movies -------------------------------------------------------------

  /// Points [movieKey] at the TMDB film [tmdbId] the user chose, fetching its
  /// full record and artwork and marking the match manual.
  Future<ManualMatchStatus> applyMovieMatch(String movieKey, int tmdbId) {
    return _writeMovie(movieKey, tmdbId, status: MatchStatus.manual);
  }

  /// Re-fetches the film currently matched to [movieKey], keeping the existing
  /// match decision (a manual choice stays manual). No-op when nothing is
  /// matched yet — there's nothing to refresh.
  Future<ManualMatchStatus> refreshMovie(String movieKey) async {
    final record = await _metadata.movieByKey(movieKey);
    final tmdbId = record?.tmdbId;
    if (record == null || tmdbId == null) {
      return ManualMatchStatus.nothingToRefresh;
    }
    return _writeMovie(movieKey, tmdbId, status: record.matchStatus);
  }

  Future<ManualMatchStatus> _writeMovie(
    String movieKey,
    int tmdbId, {
    required MatchStatus status,
  }) async {
    if (!_api.hasToken) return ManualMatchStatus.notConfigured;

    final details = await _api.movieDetails(tmdbId);
    switch (details) {
      case TmdbFailure(:final kind):
        return _statusForFailure(kind);
      case TmdbSuccess(:final value):
        await _metadata.saveMovieMatch(
          movieKey,
          MovieMetadataCompanion(
            tmdbId: Value(value.id),
            title: Value(value.title),
            year: Value(value.year),
            overview: Value(value.overview),
            runtimeMs: Value(value.runtime?.inMilliseconds),
            voteAverage: Value(value.voteAverage),
            genres: Value(encodeGenres(value.genres)),
            posterPath: Value(value.posterPath),
            backdropPath: Value(value.backdropPath),
            // Drop the old local artwork so the new poster/backdrop are fetched
            // rather than the previous match's images lingering on screen.
            localPosterPath: const Value(null),
            localBackdropPath: const Value(null),
            matchConfidence: const Value(1),
            matchStatus: Value(status),
            lastRefreshed: Value(DateTime.now()),
          ),
          force: true,
        );
        await _cacheMovieImages(movieKey);
        return ManualMatchStatus.applied;
    }
  }

  Future<void> _cacheMovieImages(String movieKey) async {
    final record = await _metadata.movieByKey(movieKey);
    if (record == null) return;
    final images = _api.images;
    final poster = record.localPosterPath ??
        await _cache.ensureCached(images.poster(record.posterPath));
    final backdrop = record.localBackdropPath ??
        await _cache.ensureCached(images.backdrop(record.backdropPath));
    if (poster != null || backdrop != null) {
      await _metadata.saveMovieImages(
        movieKey,
        localPosterPath: poster,
        localBackdropPath: backdrop,
      );
    }
  }

  // --- Shows --------------------------------------------------------------

  /// Points [showKey] at the TMDB show [tmdbId] the user chose, fetching its
  /// record, the seasons the library actually has, artwork, and stills, and
  /// marking the match manual.
  Future<ManualMatchStatus> applyShowMatch(String showKey, int tmdbId) {
    return _writeShow(showKey, tmdbId, status: MatchStatus.manual);
  }

  /// Re-fetches the show currently matched to [showKey], keeping its match
  /// decision. No-op when nothing is matched yet.
  Future<ManualMatchStatus> refreshShow(String showKey) async {
    final record = await _metadata.showByKey(showKey);
    final tmdbId = record?.tmdbId;
    if (record == null || tmdbId == null) {
      return ManualMatchStatus.nothingToRefresh;
    }
    return _writeShow(showKey, tmdbId, status: record.matchStatus);
  }

  Future<ManualMatchStatus> _writeShow(
    String showKey,
    int tmdbId, {
    required MatchStatus status,
  }) async {
    if (!_api.hasToken) return ManualMatchStatus.notConfigured;

    final details = await _api.tvDetails(tmdbId);
    switch (details) {
      case TmdbFailure(:final kind):
        return _statusForFailure(kind);
      case TmdbSuccess(:final value):
        await _metadata.saveShowMatch(
          showKey,
          ShowMetadataCompanion(
            tmdbId: Value(value.id),
            name: Value(value.name),
            firstAirYear: Value(value.year),
            overview: Value(value.overview),
            genres: Value(encodeGenres(value.genres)),
            posterPath: Value(value.posterPath),
            backdropPath: Value(value.backdropPath),
            localPosterPath: const Value(null),
            localBackdropPath: const Value(null),
            matchConfidence: const Value(1),
            matchStatus: Value(status),
            lastRefreshed: Value(DateTime.now()),
          ),
          force: true,
        );

        final seasonOutcome = await _fetchSeasonsOnDisk(showKey, value.id);
        if (seasonOutcome == ManualMatchStatus.offline) {
          return ManualMatchStatus.offline;
        }
        await _cacheShowImages(showKey);
        await _cacheEpisodeStills();
        return ManualMatchStatus.applied;
    }
  }

  /// Fetches episode data for exactly the seasons of [showKey] the library
  /// holds — never a 20-season show when three are on disk.
  Future<ManualMatchStatus> _fetchSeasonsOnDisk(
    String showKey,
    int tmdbId,
  ) async {
    final episodes = await _library.watchMediaOfType(MediaType.episode).first;
    final seasons = <int>{
      for (final file in episodes)
        if (showKeyFor(file.displayTitle) == showKey && file.parsedSeason != null)
          file.parsedSeason!,
    };
    if (seasons.isEmpty) return ManualMatchStatus.applied;

    final matcher = MetadataMatcher(_api, _metadata);
    final stored = await _metadata.storedSeasons(tmdbId);
    for (final season in seasons.difference(stored)) {
      final outcome = await matcher.fetchSeason(tmdbId, season);
      if (outcome == MatchOutcome.offline) return ManualMatchStatus.offline;
    }
    return ManualMatchStatus.applied;
  }

  Future<void> _cacheShowImages(String showKey) async {
    final record = await _metadata.showByKey(showKey);
    if (record == null) return;
    final images = _api.images;
    final poster = record.localPosterPath ??
        await _cache.ensureCached(images.poster(record.posterPath));
    final backdrop = record.localBackdropPath ??
        await _cache.ensureCached(images.backdrop(record.backdropPath));
    if (poster != null || backdrop != null) {
      await _metadata.saveShowImages(
        showKey,
        localPosterPath: poster,
        localBackdropPath: backdrop,
      );
    }
  }

  Future<void> _cacheEpisodeStills() async {
    final images = _api.images;
    for (final episode in await _metadata.episodesNeedingStills()) {
      final still = await _cache.ensureCached(images.still(episode.stillPath));
      if (still != null) {
        await _metadata.saveEpisodeStill(episode.id, still);
      }
    }
  }

  /// A missing network is offline (retry later); everything else is a failure.
  static ManualMatchStatus _statusForFailure(TmdbFailureKind kind) {
    return switch (kind) {
      TmdbFailureKind.networkUnavailable ||
      TmdbFailureKind.timeout =>
        ManualMatchStatus.offline,
      TmdbFailureKind.unauthorized => ManualMatchStatus.notConfigured,
      _ => ManualMatchStatus.failed,
    };
  }
}

final manualMatchServiceProvider = Provider<ManualMatchService>((ref) {
  return ManualMatchService(
    api: ref.watch(tmdbApiProvider),
    metadata: ref.watch(metadataRepositoryProvider),
    library: ref.watch(libraryRepositoryProvider),
    cache: ref.watch(metadataImageCacheProvider),
  );
});
