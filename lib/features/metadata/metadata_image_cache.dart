import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Downloads TMDB artwork into app storage and hands back local file paths.
///
/// The UI reads only from these files, never from a URL. That is what makes the
/// library look the same offline as online — a poster that has been fetched
/// once stays visible forever, with no network and no image-loading spinner.
class MetadataImageCache {
  MetadataImageCache({http.Client? httpClient, Directory? directory})
      : _http = httpClient ?? http.Client(),
        _directory = directory,
        _ownsClient = httpClient == null;

  final http.Client _http;
  final bool _ownsClient;

  /// Injectable so tests write to a temporary directory.
  Directory? _directory;

  /// Where artwork lives, created on first use.
  ///
  /// Application *support* rather than documents: this is a regenerable cache,
  /// not user data, and on iOS documents are user-visible and backed up.
  Future<Directory> _resolveDirectory() async {
    final existing = _directory;
    if (existing != null) return existing;

    final base = await getApplicationSupportDirectory();
    final directory = Directory('${base.path}/metadata_images');
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    _directory = directory;
    return directory;
  }

  /// Ensures the image at [url] exists on disk, returning its local path.
  ///
  /// Returns the existing path without a request when it has been downloaded
  /// already, and null when [url] is null or the download fails — a missing
  /// poster is a placeholder tile, never an error.
  Future<String?> ensureCached(String? url) async {
    if (url == null || url.isEmpty) return null;

    final Directory directory;
    try {
      directory = await _resolveDirectory();
    } on Object {
      return null;
    }

    final file = File('${directory.path}/${fileNameFor(url)}');
    // Already downloaded: the common case on every sync after the first.
    if (file.existsSync() && await file.length() > 0) return file.path;

    try {
      final response = await _http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return null;

      // Write to a temporary name first, then rename: a cancelled or crashed
      // sync can't leave a half-written file that later looks cached.
      final temporary = File('${file.path}.part');
      await temporary.writeAsBytes(response.bodyBytes, flush: true);
      await temporary.rename(file.path);
      return file.path;
    } on Object {
      // Offline, timeout, or a bad response — all just "no image yet".
      return null;
    }
  }

  /// A stable, filesystem-safe name derived from the URL, so the same artwork
  /// at the same size always maps to the same file and is downloaded once.
  ///
  /// TMDB URLs already end in a size and a unique file
  /// (`.../t/p/w342/abc123.jpg`), so joining the last two segments gives a
  /// name that is unique, readable on disk, and needs no hashing — and
  /// therefore no dependency. Anything unexpected falls back to the whole path
  /// with separators replaced, which is still unique.
  @visibleForTesting
  static String fileNameFor(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final segments =
        path.split('/').where((segment) => segment.isNotEmpty).toList();
    final name = segments.length >= 2
        ? segments.sublist(segments.length - 2).join('_')
        : segments.join('_');
    final sanitized = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return sanitized.isEmpty ? 'image.jpg' : sanitized;
  }

  /// Deletes every cached image. Artwork is regenerable, so this is safe.
  Future<void> clear() async {
    final directory = await _resolveDirectory();
    if (directory.existsSync()) await directory.delete(recursive: true);
    _directory = null;
  }

  void close() {
    if (_ownsClient) _http.close();
  }
}

final metadataImageCacheProvider = Provider<MetadataImageCache>((ref) {
  final cache = MetadataImageCache();
  ref.onDispose(cache.close);
  return cache;
});
