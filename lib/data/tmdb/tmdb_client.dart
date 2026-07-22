import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import '../../config/app_secrets.dart';
import 'tmdb_result.dart';

/// TMDB v3 API host. Auth is the v4 Read Access Token in an `Authorization:
/// Bearer` header — not the legacy `api_key` query parameter, which would put
/// the credential in URLs and logs.
const _baseUrl = 'https://api.themoviedb.org/3';

/// How long one attempt may take before it is abandoned.
const _requestTimeout = Duration(seconds: 12);

/// Total attempts per request, including the first.
const _maxAttempts = 3;

/// First backoff step; doubles per retry (400ms, 800ms).
const _baseBackoff = Duration(milliseconds: 400);

/// Ceiling on any single wait, including a server-supplied `Retry-After`. A
/// misconfigured header shouldn't strand a request for minutes.
const _maxBackoff = Duration(seconds: 8);

/// Minimum spacing between requests. TMDB no longer publishes a hard limit but
/// does throttle bursts, and enrichment walks a whole library — so requests are
/// spaced rather than fired in parallel.
const _minRequestInterval = Duration(milliseconds: 30);

/// HTTP transport for TMDB: authentication, timeouts, retry with backoff, and
/// a serial request queue.
///
/// Returns [TmdbResult] rather than throwing. Everything above this layer can
/// then treat "no metadata" as an ordinary state, which is what lets the app
/// stay usable with no network at all.
class TmdbClient {
  TmdbClient({
    http.Client? httpClient,
    String? token,
    Future<void> Function(Duration)? delay,
    Duration timeout = _requestTimeout,
  })  : _http = httpClient ?? http.Client(),
        _token = token ?? AppSecrets.tmdbReadAccessToken,
        _delay = delay ?? Future<void>.delayed,
        _timeout = timeout,
        _ownsClient = httpClient == null;

  final http.Client _http;
  final String _token;

  /// Injected so retry tests don't spend real time asleep.
  final Future<void> Function(Duration) _delay;

  /// Per-attempt timeout. Overridable so a test can exercise the timeout path
  /// without waiting the real 12 seconds three times over.
  final Duration _timeout;

  /// Only close the client if this instance created it.
  final bool _ownsClient;

  /// Tail of the request queue: each request waits for the previous one plus
  /// [_minRequestInterval].
  Future<void> _gate = Future<void>.value();

  bool get hasToken => _token.isNotEmpty;

  /// GETs [path] (e.g. `search/movie`) and decodes the JSON object body.
  Future<TmdbResult<Map<String, dynamic>>> getJson(
    String path, {
    Map<String, String>? query,
  }) {
    if (!hasToken) {
      return Future.value(
        const TmdbFailure(
          TmdbFailureKind.unauthorized,
          message: 'No TMDB token configured. See lib/config/secrets.dart.',
        ),
      );
    }
    return _serialize(() => _attempt(path, query));
  }

  /// Runs [action] after the previous request has finished and the minimum
  /// spacing has elapsed, so concurrent callers queue instead of bursting.
  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = _gate.then((_) => action());
    // The gate advances whether the request succeeded or not — a failure must
    // never wedge the queue.
    _gate = result
        .then<void>((_) {}, onError: (Object _) {})
        .then((_) => _delay(_minRequestInterval));
    return result;
  }

  Future<TmdbResult<Map<String, dynamic>>> _attempt(
    String path,
    Map<String, String>? query,
  ) async {
    final uri = Uri.parse('$_baseUrl/${path.replaceFirst(RegExp(r'^/'), '')}')
        .replace(queryParameters: query);

    TmdbFailure<Map<String, dynamic>>? lastFailure;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      final http.Response response;
      try {
        response = await _http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        ).timeout(_timeout);
      } on TimeoutException {
        lastFailure = const TmdbFailure(
          TmdbFailureKind.timeout,
          message: 'Request timed out.',
        );
        if (await _waitBeforeRetry(attempt, null)) continue;
        return lastFailure;
      } on SocketException catch (error) {
        // No route, DNS failure, connection refused: the device is offline.
        // Retrying immediately just burns battery, so give up at once.
        return TmdbFailure(
          TmdbFailureKind.networkUnavailable,
          message: error.message,
        );
      } on http.ClientException catch (error) {
        return TmdbFailure(
          TmdbFailureKind.networkUnavailable,
          message: error.message,
        );
      }

      final status = response.statusCode;

      if (status == 200) return _decode(response.body);

      if (status == 401 || status == 403) {
        return TmdbFailure(
          TmdbFailureKind.unauthorized,
          message: 'TMDB rejected the token.',
          statusCode: status,
        );
      }

      if (status == 404) {
        return TmdbFailure(
          TmdbFailureKind.notFound,
          message: 'No such TMDB resource.',
          statusCode: status,
        );
      }

      if (status == 429) {
        lastFailure = TmdbFailure(
          TmdbFailureKind.rateLimited,
          message: 'Rate limited by TMDB.',
          statusCode: status,
        );
        // TMDB says how long to wait; prefer that over our own guess.
        if (await _waitBeforeRetry(attempt, _retryAfter(response))) continue;
        return lastFailure;
      }

      if (status >= 500) {
        lastFailure = TmdbFailure(
          TmdbFailureKind.serverError,
          message: 'TMDB returned $status.',
          statusCode: status,
        );
        if (await _waitBeforeRetry(attempt, null)) continue;
        return lastFailure;
      }

      // Any other 4xx is a request we got wrong; retrying won't fix it.
      return TmdbFailure(
        TmdbFailureKind.badResponse,
        message: 'Unexpected status $status.',
        statusCode: status,
      );
    }

    return lastFailure ??
        const TmdbFailure(
          TmdbFailureKind.badResponse,
          message: 'Request failed.',
        );
  }

  /// Waits before another attempt, or returns false when [attempt] was the
  /// last one allowed.
  Future<bool> _waitBeforeRetry(int attempt, Duration? serverHint) async {
    if (attempt >= _maxAttempts) return false;
    final backoff = serverHint ?? _baseBackoff * (1 << (attempt - 1));
    await _delay(backoff > _maxBackoff ? _maxBackoff : backoff);
    return true;
  }

  /// `Retry-After` in seconds, when TMDB sends a sane one.
  Duration? _retryAfter(http.Response response) {
    final header = response.headers['retry-after'];
    if (header == null) return null;
    final seconds = int.tryParse(header.trim());
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }

  TmdbResult<Map<String, dynamic>> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return const TmdbFailure(
          TmdbFailureKind.badResponse,
          message: 'Expected a JSON object.',
        );
      }
      return TmdbSuccess(decoded);
    } on FormatException catch (error) {
      return TmdbFailure(
        TmdbFailureKind.badResponse,
        message: 'Malformed JSON: ${error.message}',
      );
    }
  }

  void close() {
    if (_ownsClient) _http.close();
  }
}
