// The matcher's judgement, in isolation from TMDB and the database.
//
// The case that drives the whole weighting: a correct title with the *wrong*
// year must lose to a correct title with the *right* year, however much more
// popular the wrong one is. Popularity may only break near-ties.

import 'package:flutter_test/flutter_test.dart';

import 'package:halo/data/tmdb/models/tmdb_search_result.dart';
import 'package:halo/features/metadata/match_scoring.dart';
import 'package:halo/features/metadata/metadata_keys.dart';

TmdbSearchResult candidate(
  String title, {
  int? year,
  double popularity = 1,
  int id = 0,
  String? originalTitle,
}) {
  return TmdbSearchResult(
    id: id,
    title: title,
    isMovie: true,
    originalTitle: originalTitle,
    popularity: popularity,
    releaseDate: year == null ? null : DateTime(year, 6, 1),
  );
}

void main() {
  const scorer = MatchScorer();

  group('title + year beats popular-but-wrong-year', () {
    test('the right year wins even when the wrong year is far more popular',
        () {
      final results = [
        candidate('Dune', year: 1984, popularity: 500, id: 1),
        candidate('Dune', year: 2021, popularity: 5, id: 2),
      ];

      final best = scorer.best(results, parsedTitle: 'Dune', parsedYear: 2021)!;

      expect(best.candidate.id, 2);
      expect(best.candidate.year, 2021);
      expect(best.score, greaterThanOrEqualTo(MatchScorer.autoAcceptThreshold));
    });

    test('an exact title with a contradicted year is held for review', () {
      final results = [candidate('Dune', year: 1984, popularity: 900)];

      final best = scorer.best(results, parsedTitle: 'Dune', parsedYear: 2021)!;

      expect(best.titleSimilarity, 1.0);
      expect(best.yearScore, 0.0);
      expect(
        best.score,
        lessThan(MatchScorer.autoAcceptThreshold),
        reason: 'a wrong year means it is probably a different film',
      );
    });

    test('popularity cannot lift a wrong year over the threshold', () {
      // The most popular possible candidate, still with the wrong year.
      final results = [candidate('Dune', year: 1984, popularity: 1000000)];

      final best = scorer.best(results, parsedTitle: 'Dune', parsedYear: 2021)!;

      expect(best.score, lessThan(MatchScorer.autoAcceptThreshold));
    });

    test('popularity breaks a tie between otherwise equal candidates', () {
      final results = [
        candidate('The Thing', year: 2011, popularity: 10, id: 1),
        candidate('The Thing', year: 2011, popularity: 90, id: 2),
      ];

      final best =
          scorer.best(results, parsedTitle: 'The Thing', parsedYear: 2011)!;

      expect(best.candidate.id, 2);
    });
  });

  group('thresholds', () {
    test('an exact title and year is accepted automatically', () {
      final best = scorer.best(
        [candidate('Arrival', year: 2016)],
        parsedTitle: 'Arrival',
        parsedYear: 2016,
      )!;

      expect(best.score, greaterThanOrEqualTo(MatchScorer.autoAcceptThreshold));
    });

    test('an exact title with no year to check is still accepted', () {
      // Most TV shows and plenty of movie files have no parsable year; holding
      // all of them for review would make the feature useless.
      final best = scorer.best(
        [candidate('Westworld', year: 2016)],
        parsedTitle: 'Westworld',
      )!;

      expect(best.score, greaterThanOrEqualTo(MatchScorer.autoAcceptThreshold));
    });

    test('an adjacent year is tolerated, since rips straddle release dates',
        () {
      final best = scorer.best(
        [candidate('Nobody', year: 2021)],
        parsedTitle: 'Nobody',
        parsedYear: 2020,
      )!;

      expect(best.yearScore, 0.6);
      expect(best.score, greaterThan(0.6));
    });

    test('an unrelated title is nowhere near acceptance', () {
      final best = scorer.best(
        [candidate('Paddington', year: 2014)],
        parsedTitle: 'Interstellar',
        parsedYear: 2014,
      )!;

      expect(best.score, lessThan(MatchScorer.autoAcceptThreshold));
    });

    test('no candidates yields no best', () {
      expect(scorer.best([], parsedTitle: 'Anything'), isNull);
    });
  });

  group('title similarity', () {
    test('ignores punctuation and case differences', () {
      expect(titleSimilarity('spider-man', 'Spider Man'), 1.0);
      expect(titleSimilarity('THE.MATRIX', 'The Matrix'), 1.0);
      expect(titleSimilarity('WALL·E', 'WALL·E'), 1.0);
    });

    test('treats & and "and" alike', () {
      expect(titleSimilarity('Fire & Blood', 'Fire and Blood'), 1.0);
    });

    test('distinguishes a sequel from its parent', () {
      final exact = titleSimilarity('Dune', 'Dune');
      final sequel = titleSimilarity('Dune', 'Dune: Part Two');
      expect(sequel, lessThan(exact));
    });

    test('matches against the original title when the localised one differs',
        () {
      final best = const MatchScorer().best(
        [candidate('The Wandering Earth', originalTitle: '流浪地球', year: 2019)],
        parsedTitle: 'The Wandering Earth',
        parsedYear: 2019,
      )!;

      expect(best.titleSimilarity, 1.0);
    });

    test('empty titles score zero rather than dividing by zero', () {
      expect(titleSimilarity('', 'Dune'), 0);
      expect(titleSimilarity('Dune', ''), 0);
    });
  });

  group('ranking is deterministic', () {
    test('identical scores order by id, not by arrival order', () {
      final results = [
        candidate('Twin', year: 2000, popularity: 5, id: 7),
        candidate('Twin', year: 2000, popularity: 5, id: 3),
      ];

      final forwards = scorer.rank(results, parsedTitle: 'Twin', parsedYear: 2000);
      final backwards = scorer.rank(
        results.reversed.toList(),
        parsedTitle: 'Twin',
        parsedYear: 2000,
      );

      expect(forwards.first.candidate.id, 3);
      expect(
        backwards.map((s) => s.candidate.id),
        forwards.map((s) => s.candidate.id),
      );
    });
  });

  group('metadata keys', () {
    test('identical title and year share one movie key', () {
      // The multi-quality case: two rips, one metadata record, one card.
      expect(
        movieKeyFor('Dune', 2021),
        movieKeyFor('dune', 2021),
      );
      expect(
        movieKeyFor('The.Matrix', 1999),
        movieKeyFor('The Matrix', 1999),
      );
    });

    test('a remake keeps its own key', () {
      expect(movieKeyFor('Dune', 2021), isNot(movieKeyFor('Dune', 1984)));
    });

    test('a missing year does not collide with a known one', () {
      expect(movieKeyFor('Dune', null), isNot(movieKeyFor('Dune', 2021)));
    });

    test('show keys normalise the same way', () {
      expect(showKeyFor('Breaking Bad'), showKeyFor('breaking.bad'));
      expect(showKeyFor('Westworld'), isNot(showKeyFor('World West')));
    });
  });
}
