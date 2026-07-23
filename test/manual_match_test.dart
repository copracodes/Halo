// The manual-match path against an in-memory database and a mocked TMDB. The
// property that matters most: a match the user chose by hand survives a later
// automatic sync, which is what "give me control" ultimately has to guarantee.

import 'dart:convert';
import 'dart:io' show Directory, SocketException;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/data/repositories/library_repository.dart';
import 'package:halo/data/repositories/metadata_repository.dart';
import 'package:halo/data/tmdb/tmdb_api.dart';
import 'package:halo/data/tmdb/tmdb_client.dart';
import 'package:halo/features/metadata/manual_match.dart';
import 'package:halo/features/metadata/metadata_image_cache.dart';
import 'package:halo/features/metadata/metadata_keys.dart';
import 'package:halo/features/metadata/metadata_matcher.dart';

/// A TMDB stood up from canned responses, keyed by the path each request hits.
TmdbApi apiFrom(Map<String, Object> byPath, {bool offline = false}) {
  final client = TmdbClient(
    token: 'test-token',
    delay: (_) async {},
    httpClient: MockClient((request) async {
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

/// The 2021 film, the auto-matcher's preferred candidate for "Dune (2021)".
const _dune2021Search = {
  'results': [
    {
      'id': 438631,
      'title': 'Dune',
      'release_date': '2021-09-15',
      'poster_path': '/dune.jpg',
      'popularity': 100.0,
    },
  ],
};

const _dune2021Details = {
  'id': 438631,
  'title': 'Dune',
  'release_date': '2021-09-15',
  'overview': 'Paul Atreides arrives on Arrakis.',
  'runtime': 155,
  'poster_path': '/dune.jpg',
  'backdrop_path': '/dunebd.jpg',
};

/// The 1984 film — the entry the user deliberately picks by hand.
const _dune1984Details = {
  'id': 841,
  'title': 'Dune',
  'release_date': '1984-12-14',
  'overview': 'A Duke son leads desert warriors.',
  'runtime': 137,
  'poster_path': '/dune84.jpg',
  'backdrop_path': '/dune84bd.jpg',
};

void main() {
  late AppDatabase db;
  late LibraryRepository library;
  late MetadataRepository metadata;
  late Directory imageDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    library = LibraryRepository(db);
    metadata = MetadataRepository(db);
    imageDir = Directory.systemTemp.createTempSync('halo_images');
  });

  tearDown(() async {
    await db.close();
    if (imageDir.existsSync()) imageDir.deleteSync(recursive: true);
  });

  /// A cache that never touches the real network or app storage: a temp dir and
  /// a client that 404s, so image downloads simply resolve to "no image yet".
  MetadataImageCache offlineImageCache() => MetadataImageCache(
        directory: imageDir,
        httpClient: MockClient((_) async => http.Response('', 404)),
      );

  ManualMatchService serviceWith(TmdbApi api) => ManualMatchService(
        api: api,
        metadata: metadata,
        library: library,
        cache: offlineImageCache(),
      );

  group('applying a manual match', () {
    test('a hand-picked film is stored as a manual match', () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);

      final service = serviceWith(apiFrom({'movie/841': _dune1984Details}));
      final status = await service.applyMovieMatch(key, 841);

      expect(status, ManualMatchStatus.applied);
      final record = await metadata.movieByKey(key);
      expect(record!.tmdbId, 841);
      expect(record.title, 'Dune');
      expect(record.overview, 'A Duke son leads desert warriors.');
      expect(record.matchStatus, MatchStatus.manual);
    });

    test('a manual match survives a subsequent automatic sync', () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);

      // The user corrects the match by hand to the 1984 film.
      final service = serviceWith(apiFrom({'movie/841': _dune1984Details}));
      expect(await service.applyMovieMatch(key, 841), ManualMatchStatus.applied);

      // A later sync runs the auto-matcher, which — left to its own devices —
      // would pick the 2021 film for "Dune (2021)".
      final matcher = MetadataMatcher(
        apiFrom({
          'search/movie': _dune2021Search,
          'movie/438631': _dune2021Details,
        }),
        metadata,
      );
      await matcher.matchMovie(key, parsedTitle: 'Dune', parsedYear: 2021);

      final record = await metadata.movieByKey(key);
      expect(record!.tmdbId, 841,
          reason: 'the human choice must outrank the auto-matcher');
      expect(record.matchStatus, MatchStatus.manual);
    });

    test('offline apply reports offline and writes nothing', () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);

      final service = serviceWith(apiFrom(const {}, offline: true));
      final status = await service.applyMovieMatch(key, 841);

      expect(status, ManualMatchStatus.offline);
      final record = await metadata.movieByKey(key);
      expect(record!.matchStatus, MatchStatus.pending,
          reason: 'being offline must not corrupt the pending record');
      expect(record.tmdbId, isNull);
    });
  });

  group('refresh', () {
    test('refreshing a manual match keeps it manual', () async {
      final key = movieKeyFor('Dune', 2021);
      await metadata.ensureMoviePending(key);

      final service = serviceWith(apiFrom({'movie/841': _dune1984Details}));
      await service.applyMovieMatch(key, 841);

      final status = await service.refreshMovie(key);

      expect(status, ManualMatchStatus.applied);
      final record = await metadata.movieByKey(key);
      expect(record!.tmdbId, 841);
      expect(record.matchStatus, MatchStatus.manual,
          reason: 'a refresh re-fetches data but never downgrades the decision');
    });

    test('refreshing an unmatched title has nothing to do', () async {
      final key = movieKeyFor('Nonexistent', 2000);
      await metadata.ensureMoviePending(key);

      final service = serviceWith(apiFrom(const {}));
      expect(await service.refreshMovie(key), ManualMatchStatus.nothingToRefresh);
    });
  });
}
