import 'secrets.dart' as local;

/// Resolves the app's secrets, preferring a `--dart-define` over the local
/// git-ignored file.
///
/// The file is the everyday path: it means a plain `flutter run` works with no
/// flags to remember. The `--dart-define` override exists so a build can supply
/// the token without writing it to disk:
///
/// ```
/// flutter build apk --dart-define=TMDB_TOKEN=eyJ...
/// ```
class AppSecrets {
  const AppSecrets._();

  static const String _fromEnvironment = String.fromEnvironment('TMDB_TOKEN');

  /// TMDB v4 Read Access Token, or an empty string when none is configured.
  static String get tmdbReadAccessToken =>
      _fromEnvironment.isNotEmpty ? _fromEnvironment : local.tmdbReadAccessToken;

  /// Whether TMDB calls can be attempted at all. When false the app is fully
  /// usable — it simply has no metadata, which is the offline-first promise.
  static bool get hasTmdbToken => tmdbReadAccessToken.isNotEmpty;
}
