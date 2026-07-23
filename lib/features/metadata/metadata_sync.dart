import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/repositories/metadata_repository.dart';
import '../../data/tmdb/tmdb_images.dart';
import '../../data/tmdb/tmdb_providers.dart';
import '../../data/tmdb/tmdb_result.dart';
import '../library/media_display.dart';
import 'metadata_image_cache.dart';
import 'metadata_keys.dart';
import 'metadata_matcher.dart';

/// How a sync ended, for the UI and for deciding whether to try again.
enum SyncOutcome {
  /// Never run this session.
  idle,

  /// Finished the queue.
  completed,

  /// Nothing to do.
  nothingToDo,

  /// No network. Deliberately silent: offline is a normal state, not a fault.
  skippedOffline,

  /// No TMDB token configured.
  notConfigured,

  /// A token is set but TMDB rejected it (invalid or expired). Surfaced once so
  /// the user can fix their configuration; the pass stops rather than retrying.
  tokenRejected,

  /// Stopped early by [MetadataSyncController.cancel] or provider disposal.
  cancelled;

  /// What to tell the user when they asked for this explicitly.
  ///
  /// A sync that found nothing to do has to *say so*: silence is
  /// indistinguishable from a broken button, which is exactly how this was
  /// first reported.
  String get message => switch (this) {
        SyncOutcome.idle => 'Ready.',
        SyncOutcome.completed => 'Metadata updated.',
        SyncOutcome.nothingToDo => 'Everything is already up to date.',
        SyncOutcome.skippedOffline =>
          'No connection — metadata will sync next time you’re online.',
        SyncOutcome.notConfigured =>
          'No TMDB token configured, so metadata is unavailable.',
        SyncOutcome.tokenRejected =>
          'Your TMDB token was rejected — it may be invalid or expired. '
              'Update it to fetch metadata.',
        SyncOutcome.cancelled => 'Sync stopped.',
      };
}

/// Live progress of a metadata sync.
class MetadataSyncState {
  const MetadataSyncState({
    this.running = false,
    this.completed = 0,
    this.total = 0,
    this.outcome = SyncOutcome.idle,
  });

  final bool running;

  /// Work items finished and expected. Both zero when nothing is queued.
  final int completed;
  final int total;

  final SyncOutcome outcome;

  /// 0–1, or null when the total isn't known yet — an indeterminate spinner is
  /// the honest rendering then.
  double? get progress {
    if (!running || total <= 0) return null;
    return (completed / total).clamp(0.0, 1.0);
  }

  MetadataSyncState copyWith({
    bool? running,
    int? completed,
    int? total,
    SyncOutcome? outcome,
  }) {
    return MetadataSyncState(
      running: running ?? this.running,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      outcome: outcome ?? this.outcome,
    );
  }
}

/// Orchestrates enrichment: enqueue what the scan found, match it, fetch the
/// seasons the library actually has, and cache the artwork.
///
/// Three properties matter more than speed here:
///
/// * **Offline is silent.** A missing network ends the pass without touching
///   any record, so nothing is marked unmatched just because the wifi was off,
///   and the next run picks up exactly where this one stopped.
/// * **Cancel-safe.** The flag is checked between every item and on provider
///   disposal, so leaving the app can't leave a half-written record.
/// * **Resumable.** Every step is idempotent — already-matched records and
///   already-downloaded images are skipped — so re-running costs almost
///   nothing.
class MetadataSyncController extends Notifier<MetadataSyncState> {
  bool _cancelled = false;
  bool _running = false;

  @override
  MetadataSyncState build() {
    // Leaving the screen (or the app) stops the pass rather than letting it
    // write into a disposed provider's dependencies.
    ref.onDispose(() => _cancelled = true);
    return const MetadataSyncState();
  }

  /// Requests that an in-flight sync stop at the next item boundary.
  void cancel() => _cancelled = true;

  /// Runs a full pass. Safe to call repeatedly; concurrent calls are ignored.
  ///
  /// [retryFailed] re-attempts titles TMDB previously rejected or scored too
  /// low. Automatic passes leave those alone so every scan doesn't re-query
  /// hopeless titles, but an explicit "sync now" from the user should try
  /// again — they may have just corrected a filename.
  Future<void> syncNow({bool retryFailed = false}) async {
    if (_running) return;
    _running = true;
    _cancelled = false;

    final api = ref.read(tmdbApiProvider);
    if (!api.hasToken) {
      _finish(SyncOutcome.notConfigured);
      return;
    }

    state = const MetadataSyncState(running: true, outcome: SyncOutcome.idle);

    try {
      await _enqueueFromLibrary();

      final movies =
          await _metadata.moviesNeedingMatch(includeFailed: retryFailed);
      final shows =
          await _metadata.showsNeedingMatch(includeFailed: retryFailed);
      if (movies.isEmpty && shows.isEmpty) {
        // Still worth a pass for artwork the last run couldn't fetch.
        final outcome = await _syncImages(expectWork: false);
        _finish(outcome);
        return;
      }

      // One probe before doing anything: if the device is offline, or the token
      // is rejected, stop now rather than failing item by item. `/configuration`
      // needs auth, so it's the single choke point that catches a bad token
      // before a whole library's worth of requests do — no crash loop.
      final configuration = await api.loadConfiguration();
      if (configuration case TmdbFailure(:final kind)) {
        if (kind == TmdbFailureKind.networkUnavailable ||
            kind == TmdbFailureKind.timeout) {
          _finish(SyncOutcome.skippedOffline);
          return;
        }
        if (kind == TmdbFailureKind.unauthorized) {
          _finish(SyncOutcome.tokenRejected);
          return;
        }
      }

      state = state.copyWith(total: movies.length + shows.length);

      final matchOutcome = await _matchAll(movies, shows);
      if (matchOutcome != null) {
        _finish(matchOutcome);
        return;
      }

      if (_cancelled) {
        _finish(SyncOutcome.cancelled);
        return;
      }

      final seasonOutcome = await _syncSeasons();
      if (seasonOutcome != null) {
        _finish(seasonOutcome);
        return;
      }

      _finish(await _syncImages(expectWork: true));
    } on Object {
      // Enrichment must never take the app down with it.
      _finish(SyncOutcome.completed);
    }
  }

  MetadataRepository get _metadata => ref.read(metadataRepositoryProvider);

  /// Creates pending records for everything the library contains, so matching
  /// has a queue to work through. Idempotent — existing records are untouched.
  Future<void> _enqueueFromLibrary() async {
    final library = ref.read(libraryRepositoryProvider);
    final movies = await library.watchMediaOfType(MediaType.movie).first;
    final episodes = await library.watchMediaOfType(MediaType.episode).first;

    for (final key in _movieKeys(movies).keys) {
      await _metadata.ensureMoviePending(key);
    }
    for (final key in _showKeys(episodes).keys) {
      await _metadata.ensureShowPending(key);
    }
  }

  /// Movie key → the parsed title and year it was built from. Files that share
  /// a key collapse into one entry, which is the whole point: one record, one
  /// request, one poster for every quality of the same film.
  Map<String, ({String title, int? year})> _movieKeys(List<MediaFile> files) {
    final keys = <String, ({String title, int? year})>{};
    for (final file in files) {
      final title = file.displayTitle;
      if (title.isEmpty) continue;
      keys.putIfAbsent(
        movieKeyFor(title, file.parsedYear),
        () => (title: title, year: file.parsedYear),
      );
    }
    return keys;
  }

  Map<String, String> _showKeys(List<MediaFile> files) {
    final keys = <String, String>{};
    for (final file in files) {
      final title = file.displayTitle;
      if (title.isEmpty) continue;
      keys.putIfAbsent(showKeyFor(title), () => title);
    }
    return keys;
  }

  /// Returns a terminal outcome if the pass should stop, or null to continue.
  Future<SyncOutcome?> _matchAll(
    List<MovieMetadataData> movies,
    List<ShowMetadataData> shows,
  ) async {
    final library = ref.read(libraryRepositoryProvider);
    final matcher = MetadataMatcher(ref.read(tmdbApiProvider), _metadata);

    final movieSources =
        _movieKeys(await library.watchMediaOfType(MediaType.movie).first);
    final showSources =
        _showKeys(await library.watchMediaOfType(MediaType.episode).first);

    for (final movie in movies) {
      if (_cancelled) return SyncOutcome.cancelled;
      final source = movieSources[movie.movieKey];
      if (source == null) continue;

      final outcome = await matcher.matchMovie(
        movie.movieKey,
        parsedTitle: source.title,
        parsedYear: source.year,
      );
      final terminal = _terminalFor(outcome);
      if (terminal != null) return terminal;
      _advance();
    }

    for (final show in shows) {
      if (_cancelled) return SyncOutcome.cancelled;
      final title = showSources[show.showKey];
      if (title == null) continue;

      final outcome = await matcher.matchShow(show.showKey, parsedTitle: title);
      final terminal = _terminalFor(outcome);
      if (terminal != null) return terminal;
      _advance();
    }

    return null;
  }

  /// Maps a per-item outcome that must stop the whole pass to its sync outcome,
  /// or null to keep going. Offline and a rejected token are pass-wide: every
  /// remaining item would hit the same wall.
  static SyncOutcome? _terminalFor(MatchOutcome outcome) {
    return switch (outcome) {
      MatchOutcome.offline => SyncOutcome.skippedOffline,
      MatchOutcome.unauthorized => SyncOutcome.tokenRejected,
      _ => null,
    };
  }

  /// Fetches episode data for the seasons present on disk, and only those.
  Future<SyncOutcome?> _syncSeasons() async {
    final library = ref.read(libraryRepositoryProvider);
    final matcher = MetadataMatcher(ref.read(tmdbApiProvider), _metadata);

    final episodes = await library.watchMediaOfType(MediaType.episode).first;
    final wanted = <String, Set<int>>{};
    for (final file in episodes) {
      final season = file.parsedSeason;
      if (season == null) continue;
      wanted.putIfAbsent(showKeyFor(file.displayTitle), () => <int>{}).add(season);
    }

    for (final show in await _metadata.matchedShows()) {
      final tmdbId = show.tmdbId;
      if (tmdbId == null) continue;
      final seasons = wanted[show.showKey];
      if (seasons == null || seasons.isEmpty) continue;

      final stored = await _metadata.storedSeasons(tmdbId);
      for (final season in seasons.difference(stored)) {
        if (_cancelled) return SyncOutcome.cancelled;
        final outcome = await matcher.fetchSeason(tmdbId, season);
        final terminal = _terminalFor(outcome);
        if (terminal != null) return terminal;
      }
    }

    return null;
  }

  /// Downloads artwork for everything matched, skipping what is already on
  /// disk. The UI reads only these local files.
  Future<SyncOutcome> _syncImages({required bool expectWork}) async {
    final cache = ref.read(metadataImageCacheProvider);
    final images = ref.read(tmdbApiProvider).images;

    var didWork = false;

    for (final movie in await _metadata.moviesNeedingImages()) {
      if (_cancelled) return SyncOutcome.cancelled;
      final poster = movie.localPosterPath ??
          await cache.ensureCached(images.poster(movie.posterPath));
      final backdrop = movie.localBackdropPath ??
          await cache.ensureCached(images.backdrop(movie.backdropPath));
      if (poster != null || backdrop != null) {
        await _metadata.saveMovieImages(
          movie.movieKey,
          localPosterPath: poster,
          localBackdropPath: backdrop,
        );
        didWork = true;
      }
    }

    for (final show in await _metadata.showsNeedingImages()) {
      if (_cancelled) return SyncOutcome.cancelled;
      final poster = show.localPosterPath ??
          await cache.ensureCached(images.poster(show.posterPath));
      final backdrop = show.localBackdropPath ??
          await cache.ensureCached(images.backdrop(show.backdropPath));
      if (poster != null || backdrop != null) {
        await _metadata.saveShowImages(
          show.showKey,
          localPosterPath: poster,
          localBackdropPath: backdrop,
        );
        didWork = true;
      }
    }

    for (final episode in await _metadata.episodesNeedingStills()) {
      if (_cancelled) return SyncOutcome.cancelled;
      final still = await cache.ensureCached(images.still(episode.stillPath));
      if (still != null) {
        await _metadata.saveEpisodeStill(episode.id, still);
        didWork = true;
      }
    }

    if (!expectWork && !didWork) return SyncOutcome.nothingToDo;
    return SyncOutcome.completed;
  }

  void _advance() {
    state = state.copyWith(completed: state.completed + 1);
  }

  void _finish(SyncOutcome outcome) {
    _running = false;
    state = MetadataSyncState(
      running: false,
      completed: state.completed,
      total: state.total,
      outcome: outcome,
    );
  }
}

final metadataSyncProvider =
    NotifierProvider<MetadataSyncController, MetadataSyncState>(
  MetadataSyncController.new,
);

/// Metadata keyed for lookup by the grids (3.3 will consume these).
final movieMetadataByKeyProvider =
    StreamProvider<Map<String, MovieMetadataData>>((ref) {
  return ref.watch(metadataRepositoryProvider).watchMoviesByKey();
});

final showMetadataByKeyProvider =
    StreamProvider<Map<String, ShowMetadataData>>((ref) {
  return ref.watch(metadataRepositoryProvider).watchShowsByKey();
});

/// Re-exported so callers don't need the tmdb layer directly.
TmdbImages tmdbImagesOf(Ref ref) => ref.read(tmdbApiProvider).images;
