// The typed TMDB endpoints against mocked HTTP: request shape, response
// parsing into models, and image URL building at each requested size.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:halo/data/tmdb/tmdb_api.dart';
import 'package:halo/data/tmdb/tmdb_client.dart';
import 'package:halo/data/tmdb/tmdb_images.dart';
import 'package:halo/data/tmdb/tmdb_result.dart';

http.Response _json(Object body) => http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

/// Builds an API whose every request returns [body], capturing the last URI.
({TmdbApi api, List<Uri> requests}) apiReturning(Object body) {
  final requests = <Uri>[];
  final client = TmdbClient(
    token: 'test-token',
    delay: (_) async {},
    httpClient: MockClient((request) async {
      requests.add(request.url);
      return _json(body);
    }),
  );
  return (api: TmdbApi(client), requests: requests);
}

void main() {
  group('search/tv', () {
    const westworld = {
      'page': 1,
      'total_pages': 1,
      'total_results': 2,
      'results': [
        {
          'id': 63247,
          'name': 'Westworld',
          'original_name': 'Westworld',
          'overview': 'A dark odyssey about the dawn of artificial '
              'consciousness.',
          'poster_path': '/8MfgyFHf7XEboZJPZXCIDqqiz6e.jpg',
          'backdrop_path': '/6qAtSF0oJDsClS8fBpMgIYS3lqp.jpg',
          'first_air_date': '2016-10-02',
          'vote_average': 8.1,
          'vote_count': 3421,
          'popularity': 92.5,
        },
        {
          'id': 1234,
          'name': 'Westworld Confidential',
          'first_air_date': '',
          'poster_path': null,
        },
      ],
    };

    test('parses results, normalising name and first_air_date', () async {
      final (:api, :requests) = apiReturning(westworld);

      final result = await api.searchTv('Westworld');

      final page = (result as TmdbSuccess).value;
      expect(page.totalResults, 2);
      expect(page.results, hasLength(2));

      final top = page.results.first;
      expect(top.id, 63247);
      expect(top.title, 'Westworld', reason: '`name` maps onto title for TV');
      expect(top.year, 2016);
      expect(top.isMovie, isFalse);
      expect(top.voteAverage, 8.1);
      expect(top.posterPath, '/8MfgyFHf7XEboZJPZXCIDqqiz6e.jpg');

      expect(requests.single.path, endsWith('/search/tv'));
      expect(requests.single.queryParameters['query'], 'Westworld');
    });

    test('an empty air date reads as no year rather than a parse failure',
        () async {
      final (:api, requests: _) = apiReturning(westworld);

      final page = ((await api.searchTv('Westworld')) as TmdbSuccess).value;

      expect(page.results[1].year, isNull);
      expect(page.results[1].posterPath, isNull);
    });

    test('year narrows the search with first_air_date_year', () async {
      final (:api, :requests) = apiReturning(westworld);

      await api.searchTv('Westworld', year: 2016);

      expect(requests.single.queryParameters['first_air_date_year'], '2016');
    });

    test('movie search uses primary_release_year and reads `title`', () async {
      final (:api, :requests) = apiReturning({
        'results': [
          {'id': 1, 'title': 'Dune', 'release_date': '2021-09-15'},
        ],
      });

      final page =
          ((await api.searchMovies('Dune', year: 2021)) as TmdbSuccess).value;

      expect(page.results.single.title, 'Dune');
      expect(page.results.single.year, 2021);
      expect(page.results.single.isMovie, isTrue);
      expect(requests.single.path, endsWith('/search/movie'));
      expect(requests.single.queryParameters['primary_release_year'], '2021');
    });

    test('a failure propagates as a failure, not an empty page', () async {
      final client = TmdbClient(
        token: 'test-token',
        delay: (_) async {},
        httpClient: MockClient((request) async => http.Response('{}', 404)),
      );

      final result = await TmdbApi(client).searchTv('Nothing');

      expect((result as TmdbFailure).kind, TmdbFailureKind.notFound);
    });
  });

  group('details', () {
    test('movie details request credits and images in one round trip',
        () async {
      final (:api, :requests) = apiReturning({
        'id': 438631,
        'title': 'Dune',
        'release_date': '2021-09-15',
        'runtime': 155,
        'genres': [
          {'id': 878, 'name': 'Science Fiction'},
          {'id': 12, 'name': 'Adventure'},
        ],
        'credits': {
          'cast': [
            {'id': 1, 'name': 'Timothée Chalamet', 'character': 'Paul', 'order': 0},
            {'id': 2, 'name': 'Rebecca Ferguson', 'character': 'Jessica', 'order': 1},
          ],
          'crew': [
            {'id': 3, 'name': 'Denis Villeneuve', 'job': 'Director'},
          ],
        },
        'images': {
          'posters': [
            {'file_path': '/low.jpg', 'vote_average': 1.0},
            {'file_path': '/best.jpg', 'vote_average': 9.0},
          ],
        },
      });

      final movie = ((await api.movieDetails(438631)) as TmdbSuccess).value;

      expect(movie.title, 'Dune');
      expect(movie.runtime, const Duration(minutes: 155));
      expect(movie.genres, ['Science Fiction', 'Adventure']);
      expect(movie.credits.cast.first.name, 'Timothée Chalamet');
      expect(movie.credits.directors.single.name, 'Denis Villeneuve');
      // Best-rated artwork first, so a caller can just take the head.
      expect(movie.images.posters.first.filePath, '/best.jpg');

      expect(
        requests.single.queryParameters['append_to_response'],
        'credits,images',
      );
    });

    test('a zero runtime is absent, not a zero duration', () async {
      final (:api, requests: _) = apiReturning({
        'id': 1,
        'title': 'Unknown Runtime',
        'runtime': 0,
      });

      final movie = ((await api.movieDetails(1)) as TmdbSuccess).value;

      expect(movie.runtime, isNull);
    });

    test('tv details order seasons ascending with specials last', () async {
      final (:api, requests: _) = apiReturning({
        'id': 63247,
        'name': 'Westworld',
        'first_air_date': '2016-10-02',
        'number_of_seasons': 4,
        'seasons': [
          {'season_number': 0, 'name': 'Specials', 'episode_count': 3},
          {'season_number': 2, 'name': 'Season 2', 'episode_count': 10},
          {'season_number': 1, 'name': 'Season 1', 'episode_count': 10},
        ],
      });

      final show = ((await api.tvDetails(63247)) as TmdbSuccess).value;

      expect(show.name, 'Westworld');
      expect(show.seasons.map((s) => s.seasonNumber), [1, 2, 0]);
      expect(show.regularSeasons.map((s) => s.seasonNumber), [1, 2]);
      expect(show.seasons.last.isSpecials, isTrue);
    });

    test('season details parse episodes with names, dates and stills',
        () async {
      final (:api, :requests) = apiReturning({
        'season_number': 2,
        'name': 'Season 2',
        'air_date': '2018-04-22',
        'episodes': [
          {
            'episode_number': 2,
            'name': 'Reunion',
            'overview': 'Dolores continues her rampage.',
            'still_path': '/still2.jpg',
            'air_date': '2018-04-29',
            'runtime': 60,
          },
          {
            'episode_number': 1,
            'name': 'Journey Into Night',
            'still_path': '/still1.jpg',
            'air_date': '2018-04-22',
          },
        ],
      });

      final season = ((await api.seasonDetails(63247, 2)) as TmdbSuccess).value;

      expect(requests.single.path, endsWith('/tv/63247/season/2'));
      expect(season.episodes.map((e) => e.episodeNumber), [1, 2],
          reason: 'episodes are ordered regardless of response order');
      expect(season.episode(1)!.name, 'Journey Into Night');
      expect(season.episode(2)!.overview, 'Dolores continues her rampage.');
      expect(season.episode(2)!.runtime, const Duration(minutes: 60));
      expect(season.episode(99), isNull, reason: 'a mis-numbered rip is not an error');
    });
  });

  group('image URLs', () {
    const images = TmdbImages(secureBaseUrl: 'https://image.tmdb.org/t/p/');

    test('builds poster URLs at the sizes the grids use', () {
      expect(
        images.poster('/abc.jpg'),
        'https://image.tmdb.org/t/p/w342/abc.jpg',
      );
      expect(
        images.poster('/abc.jpg', size: PosterSize.w500),
        'https://image.tmdb.org/t/p/w500/abc.jpg',
      );
    });

    test('builds backdrop and still URLs at their sizes', () {
      expect(
        images.backdrop('/bd.jpg'),
        'https://image.tmdb.org/t/p/w780/bd.jpg',
      );
      expect(
        images.backdrop('/bd.jpg', size: BackdropSize.w1280),
        'https://image.tmdb.org/t/p/w1280/bd.jpg',
      );
      expect(
        images.still('/st.jpg'),
        'https://image.tmdb.org/t/p/w300/st.jpg',
      );
    });

    test('no path means no URL, so callers render a placeholder', () {
      expect(images.poster(null), isNull);
      expect(images.poster(''), isNull);
    });

    test('tolerates a base or path with awkward slashes', () {
      const noSlash = TmdbImages(secureBaseUrl: 'https://example.com/t/p');
      expect(noSlash.poster('abc.jpg'), 'https://example.com/t/p/w342/abc.jpg');
    });

    test('configuration supplies the base URL and is cached', () async {
      var calls = 0;
      final client = TmdbClient(
        token: 'test-token',
        delay: (_) async {},
        httpClient: MockClient((request) async {
          calls++;
          return _json({
            'images': {
              'secure_base_url': 'https://cdn.example.com/t/p/',
              'poster_sizes': ['w342', 'w500'],
            },
          });
        }),
      );
      final api = TmdbApi(client);

      final first = await api.loadConfiguration();
      final second = await api.loadConfiguration();

      expect((first as TmdbSuccess).value.secureBaseUrl,
          'https://cdn.example.com/t/p/');
      expect(second, isA<TmdbSuccess<TmdbImages>>());
      expect(calls, 1, reason: 'configuration is fetched once per session');
      expect(
        api.images.poster('/x.jpg'),
        'https://cdn.example.com/t/p/w342/x.jpg',
      );
    });

    test('falls back to the known host when configuration is unavailable',
        () async {
      final client = TmdbClient(
        token: 'test-token',
        delay: (_) async {},
        httpClient: MockClient((request) async => http.Response('{}', 500)),
      );
      final api = TmdbApi(client);

      final result = await api.loadConfiguration();

      expect(result, isA<TmdbFailure<TmdbImages>>());
      // Artwork URLs must still be buildable — offline is a normal state.
      expect(
        api.images.poster('/x.jpg'),
        'https://image.tmdb.org/t/p/w342/x.jpg',
      );
    });
  });
}
