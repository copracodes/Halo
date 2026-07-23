// The matcher and the sync orchestration against an in-memory database and a
// mocked TMDB, covering the two behaviours that are easy to get wrong:
// multi-quality files collapsing into one metadata record, and a sync going
// quiet rather than destructive when the device is offline.

import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/data/repositories/library_repository.dart';
import 'package:halo/data/repositories/metadata_repository.dart';
import 'package:halo/data/tmdb/tmdb_api.dart';
import 'package:halo/data/tmdb/tmdb_client.dart';
import 'package:halo/features/metadata/metadata_keys.dart';
import 'package:halo/features/metadata/metadata_matcher.dart';

/// A TMDB stood up from canned responses, keyed by the path each request hits.
TmdbApi apiFrom(
  Map<String, Object> byPath, {
  List<Uri>? record,
  bool offline = false,
}) {
  final client = TmdbClient(
    token: 'test-token',
    delay: (_) async {},
    httpClient: MockClient((request) async {
      record?.add(request.url);
      if (offline) throw const SocketException('Failed host lookup');
      for (final entry in byPath.entries) {
        if (request.url.path.endsWith(entry.key)) {
          return http.Response(jsonEncode(entry.value), 200);
        }
      }
      return http.Response('{}', 404);
    }),
  );
  return TmdbApi(client);
}

/// A TMDB whose every request is rejected with 401 — a bad or expired token.
TmdbApi apiRejectingToken() {
  final client = TmdbClient(
    token: 'stale-token',
    delay: (_) async {},
    httpClient: MockClient((_) async => http.Response('{}', 401)),
  );
  return TmdbApi(client);
}

const _duneSearch = {
  'results': [
    {
      'id': 438631,
      'title': 'Dune',
      'release_date': '2021-09-15',
      'poster_path': '/dune.jpg',
      'popularity': 100.0,
    },
    {
      'id': 841,
      'title': 'Dune',
      'release_date': '1984-12-14',
      'poster_path': '/dune84.jpg',
      'popularity': 900.0,
    },
  ],
};

const _duneDetails = {
  'id': 438631,
  'title': 'Dune',
  'release_date': '2021-09-15',
  'overview': 'Paul Atreides arrives on Arrakis.',
  'runtime': 155,
  'vote_average': 7.8,
  'genres': [
    {'id': 878, 'name': 'Science Fiction'},
  ],
  'poster_path': '/dune.jpg',
  'backdrop_path': '/dunebd.jpg',
};

void main() {
  late AppDatabase db;
  late LibraryRepository library;
  late MetadataRepository metadata;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    library = LibraryRepository(db);
    metadata = MetadataRepository(db);
  });

  tearDown(() async => db.close());

  /// Indexes [fileName] as a movie under a library folder.
  Future<void> addMovie(String fileName, {String? title, int? year}) async {
    final folders = await library.allFolders();
    final folderId = folders.isEmpty
        ? await library.addFolder(path: 'content://tree/m', displayName: 'M')
        : folders.first.id;
    await library.upsertMediaFile(
      folderId: folderId,
      filePath: 'content://tree/m/$fileName',
      fileName: fileName,
      mediaType: MediaType.movie,
      parsedTitle: title,
      parsedYear: year,
    );
  }

  group('multi-quality files share one metadata record', () {
    test('two rips of one film collapse to a single key and one record',
        () async {
      await addMovie('Dune.2021.1080p.mkv', title: 'Dune', year: 2021);
      await addMovie('Dune.2021.720p.mkv', title: 'Dune', year: 2021);

      final files = await library.watchMediaOfType(MediaType.movie).first;
      final keys = files
          .map((f) => movieKeyFor(f.parsedTitle!, f.parsedYear))
          .toSet();

      expect(files, hasLength(2), reason: 'both files stay indexed');
      expect(keys, hasLength(1), reason: 'but they share one metadata record');

      for (final key in keys) {
        await metadata.ensureMoviePending(key);
        await metadata.ensureMoviePending(key); // idempotent
      }
      expect(await metadata.moviesNeedingMatch(), hasLength(1));
    });

    test('a remake of the same title keeps its own record', () async {
      await addMovie('Dune.2021.mkv', title: 'Dune', year: 2021);
      await addMovie('Dune.1984.mkv', title: 'Dune', year: 1984);

      final files = await library.watchMediaOfType(MediaType.movie).first;
      for (final file in files) {
        await metadata
            .ensureMoviePending(movieKeyFor(file.parsedTitle!, file.parsedYear));
      }

      expect(await metadata.moviesNeedingMatch(), hasLength(2));
    });

    test('one match populates the record every quality reads from', () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);

      final matcher = MetadataMatcher(
        apiFrom({'search/movie': _duneSearch, 'movie/438631': _duneDetails}),
        metadata,
      );

      final outcome =
          await matcher.matchMovie(key, parsedTitle: 'Dune', parsedYear: 2021);

      expect(outcome, MatchOutcome.matched);
      final record = await metadata.movieByKey(key);
      expect(record!.tmdbId, 438631, reason: 'the 2021 film, not the 1984 one');
      expect(record.matchStatus, MatchStatus.auto);
      expect(record.overview, 'Paul Atreides arrives on Arrakis.');
      expect(decodeGenres(record.genres), ['Science Fiction']);
    });
  });

  group('matching decisions', () {
    test('a wrong-year-only candidate is held for review, not accepted',
        () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);

      // Only the 1984 film exists in the results, and it is very popular.
      final matcher = MetadataMatcher(
        apiFrom({
          'search/movie': {
            'results': [
              {
                'id': 841,
                'title': 'Dune',
                'release_date': '1984-12-14',
                'popularity': 900.0,
              },
            ],
          },
        }),
        metadata,
      );

      final outcome =
          await matcher.matchMovie(key, parsedTitle: 'Dune', parsedYear: 2021);

      expect(outcome, MatchOutcome.needsReview);
      final record = await metadata.movieByKey(key);
      expect(record!.matchStatus, MatchStatus.needsReview);
      expect(record.tmdbId, 841, reason: 'the guess is kept for the review UI');
      expect(record.overview, isNull, reason: 'no details fetched for a guess');
    });

    test('no results at all is recorded as unmatched', () async {
      final key = movieKeyFor('Some Home Video', null);
      await metadata.ensureMoviePending(key);

      final matcher = MetadataMatcher(
        apiFrom({'search/movie': {'results': <Object>[]}}),
        metadata,
      );

      final outcome =
          await matcher.matchMovie(key, parsedTitle: 'Some Home Video');

      expect(outcome, MatchOutcome.unmatched);
      expect((await metadata.movieByKey(key))!.matchStatus,
          MatchStatus.unmatched);
    });

    test('a manual match is never overwritten by an automatic pass', () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);
      await metadata.saveMovieMatch(
        key,
        const MovieMetadataCompanion(
          tmdbId: Value(999),
          matchStatus: Value(MatchStatus.manual),
        ),
      );

      final matcher = MetadataMatcher(
        apiFrom({'search/movie': _duneSearch, 'movie/438631': _duneDetails}),
        metadata,
      );
      await matcher.matchMovie(key, parsedTitle: 'Dune', parsedYear: 2021);

      final record = await metadata.movieByKey(key);
      expect(record!.tmdbId, 999, reason: 'a human decision outranks the scorer');
      expect(record.matchStatus, MatchStatus.manual);
    });
  });

  group('failure modes', () {
    test('a rejected token reports unauthorized, not a per-item failure',
        () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);

      final matcher = MetadataMatcher(apiRejectingToken(), metadata);
      final outcome =
          await matcher.matchMovie(key, parsedTitle: 'Dune', parsedYear: 2021);

      // The sync maps this to a single "token rejected" message and stops,
      // rather than looping the whole library into failures.
      expect(outcome, MatchOutcome.unauthorized);
      expect((await metadata.movieByKey(key))!.matchStatus, MatchStatus.pending,
          reason: 'a bad token must not corrupt the queue');
    });

    test('TMDB dropping mid-pass saves what completed and resumes cleanly',
        () async {
      final duneKey = movieKeyFor('Dune', 2021);
      final arrivalKey = movieKeyFor('Arrival', 2016);
      await metadata.ensureMoviePending(duneKey);
      await metadata.ensureMoviePending(arrivalKey);

      // First pass: Dune matches, then the network drops before Arrival.
      final onlineForDune = MetadataMatcher(
        apiFrom({'search/movie': _duneSearch, 'movie/438631': _duneDetails}),
        metadata,
      );
      expect(
        await onlineForDune.matchMovie(duneKey,
            parsedTitle: 'Dune', parsedYear: 2021),
        MatchOutcome.matched,
      );
      final offline = MetadataMatcher(apiFrom(const {}, offline: true), metadata);
      expect(
        await offline.matchMovie(arrivalKey,
            parsedTitle: 'Arrival', parsedYear: 2016),
        MatchOutcome.offline,
      );

      // Dune's result is durable; Arrival is still queued, not failed.
      expect((await metadata.movieByKey(duneKey))!.matchStatus, MatchStatus.auto);
      expect((await metadata.movieByKey(arrivalKey))!.matchStatus,
          MatchStatus.pending);
      expect((await metadata.moviesNeedingMatch()).map((m) => m.movieKey),
          [arrivalKey], reason: 'the next sync picks up exactly where it left off');
    });
  });

  group('offline', () {
    test('a matcher run while offline reports offline and writes nothing',
        () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);

      final matcher = MetadataMatcher(
        apiFrom(const {}, offline: true),
        metadata,
      );

      final outcome =
          await matcher.matchMovie(key, parsedTitle: 'Dune', parsedYear: 2021);

      expect(outcome, MatchOutcome.offline);
      final record = await metadata.movieByKey(key);
      expect(
        record!.matchStatus,
        MatchStatus.pending,
        reason: 'being offline must not mark a title unmatched — it stays '
            'queued for the next time there is a network',
      );
      expect(record.tmdbId, isNull);
    });

    test('an offline season fetch leaves stored episodes untouched', () async {
      final matcher = MetadataMatcher(
        apiFrom(const {}, offline: true),
        metadata,
      );

      final outcome = await matcher.fetchSeason(63247, 2);

      expect(outcome, MatchOutcome.offline);
      expect(await metadata.storedSeasons(63247), isEmpty);
    });
  });

  group('seasons', () {
    const seasonTwo = {
      'season_number': 2,
      'name': 'Season 2',
      'episodes': [
        {
          'episode_number': 1,
          'name': 'Journey Into Night',
          'still_path': '/s2e1.jpg',
          'air_date': '2018-04-22',
        },
        {
          'episode_number': 2,
          'name': 'Reunion',
          'still_path': '/s2e2.jpg',
        },
      ],
    };

    test('stores episodes and reports which seasons are held', () async {
      final matcher = MetadataMatcher(
        apiFrom({'tv/63247/season/2': seasonTwo}),
        metadata,
      );

      expect(await matcher.fetchSeason(63247, 2), MatchOutcome.matched);

      expect(await metadata.storedSeasons(63247), {2});
      final episodes = await metadata.watchEpisodesForShow(63247).first;
      expect(episodes.map((e) => e.name), ['Journey Into Night', 'Reunion']);
      expect(episodes.first.stillPath, '/s2e1.jpg');
    });

    test('re-fetching a season updates rather than duplicates', () async {
      final matcher = MetadataMatcher(
        apiFrom({'tv/63247/season/2': seasonTwo}),
        metadata,
      );

      await matcher.fetchSeason(63247, 2);
      await matcher.fetchSeason(63247, 2);

      final episodes = await metadata.watchEpisodesForShow(63247).first;
      expect(episodes, hasLength(2), reason: 'unique on show+season+episode');
    });

    test('only the seasons on disk are requested', () async {
      // A show with ten seasons, of which the library holds one.
      final requested = <Uri>[];
      final matcher = MetadataMatcher(
        apiFrom({'tv/63247/season/2': seasonTwo}, record: requested),
        metadata,
      );

      final stored = await metadata.storedSeasons(63247);
      const seasonsOnDisk = {2};
      for (final season in seasonsOnDisk.difference(stored)) {
        await matcher.fetchSeason(63247, season);
      }

      expect(requested, hasLength(1));
      expect(requested.single.path, endsWith('/tv/63247/season/2'));
    });
  });

  group('retrying failed matches', () {
    /// Puts one record in each terminal state.
    Future<void> seedStatuses() async {
      for (final entry in {
        'pending-one': MatchStatus.pending,
        'unmatched-one': MatchStatus.unmatched,
        'review-one': MatchStatus.needsReview,
        'manual-one': MatchStatus.manual,
        'auto-one': MatchStatus.auto,
      }.entries) {
        await metadata.ensureMoviePending(entry.key);
        await metadata.saveMovieMatch(
          entry.key,
          MovieMetadataCompanion(matchStatus: Value(entry.value)),
        );
      }
    }

    test('an automatic pass only picks up pending records', () async {
      await seedStatuses();

      final queued = await metadata.moviesNeedingMatch();

      expect(queued.map((m) => m.movieKey), ['pending-one'],
          reason: 'every scan re-querying hopeless titles would be waste');
    });

    test('an explicit sync also retries unmatched and needs-review', () async {
      await seedStatuses();

      final queued = await metadata.moviesNeedingMatch(includeFailed: true);

      expect(
        queued.map((m) => m.movieKey).toSet(),
        {'pending-one', 'unmatched-one', 'review-one'},
      );
    });

    test('a manual match is never re-queued, even on an explicit retry',
        () async {
      await seedStatuses();

      final queued = await metadata.moviesNeedingMatch(includeFailed: true);

      expect(queued.map((m) => m.movieKey), isNot(contains('manual-one')));
      expect(queued.map((m) => m.movieKey), isNot(contains('auto-one')));
    });

    test('shows follow the same rule', () async {
      await metadata.ensureShowPending('pending-show');
      await metadata.ensureShowPending('unmatched-show');
      await metadata.saveShowMatch(
        'unmatched-show',
        const ShowMetadataCompanion(matchStatus: Value(MatchStatus.unmatched)),
      );

      expect((await metadata.showsNeedingMatch()).map((s) => s.showKey),
          ['pending-show']);
      expect(
        (await metadata.showsNeedingMatch(includeFailed: true))
            .map((s) => s.showKey)
            .toSet(),
        {'pending-show', 'unmatched-show'},
      );
    });
  });

  group('images are not re-downloaded', () {
    test('a movie with both local paths is not queued for images', () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);
      await metadata.saveMovieMatch(
        key,
        const MovieMetadataCompanion(
          tmdbId: Value(438631),
          posterPath: Value('/dune.jpg'),
          backdropPath: Value('/dunebd.jpg'),
          matchStatus: Value(MatchStatus.auto),
        ),
      );

      expect(await metadata.moviesNeedingImages(), hasLength(1));

      await metadata.saveMovieImages(
        key,
        localPosterPath: '/local/dune.jpg',
        localBackdropPath: '/local/dunebd.jpg',
      );

      expect(await metadata.moviesNeedingImages(), isEmpty);
    });
  });
}
