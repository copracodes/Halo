// The episode row's label. Release junk in a filename ("_720p", codec and
// group tags) must not leak into the list — every other surface shows the
// parsed identity, and this one has to match.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/features/library/widgets/episode_tile.dart';

import 'support/media_fixtures.dart';

void main() {
  Future<void> pumpTile(WidgetTester tester, MediaFile file) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EpisodeTile(file: file, onTap: () {}),
        ),
      ),
    );
  }

  testWidgets('labels a numbered episode by its number, not its file name',
      (tester) async {
    await pumpTile(
      tester,
      mediaFile(
        'westworld-s2-E1_720p.mkv',
        mediaType: MediaType.episode,
        parsedTitle: 'Westworld',
        parsedSeason: 2,
        parsedEpisode: 1,
      ),
    );

    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.textContaining('720p'), findsNothing);
  });

  testWidgets('labels a multi-episode file with its range', (tester) async {
    await pumpTile(
      tester,
      mediaFile(
        'show.S01E01E02.1080p.mkv',
        mediaType: MediaType.episode,
        parsedTitle: 'Show',
        parsedSeason: 1,
        parsedEpisode: 1,
        parsedEpisodeEnd: 2,
      ),
    );

    expect(find.text('Episodes 1–2'), findsOneWidget);
  });

  testWidgets('falls back to the file name when there is no episode number',
      (tester) async {
    await pumpTile(
      tester,
      mediaFile(
        'westworld.finale.mkv',
        mediaType: MediaType.episode,
        parsedTitle: 'Westworld',
        parsedSeason: 2,
      ),
    );

    expect(find.text('westworld.finale'), findsOneWidget);
  });
}
