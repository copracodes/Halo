/// Why a TMDB call didn't produce data.
///
/// Halo is offline-first: metadata is an enhancement, and its absence must
/// never block browsing or playback. So every failure is a *value* the caller
/// can inspect and shrug off — nothing here is ever thrown at the UI.
enum TmdbFailureKind {
  /// No usable network: DNS failure, no route, connection refused. The normal
  /// state of an offline device, not an error worth surfacing loudly.
  networkUnavailable,

  /// The request took too long. Distinct from [networkUnavailable] because a
  /// slow network is worth retrying sooner than an absent one.
  timeout,

  /// No token configured, or TMDB rejected it (401/403). Retrying won't help
  /// until the user fixes their configuration.
  unauthorized,

  /// TMDB has no such resource (404).
  notFound,

  /// Rate limited (429) and still failing after the client's own retries.
  rateLimited,

  /// TMDB returned 5xx after retries.
  serverError,

  /// A response arrived but couldn't be decoded into the expected shape.
  badResponse,
}

/// The outcome of a TMDB call: either [TmdbSuccess] with data, or
/// [TmdbFailure] describing why not. Sealed so callers must handle both.
sealed class TmdbResult<T> {
  const TmdbResult();

  /// The value on success, or null on failure — for callers that treat missing
  /// metadata as simply "nothing to show".
  T? get valueOrNull => switch (this) {
        TmdbSuccess(:final value) => value,
        TmdbFailure() => null,
      };

  bool get isSuccess => this is TmdbSuccess<T>;

  /// Maps the value of a success, leaving a failure untouched (including its
  /// type parameter, which is why the failure is rebuilt rather than cast).
  TmdbResult<R> map<R>(R Function(T value) transform) => switch (this) {
        TmdbSuccess(:final value) => TmdbSuccess(transform(value)),
        TmdbFailure(:final kind, :final message, :final statusCode) =>
          TmdbFailure(kind, message: message, statusCode: statusCode),
      };
}

class TmdbSuccess<T> extends TmdbResult<T> {
  const TmdbSuccess(this.value);

  final T value;
}

class TmdbFailure<T> extends TmdbResult<T> {
  const TmdbFailure(this.kind, {this.message, this.statusCode});

  final TmdbFailureKind kind;

  /// Diagnostic detail for logs. Not intended for display.
  final String? message;

  /// HTTP status that caused the failure, when there was one.
  final int? statusCode;

  /// Whether trying again later stands a chance. A missing network or a
  /// transient server fault may recover; a bad token or a missing record
  /// will not.
  bool get isTransient => switch (kind) {
        TmdbFailureKind.networkUnavailable ||
        TmdbFailureKind.timeout ||
        TmdbFailureKind.rateLimited ||
        TmdbFailureKind.serverError =>
          true,
        TmdbFailureKind.unauthorized ||
        TmdbFailureKind.notFound ||
        TmdbFailureKind.badResponse =>
          false,
      };

  @override
  String toString() =>
      'TmdbFailure(${kind.name}${statusCode == null ? '' : ' $statusCode'}'
      '${message == null ? '' : ': $message'})';
}
