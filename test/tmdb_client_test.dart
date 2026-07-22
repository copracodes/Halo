// The TMDB transport against a mocked HTTP client: auth header, retry and
// backoff on 429/5xx, and the offline result type. Nothing here touches the
// network, and no test sleeps — the client's delay function is injected.

import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:halo/data/tmdb/tmdb_client.dart';
import 'package:halo/data/tmdb/tmdb_result.dart';

/// Records every wait the client asks for, and returns instantly, so backoff
/// can be asserted without spending the time.
class _RecordedDelays {
  final List<Duration> waits = [];

  Future<void> call(Duration duration) async => waits.add(duration);
}

http.Response _json(Object body, {int status = 200}) =>
    http.Response(jsonEncode(body), status);

void main() {
  const token = 'test-token';

  TmdbClient clientFor(
    MockClient mock, {
    _RecordedDelays? delays,
    String tokenValue = token,
    Duration timeout = const Duration(milliseconds: 50),
  }) =>
      TmdbClient(
        httpClient: mock,
        token: tokenValue,
        delay: (delays ?? _RecordedDelays()).call,
        timeout: timeout,
      );

  group('authentication', () {
    test('sends the v4 read token as a Bearer header', () async {
      String? authorization;
      String? accept;
      final client = clientFor(MockClient((request) async {
        authorization = request.headers['Authorization'];
        accept = request.headers['Accept'];
        return _json({'ok': true});
      }));

      await client.getJson('configuration');

      expect(authorization, 'Bearer $token');
      expect(accept, 'application/json');
    });

    test('never puts the credential in the query string', () async {
      Uri? seen;
      final client = clientFor(MockClient((request) async {
        seen = request.url;
        return _json({'ok': true});
      }));

      await client.getJson('search/tv', query: {'query': 'Westworld'});

      expect(seen!.query, contains('query=Westworld'));
      expect(seen!.query, isNot(contains('api_key')));
      expect(seen.toString(), isNot(contains(token)));
    });

    test('fails fast with unauthorized when no token is configured', () async {
      var called = false;
      final client = clientFor(
        MockClient((request) async {
          called = true;
          return _json({'ok': true});
        }),
        tokenValue: '',
      );

      final result = await client.getJson('configuration');

      expect(result, isA<TmdbFailure<Map<String, dynamic>>>());
      expect(
        (result as TmdbFailure).kind,
        TmdbFailureKind.unauthorized,
      );
      expect(called, isFalse, reason: 'must not hit the network without a token');
    });

    test('maps a rejected token to unauthorized without retrying', () async {
      var attempts = 0;
      final client = clientFor(MockClient((request) async {
        attempts++;
        return _json({'status_message': 'Invalid API key'}, status: 401);
      }));

      final result = await client.getJson('configuration');

      expect((result as TmdbFailure).kind, TmdbFailureKind.unauthorized);
      expect(attempts, 1, reason: 'a bad token will not fix itself');
    });
  });

  group('offline', () {
    test('a socket failure becomes networkUnavailable, not an exception',
        () async {
      final client = clientFor(MockClient((request) async {
        throw const SocketException('Network is unreachable');
      }));

      final result = await client.getJson('configuration');

      final failure = result as TmdbFailure;
      expect(failure.kind, TmdbFailureKind.networkUnavailable);
      expect(failure.isTransient, isTrue);
    });

    test('does not retry while offline', () async {
      var attempts = 0;
      final client = clientFor(MockClient((request) async {
        attempts++;
        throw const SocketException('No route to host');
      }));

      await client.getJson('configuration');

      expect(attempts, 1, reason: 'retrying an offline device wastes battery');
    });

    test('a timeout is reported as timeout and retried', () async {
      final delays = _RecordedDelays();
      var attempts = 0;
      final client = clientFor(
        MockClient((request) async {
          attempts++;
          // Outlives the client's timeout; the pending future is abandoned.
          return Completer<http.Response>().future;
        }),
        delays: delays,
      );

      final result = await client.getJson('configuration');

      expect((result as TmdbFailure).kind, TmdbFailureKind.timeout);
      expect(attempts, 3, reason: 'a slow network is worth retrying');
    });
  });

  group('retry', () {
    test('retries a 429 and succeeds on a later attempt', () async {
      var attempts = 0;
      final client = clientFor(MockClient((request) async {
        attempts++;
        if (attempts < 3) return _json({'error': 'slow down'}, status: 429);
        return _json({'results': []});
      }));

      final result = await client.getJson('search/tv');

      expect(result, isA<TmdbSuccess<Map<String, dynamic>>>());
      expect(attempts, 3);
    });

    test('gives up on 429 after the attempt limit, reporting rateLimited',
        () async {
      var attempts = 0;
      final client = clientFor(MockClient((request) async {
        attempts++;
        return _json({'error': 'slow down'}, status: 429);
      }));

      final result = await client.getJson('search/tv');

      expect((result as TmdbFailure).kind, TmdbFailureKind.rateLimited);
      expect(attempts, 3, reason: 'bounded retries, not an infinite loop');
    });

    test('honours Retry-After over its own backoff', () async {
      final delays = _RecordedDelays();
      final client = clientFor(
        MockClient((request) async => http.Response(
              '{}',
              429,
              headers: {'retry-after': '2'},
            )),
        delays: delays,
      );

      await client.getJson('search/tv');

      // Two waits between three attempts, both the server-requested 2s rather
      // than the 400ms/800ms the client would have chosen.
      expect(delays.waits.take(2), everyElement(const Duration(seconds: 2)));
    });

    test('backs off exponentially on 5xx', () async {
      final delays = _RecordedDelays();
      final client = clientFor(
        MockClient((request) async => _json({}, status: 503)),
        delays: delays,
      );

      final result = await client.getJson('configuration');

      expect((result as TmdbFailure).kind, TmdbFailureKind.serverError);
      expect(
        delays.waits.take(2),
        [const Duration(milliseconds: 400), const Duration(milliseconds: 800)],
      );
    });

    test('does not retry a 404', () async {
      var attempts = 0;
      final client = clientFor(MockClient((request) async {
        attempts++;
        return _json({'status_message': 'not found'}, status: 404);
      }));

      final result = await client.getJson('movie/999999999');

      expect((result as TmdbFailure).kind, TmdbFailureKind.notFound);
      expect(attempts, 1);
    });
  });

  group('decoding', () {
    test('malformed JSON becomes badResponse rather than throwing', () async {
      final client = clientFor(
        MockClient((request) async => http.Response('not json', 200)),
      );

      final result = await client.getJson('configuration');

      final failure = result as TmdbFailure;
      expect(failure.kind, TmdbFailureKind.badResponse);
      expect(failure.isTransient, isFalse);
    });

    test('a JSON array where an object was expected is a badResponse',
        () async {
      final client = clientFor(
        MockClient((request) async => http.Response('[1,2,3]', 200)),
      );

      final result = await client.getJson('configuration');

      expect((result as TmdbFailure).kind, TmdbFailureKind.badResponse);
    });
  });

  group('request queue', () {
    test('serialises concurrent requests instead of bursting', () async {
      var inFlight = 0;
      var maxConcurrent = 0;
      final client = clientFor(MockClient((request) async {
        inFlight++;
        maxConcurrent = inFlight > maxConcurrent ? inFlight : maxConcurrent;
        await Future<void>.delayed(Duration.zero);
        inFlight--;
        return _json({'ok': true});
      }));

      await Future.wait([
        client.getJson('search/tv', query: {'query': 'a'}),
        client.getJson('search/tv', query: {'query': 'b'}),
        client.getJson('search/tv', query: {'query': 'c'}),
      ]);

      expect(maxConcurrent, 1);
    });

    test('a failing request does not wedge the queue', () async {
      var attempts = 0;
      final client = clientFor(MockClient((request) async {
        attempts++;
        if (attempts == 1) throw const SocketException('down');
        return _json({'ok': true});
      }));

      final first = await client.getJson('configuration');
      final second = await client.getJson('configuration');

      expect(first, isA<TmdbFailure<Map<String, dynamic>>>());
      expect(second, isA<TmdbSuccess<Map<String, dynamic>>>());
    });
  });
}
