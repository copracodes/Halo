// The movies grid, driven by a stand-in for the library repository: the tab's
// streams are overridden with fixed rows so the test exercises the rendering,
// the sort toggle, and the "Other files" fallback without touching a database.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/features/library/library_providers.dart';
import 'package:halo/features/metadata/metadata_sync.dart';
import 'package:halo/features/library/movies_tab.dart';
import 'package:halo/features/library/widgets/poster_card.dart';

import 'support/media_fixtures.dart';

void main() {
  /// Pumps the tab with [movies] and [other] standing in for what the
  /// repository would stream.
  Future<void> pumpMoviesTab(
    WidgetTester tester, {
    List<MediaFile> movies = const [],
    List<MediaFile> other = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moviesProvider.overrideWith((ref) => Stream.value(movies)),
          otherFilesProvider.overrideWith((ref) => Stream.value(other)),
          // The grid now joins files to their metadata; without this the
          // provider would reach a real on-disk database.
          movieMetadataByKeyProvider.overrideWith(
            (ref) => Stream.value(const {}),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: MoviesTab())),
      ),
    );
    // Let the overridden streams deliver their first value.
    await tester.pump();
    await tester.pump();
  }

  /// Card titles in the order the grid lays them out.
  List<String> renderedTitles(WidgetTester tester) =>
      tester.widgetList<PosterCard>(find.byType(PosterCard))
          .map((card) => card.title)
          .toList();

  testWidgets('renders a card per movie, with its title and year',
      (tester) async {
    await pumpMoviesTab(tester, movies: [
      mediaFile('dune.2021.mkv', parsedTitle: 'Dune', parsedYear: 2021),
      mediaFile('arrival.mkv', parsedTitle: 'Arrival', parsedYear: 2016),
    ]);

    expect(find.byType(PosterCard), findsNTiles(2));
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('2021'), findsOneWidget);
    expect(find.text('Arrival'), findsOneWidget);
    expect(find.text('2016'), findsOneWidget);
  });

  testWidgets('falls back to the file name when the parser found no title',
      (tester) async {
    await pumpMoviesTab(tester, movies: [mediaFile('some.odd.release.mkv')]);

    expect(find.text('some.odd.release'), findsOneWidget);
  });

  testWidgets('sorts alphabetically by default', (tester) async {
    await pumpMoviesTab(tester, movies: [
      mediaFile('z.mkv', parsedTitle: 'Zodiac'),
      mediaFile('a.mkv', parsedTitle: 'Alien'),
      mediaFile('m.mkv', parsedTitle: 'Memento'),
    ]);

    expect(renderedTitles(tester), ['Alien', 'Memento', 'Zodiac']);
  });

  testWidgets('the sort toggle switches to newest first', (tester) async {
    await pumpMoviesTab(tester, movies: [
      mediaFile('a.mkv', parsedTitle: 'Alien', dateScanned: DateTime(2026, 1)),
      mediaFile('z.mkv', parsedTitle: 'Zodiac', dateScanned: DateTime(2026, 6)),
      mediaFile('m.mkv', parsedTitle: 'Memento', dateScanned: DateTime(2026, 3)),
    ]);

    expect(renderedTitles(tester), ['Alien', 'Memento', 'Zodiac']);

    await tester.tap(find.text('Recent'));
    await tester.pumpAndSettle();

    expect(renderedTitles(tester), ['Zodiac', 'Memento', 'Alien']);
  });

  testWidgets('unidentified files get a collapsed Other files section',
      (tester) async {
    await pumpMoviesTab(
      tester,
      movies: [mediaFile('dune.mkv', parsedTitle: 'Dune')],
      other: [mediaFile('VID_20240110.mp4', mediaType: MediaType.unknown)],
    );

    expect(find.text('Other files'), findsOneWidget);
    // Collapsed: the file itself isn't on screen until the section is opened.
    expect(find.text('VID_20240110.mp4'), findsNothing);

    await tester.tap(find.text('Other files'));
    await tester.pumpAndSettle();

    expect(find.text('VID_20240110.mp4'), findsOneWidget);
  });

  testWidgets('shows an empty state when there is nothing to list',
      (tester) async {
    await pumpMoviesTab(tester);

    expect(find.text('No movies yet'), findsOneWidget);
    expect(find.byType(PosterCard), findsNothing);
  });
}

/// Readability alias — `findsNWidgets` reads oddly for a grid of cards.
Matcher findsNTiles(int n) => findsNWidgets(n);
