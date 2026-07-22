/// Poster widths TMDB serves. Halo uses [w342] for grid cards and [w500] for
/// detail headers.
enum PosterSize {
  w92,
  w154,
  w185,
  w342,
  w500,
  w780,
  original;

  String get path => name;
}

/// Backdrop widths. [w780] for phone-sized headers, [w1280] for tablets.
enum BackdropSize {
  w300,
  w780,
  w1280,
  original;

  String get path => name;
}

/// Episode still widths. [w300] is the size episode rows need.
enum StillSize {
  w92,
  w185,
  w300,
  original;

  String get path => name;
}

/// Profile (cast photo) widths.
enum ProfileSize {
  w45,
  w185,
  h632,
  original;

  String get path => name;
}

/// Builds full artwork URLs from the relative paths TMDB returns (`/abc123.jpg`).
///
/// TMDB's `/configuration` endpoint publishes the image base URL and the sizes
/// each image kind supports, and asks clients to read it rather than hardcode
/// it — it has changed before. [TmdbApi.configuration] fetches it; [fallback]
/// is used until then (and forever, if the device is offline), so artwork URLs
/// can always be built.
class TmdbImages {
  const TmdbImages({required this.secureBaseUrl});

  /// TMDB's long-standing image host. Values published by `/configuration`
  /// replace this at runtime; it exists so an offline first launch can still
  /// build URLs for anything already cached.
  static const TmdbImages fallback =
      TmdbImages(secureBaseUrl: 'https://image.tmdb.org/t/p/');

  /// Always the HTTPS base (`secure_base_url`), never the plain one.
  final String secureBaseUrl;

  factory TmdbImages.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is! Map<String, dynamic>) return fallback;
    final base = images['secure_base_url'];
    if (base is! String || base.isEmpty) return fallback;
    return TmdbImages(secureBaseUrl: base);
  }

  String? poster(String? path, {PosterSize size = PosterSize.w342}) =>
      _url(path, size.path);

  String? backdrop(String? path, {BackdropSize size = BackdropSize.w780}) =>
      _url(path, size.path);

  String? still(String? path, {StillSize size = StillSize.w300}) =>
      _url(path, size.path);

  String? profile(String? path, {ProfileSize size = ProfileSize.w185}) =>
      _url(path, size.path);

  /// Null in, null out: a title with no artwork is normal, and callers render a
  /// placeholder rather than branching on it here.
  String? _url(String? path, String size) {
    if (path == null || path.isEmpty) return null;
    // TMDB paths are absolute ('/abc.jpg'); tolerate one without the slash so a
    // stray value can't produce a broken '//' or a missing separator.
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    final base =
        secureBaseUrl.endsWith('/') ? secureBaseUrl : '$secureBaseUrl/';
    return '$base$size/$normalized';
  }

  @override
  bool operator ==(Object other) =>
      other is TmdbImages && other.secureBaseUrl == secureBaseUrl;

  @override
  int get hashCode => secureBaseUrl.hashCode;
}
