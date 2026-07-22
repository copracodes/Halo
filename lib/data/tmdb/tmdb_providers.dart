import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tmdb_api.dart';
import 'tmdb_client.dart';

/// The app's TMDB transport. Held for the process lifetime so its request
/// queue actually spaces requests across the whole app, and closed on dispose.
final tmdbClientProvider = Provider<TmdbClient>((ref) {
  final client = TmdbClient();
  ref.onDispose(client.close);
  return client;
});

/// Typed TMDB endpoints. Nothing is wired to the UI yet — Phase 3.2 (matching
/// and enrichment) will consume this.
final tmdbApiProvider = Provider<TmdbApi>((ref) {
  return TmdbApi(ref.watch(tmdbClientProvider));
});
