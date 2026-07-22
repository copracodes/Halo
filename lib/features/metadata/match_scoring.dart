import 'dart:math' as math;

import '../../data/tmdb/models/tmdb_search_result.dart';
import 'metadata_keys.dart';

/// A candidate paired with how well it matches what was parsed from disk.
class ScoredCandidate {
  const ScoredCandidate({
    required this.candidate,
    required this.score,
    required this.titleSimilarity,
    required this.yearScore,
  });

  final TmdbSearchResult candidate;

  /// Overall 0–1 confidence.
  final double score;

  /// Component scores, kept for the review UI in 3.4 to explain *why* a match
  /// was or wasn't accepted.
  final double titleSimilarity;
  final double yearScore;

  @override
  String toString() => 'ScoredCandidate(${candidate.title}, '
      '${score.toStringAsFixed(3)})';
}

/// Scores TMDB search results against what Halo parsed from a filename.
///
/// The weighting exists to answer one question well: a correct title with the
/// *wrong* year must lose to a correct title with the *right* year, even when
/// the wrong one is far more popular. Popularity is therefore only a
/// tiebreaker — it can reorder near-equal candidates but can never outweigh a
/// year mismatch.
class MatchScorer {
  const MatchScorer();

  /// Accept automatically at or above this. Chosen so an exact title with a
  /// matching year (~0.95) sails through, an exact title with no year to check
  /// (~0.93) is still trusted, and an exact title with a *contradicted* year
  /// (~0.67) is held back for review rather than guessed at.
  static const double autoAcceptThreshold = 0.80;

  // Weights when both years are known.
  static const double _titleWeight = 0.65;
  static const double _yearWeight = 0.30;
  static const double _popularityWeight = 0.05;

  /// With no year to compare, title similarity carries almost everything.
  static const double _titleOnlyWeight = 0.93;
  static const double _titleOnlyPopularityWeight = 0.07;

  /// Ranks [candidates] best first.
  List<ScoredCandidate> rank(
    List<TmdbSearchResult> candidates, {
    required String parsedTitle,
    int? parsedYear,
  }) {
    // Popularity is normalised across this result set, so the tiebreaker is
    // "most popular of these" rather than an absolute TMDB figure whose scale
    // varies wildly between queries.
    final maxPopularity = candidates.fold<double>(
      0,
      (best, c) => math.max(best, c.popularity),
    );

    final scored = candidates
        .map(
          (candidate) => _score(
            candidate,
            parsedTitle: parsedTitle,
            parsedYear: parsedYear,
            maxPopularity: maxPopularity,
          ),
        )
        .toList()
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        // Total order, so ranking never depends on result arrival order.
        return a.candidate.id.compareTo(b.candidate.id);
      });

    return scored;
  }

  /// The best candidate, or null when [candidates] is empty.
  ScoredCandidate? best(
    List<TmdbSearchResult> candidates, {
    required String parsedTitle,
    int? parsedYear,
  }) =>
      rank(candidates, parsedTitle: parsedTitle, parsedYear: parsedYear)
          .firstOrNull;

  ScoredCandidate _score(
    TmdbSearchResult candidate, {
    required String parsedTitle,
    required int? parsedYear,
    required double maxPopularity,
  }) {
    // Compare against both the localised and the original title; a release
    // named for either one is still the right film.
    final similarity = math.max(
      titleSimilarity(parsedTitle, candidate.title),
      candidate.originalTitle == null
          ? 0.0
          : titleSimilarity(parsedTitle, candidate.originalTitle!),
    );

    final candidateYear = candidate.year;
    final bothYearsKnown = parsedYear != null && candidateYear != null;
    final year = bothYearsKnown ? yearScore(parsedYear, candidateYear) : 0.0;

    final popularity =
        maxPopularity <= 0 ? 0.0 : candidate.popularity / maxPopularity;

    final score = bothYearsKnown
        ? similarity * _titleWeight +
            year * _yearWeight +
            popularity * _popularityWeight
        : similarity * _titleOnlyWeight +
            popularity * _titleOnlyPopularityWeight;

    return ScoredCandidate(
      candidate: candidate,
      score: score.clamp(0.0, 1.0),
      titleSimilarity: similarity,
      yearScore: year,
    );
  }
}

/// How close two years are, 0–1.
///
/// Adjacent years score well because a release date and a rip's label often
/// straddle a new year; two years out is weak; further is worthless. A wrong
/// year is a strong signal that this is a different film with the same name.
double yearScore(int parsed, int candidate) {
  final difference = (parsed - candidate).abs();
  return switch (difference) {
    0 => 1.0,
    1 => 0.6,
    2 => 0.25,
    _ => 0.0,
  };
}

/// Similarity of two titles, 0–1, after normalisation.
///
/// Uses edit distance over the normalised forms, so "Spider-Man" and
/// "spider man" are identical, while "Dune" and "Dune: Part Two" are close but
/// clearly distinguishable.
double titleSimilarity(String a, String b) {
  final left = normalizeTitle(a);
  final right = normalizeTitle(b);
  if (left.isEmpty || right.isEmpty) return 0;
  if (left == right) return 1;

  final distance = _levenshtein(left, right);
  final longest = math.max(left.length, right.length);
  return ((longest - distance) / longest).clamp(0.0, 1.0);
}

/// Standard Levenshtein distance, two rows at a time so memory stays O(n)
/// rather than O(n·m) — titles are short, but this runs per candidate per file.
int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var previous = List<int>.generate(b.length + 1, (i) => i);
  var current = List<int>.filled(b.length + 1, 0);

  for (var i = 0; i < a.length; i++) {
    current[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final substitution = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
      current[j + 1] = math.min(
        math.min(current[j] + 1, previous[j + 1] + 1),
        previous[j] + substitution,
      );
    }
    final swap = previous;
    previous = current;
    current = swap;
  }

  return previous[b.length];
}
