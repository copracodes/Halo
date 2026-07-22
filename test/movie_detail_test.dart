// The metadata-driven UI: cards fall back to the placeholder when no poster
// has been cached, and the detail screen's Play button promises the behaviour
// it will actually perform.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/data/repositories/media_with_progress.dart';
import 'package:halo/features/library/library_providers.dart';
import 'package:halo/features/library/movie_detail_screen.dart';
import 'package:halo/features/library/movies_tab.dart';
import 'package:halo/features/library/widgets/poster_card.dart';
import 'package:halo/features/metadata/metadata_keys.dart';
import 'package:halo/features/metadata/metadata_sync.dart';

import 'support/media_fixtures.dart';

/// A metadata row as the matcher would have written it.
MovieMetadataData movieMetadata(
  String movieKey, {
  String? title,
  int? year,
  String? overview,
  String? localPosterPath,
  int? runtimeMs,
  double voteAverage = 0,
}) {
  return MovieMetadataData(
    id: movieKey.hashCode,
    movieKey: movieKey,
    tmdbId: 1,
    title: title,
    year: year,
    overview: overview,
    runtimeMs: runtimeMs,
    voteAverage: voteAverage,
    localPosterPath: localPosterPath,
    matchConfidence: 1,
    matchStatus: MatchStatus.auto,
  );
}

void main() {
  /// Pumps a widget with the library and metadata streams stubbed out.
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    List<MediaFile> movies = const [],
    Map<String, MovieMetadataData> metadata = const {},
    Map<String, MediaWithProgress> progress = const {},
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moviesProvider.overrideWith((ref) => Stream.value(movies)),
          otherFilesProvider.overrideWith((ref) => Stream.value(const [])),
          movieMetadataByKeyProvider.overrideWith(
            (ref) => Stream.value(metadata),
          ),
          progressByPathProvider.overrideWithValue(progress),
        ],
        child: MaterialApp(home: child),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  group('poster fallback', () {
    testWidgets('a card with no cached poster renders the placeholder tile',
        (tester) async {
      await pump(
        tester,
        const Scaffold(body: MoviesTab()),
        movies: [mediaFile('dune.mkv', parsedTitle: 'Dune', parsedYear: 2021)],
        // Matched, but artwork was never downloaded — the offline-first case.
        metadata: {
          movieKeyFor('Dune', 2021):
              movieMetadata(movieKeyFor('Dune', 2021), title: 'Dune'),
        },
      );

      final card = tester.widget<PosterCard>(find.byType(PosterCard));
      expect(card.imagePath, isNull);
      // The card still renders, titled, rather than leaving a hole.
      expect(find.text('Dune'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unmatched movie still gets a card', (tester) async {
      await pump(
        tester,
        const Scaffold(body: MoviesTab()),
        movies: [mediaFile('some.home.video.mkv')],
      );

      expect(find.byType(PosterCard), findsOneWidget);
      expect(find.text('some.home.video'), findsOneWidget);
    });

    testWidgets('a cached poster path is handed to the card', (tester) async {
      const key = 'dune|2021';
      await pump(
        tester,
        const Scaffold(body: MoviesTab()),
        movies: [mediaFile('dune.mkv', parsedTitle: 'Dune', parsedYear: 2021)],
        metadata: {
          key: movieMetadata(key,
              title: 'Dune', localPosterPath: '/cache/dune.jpg'),
        },
      );

      final card = tester.widget<PosterCard>(find.byType(PosterCard));
      expect(card.imagePath, '/cache/dune.jpg');
    });

    testWidgets('two qualities of one film share a single card',
        (tester) async {
      await pump(
        tester,
        const Scaffold(body: MoviesTab()),
        movies: [
          mediaFile('Dune.2021.1080p.mkv', parsedTitle: 'Dune', parsedYear: 2021),
          mediaFile('Dune.2021.720p.mkv', parsedTitle: 'Dune', parsedYear: 2021),
        ],
      );

      expect(find.byType(PosterCard), findsOneWidget);
      expect(find.text('2 versions'), findsOneWidget);
    });
  });

  group('detail screen play button', () {
    final file = mediaFile('dune.mkv', parsedTitle: 'Dune', parsedYear: 2021);
    final key = movieKeyFor('Dune', 2021);

    testWidgets('reads "Play" when nothing has been watched', (tester) async {
      await pump(
        tester,
        MovieDetailScreen(movieKey: key),
        movies: [file],
        metadata: {key: movieMetadata(key, title: 'Dune', year: 2021)},
      );

      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Start over'), findsNothing);
    });

    testWidgets('offers the saved position when there is progress',
        (tester) async {
      await pump(
        tester,
        MovieDetailScreen(movieKey: key),
        movies: [file],
        metadata: {key: movieMetadata(key, title: 'Dune', year: 2021)},
        progress: {
          file.filePath: MediaWithProgress(
            file: file,
            progress: WatchProgressData(
              id: 1,
              mediaFileId: file.id,
              positionMs: const Duration(minutes: 12, seconds: 34).inMilliseconds,
              durationMs: const Duration(hours: 2).inMilliseconds,
              lastWatchedAt: DateTime(2026),
              isFinished: false,
            ),
          ),
        },
      );

      expect(find.text('Resume from 12:34'), findsOneWidget);
      // And an explicit way to ignore it.
      expect(find.text('Start over'), findsOneWidget);
    });

    testWidgets('shows the film facts from metadata', (tester) async {
      await pump(
        tester,
        MovieDetailScreen(movieKey: key),
        movies: [file],
        metadata: {
          key: movieMetadata(
            key,
            title: 'Dune',
            year: 2021,
            overview: 'Paul Atreides arrives on Arrakis.',
            runtimeMs: const Duration(minutes: 155).inMilliseconds,
            voteAverage: 7.8,
          ),
        },
      );

      expect(find.text('Dune'), findsOneWidget);
      expect(find.text('Paul Atreides arrives on Arrakis.'), findsOneWidget);
      expect(find.textContaining('2021'), findsOneWidget);
      expect(find.textContaining('★ 7.8'), findsOneWidget);
    });

    testWidgets('lists selectable versions only when there are several',
        (tester) async {
      await pump(
        tester,
        MovieDetailScreen(movieKey: key),
        movies: [
          mediaFile('Dune.2021.1080p.BluRay.mkv',
              parsedTitle: 'Dune', parsedYear: 2021, fileSize: 8000000000),
          mediaFile('Dune.2021.720p.WEBRip.mkv',
              parsedTitle: 'Dune', parsedYear: 2021, fileSize: 2000000000),
        ],
        metadata: {key: movieMetadata(key, title: 'Dune', year: 2021)},
      );

      expect(find.text('Versions'), findsOneWidget);
      // The selected version also appears in the facts line under Play, so
      // the 1080p label legitimately renders twice.
      expect(find.textContaining('1080p · BluRay'), findsAtLeastNWidgets(1));
      expect(find.textContaining('720p · WEBRip'), findsOneWidget);
      // Largest file first, so the best copy is the default selection.
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });

    testWidgets('says so when the film has left the library', (tester) async {
      await pump(tester, const MovieDetailScreen(movieKey: 'gone|1999'));

      expect(
        find.text('This film is no longer in your library'),
        findsOneWidget,
      );
    });
  });
}
