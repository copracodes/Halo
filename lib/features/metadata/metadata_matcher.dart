import 'package:drift/drift.dart' show Value;

import '../../data/database/app_database.dart';
import '../../data/repositories/metadata_repository.dart';
import '../../data/tmdb/tmdb_api.dart';
import '../../data/tmdb/tmdb_result.dart';
import 'match_scoring.dart';

/// What a single match attempt did, so the orchestrator can report progress and
/// know whether to keep going.
enum MatchOutcome {
  matched,
  needsReview,
  unmatched,

  /// The network went away mid-pass. The orchestrator stops and tries again
  /// next time rather than marking everything unmatched.
  offline,

  /// A non-network failure for this one item; move on to the next.
  failed,
}

/// Connects parsed library titles to TMDB entries.
///
/// Search, score, decide — the decision itself lives in [MatchScorer] so it can
/// be reasoned about without a network. Anything at or above the threshold is
/// accepted as [MatchStatus.auto]; anything below is recorded as
/// [MatchStatus.needsReview] with its best guess kept, so 3.4's manual fixer
/// has somewhere to start rather than a blank slate.
class MetadataMatcher {
  const MetadataMatcher(
    this._api,
    this._repository, {
    MatchScorer scorer = const MatchScorer(),
  }) : _scorer = scorer;

  final TmdbApi _api;
  final MetadataRepository _repository;
  final MatchScorer _scorer;

  /// Matches one movie record. [parsedTitle] and [parsedYear] come from the
  /// filename parser.
  Future<MatchOutcome> matchMovie(
    String movieKey, {
    required String parsedTitle,
    int? parsedYear,
  }) async {
    final result = await _api.searchMovies(parsedTitle, year: parsedYear);

    switch (result) {
      case TmdbFailure(:final kind):
        return _outcomeForFailure(kind);
      case TmdbSuccess(:final value):
        final best = _scorer.best(
          value.results,
          parsedTitle: parsedTitle,
          parsedYear: parsedYear,
        );
        if (best == null) {
          await _repository.saveMovieMatch(
            movieKey,
            MovieMetadataCompanion(
              matchStatus: const Value(MatchStatus.unmatched),
              lastRefreshed: Value(DateTime.now()),
            ),
          );
          return MatchOutcome.unmatched;
        }

        final accepted = best.score >= MatchScorer.autoAcceptThreshold;
        // Below the threshold we still fetch nothing further — a guess isn't
        // worth a detail request — but we keep the candidate so review has a
        // starting point.
        if (!accepted) {
          await _repository.saveMovieMatch(
            movieKey,
            MovieMetadataCompanion(
              tmdbId: Value(best.candidate.id),
              title: Value(best.candidate.title),
              year: Value(best.candidate.year),
              posterPath: Value(best.candidate.posterPath),
              backdropPath: Value(best.candidate.backdropPath),
              matchConfidence: Value(best.score),
              matchStatus: const Value(MatchStatus.needsReview),
              lastRefreshed: Value(DateTime.now()),
            ),
          );
          return MatchOutcome.needsReview;
        }

        return _saveMovieDetails(movieKey, best);
    }
  }

  /// Fetches the full record for an accepted movie match and stores it.
  Future<MatchOutcome> _saveMovieDetails(
    String movieKey,
    ScoredCandidate best,
  ) async {
    final details = await _api.movieDetails(best.candidate.id);

    switch (details) {
      case TmdbFailure(:final kind):
        // The search succeeded, so a failure here is transient. Leave the
        // record pending so the next sync completes it.
        return _outcomeForFailure(kind);
      case TmdbSuccess(:final value):
        await _repository.saveMovieMatch(
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
            matchConfidence: Value(best.score),
            matchStatus: const Value(MatchStatus.auto),
            lastRefreshed: Value(DateTime.now()),
          ),
        );
        return MatchOutcome.matched;
    }
  }

  /// Matches one show record. Shows carry no parsed year, so the title does the
  /// work — see [MatchScorer].
  Future<MatchOutcome> matchShow(
    String showKey, {
    required String parsedTitle,
  }) async {
    final result = await _api.searchTv(parsedTitle);

    switch (result) {
      case TmdbFailure(:final kind):
        return _outcomeForFailure(kind);
      case TmdbSuccess(:final value):
        final best = _scorer.best(value.results, parsedTitle: parsedTitle);
        if (best == null) {
          await _repository.saveShowMatch(
            showKey,
            ShowMetadataCompanion(
              matchStatus: const Value(MatchStatus.unmatched),
              lastRefreshed: Value(DateTime.now()),
            ),
          );
          return MatchOutcome.unmatched;
        }

        if (best.score < MatchScorer.autoAcceptThreshold) {
          await _repository.saveShowMatch(
            showKey,
            ShowMetadataCompanion(
              tmdbId: Value(best.candidate.id),
              name: Value(best.candidate.title),
              firstAirYear: Value(best.candidate.year),
              posterPath: Value(best.candidate.posterPath),
              backdropPath: Value(best.candidate.backdropPath),
              matchConfidence: Value(best.score),
              matchStatus: const Value(MatchStatus.needsReview),
              lastRefreshed: Value(DateTime.now()),
            ),
          );
          return MatchOutcome.needsReview;
        }

        return _saveShowDetails(showKey, best);
    }
  }

  Future<MatchOutcome> _saveShowDetails(
    String showKey,
    ScoredCandidate best,
  ) async {
    final details = await _api.tvDetails(best.candidate.id);

    switch (details) {
      case TmdbFailure(:final kind):
        return _outcomeForFailure(kind);
      case TmdbSuccess(:final value):
        await _repository.saveShowMatch(
          showKey,
          ShowMetadataCompanion(
            tmdbId: Value(value.id),
            name: Value(value.name),
            firstAirYear: Value(value.year),
            overview: Value(value.overview),
            genres: Value(encodeGenres(value.genres)),
            posterPath: Value(value.posterPath),
            backdropPath: Value(value.backdropPath),
            matchConfidence: Value(best.score),
            matchStatus: const Value(MatchStatus.auto),
            lastRefreshed: Value(DateTime.now()),
          ),
        );
        return MatchOutcome.matched;
    }
  }

  /// Fetches and stores one season's episodes.
  ///
  /// Only ever called for seasons the library actually contains — fetching a
  /// 20-season show when three seasons are on disk would be 17 pointless
  /// requests against a rate-limited API.
  Future<MatchOutcome> fetchSeason(int showTmdbId, int seasonNumber) async {
    final result = await _api.seasonDetails(showTmdbId, seasonNumber);

    switch (result) {
      case TmdbFailure(:final kind):
        return _outcomeForFailure(kind);
      case TmdbSuccess(:final value):
        for (final episode in value.episodes) {
          await _repository.upsertEpisode(
            EpisodeMetadataCompanion.insert(
              showTmdbId: showTmdbId,
              season: seasonNumber,
              episode: episode.episodeNumber,
              name: Value(episode.name),
              overview: Value(episode.overview),
              airDate: Value(episode.airDate),
              stillPath: Value(episode.stillPath),
              runtimeMs: Value(episode.runtime?.inMilliseconds),
              lastRefreshed: Value(DateTime.now()),
            ),
          );
        }
        return MatchOutcome.matched;
    }
  }

  /// A missing network stops the whole pass; anything else is this item's
  /// problem alone.
  static MatchOutcome _outcomeForFailure(TmdbFailureKind kind) {
    return switch (kind) {
      TmdbFailureKind.networkUnavailable ||
      TmdbFailureKind.timeout =>
        MatchOutcome.offline,
      _ => MatchOutcome.failed,
    };
  }
}
