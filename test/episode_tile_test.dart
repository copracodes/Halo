// The episode row's labelling: the headline is the parsed identity (matching
// every other surface), with the raw file name kept as a dim trailing line so
// two rips of the same episode stay tellable apart.

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

    // The headline is the parsed identity, not the file name...
    expect(find.text('Episode 1'), findsOneWidget);
    // ...but the file name is still there, on its own line, for disambiguation.
    expect(find.text('westworld-s2-E1_720p.mkv'), findsOneWidget);
  });

  testWidgets('two rips of one episode are distinguishable by their file names',
      (tester) async {
    MediaFile rip(String name) => mediaFile(
          name,
          mediaType: MediaType.episode,
          parsedTitle: 'Westworld',
          parsedSeason: 2,
          parsedEpisode: 1,
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              EpisodeTile(file: rip('westworld-s2-E1_720p.mkv'), onTap: () {}),
              EpisodeTile(file: rip('westworld-s2-E1_1080p.mkv'), onTap: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Episode 1'), findsNWidgets(2));
    expect(find.text('westworld-s2-E1_720p.mkv'), findsOneWidget);
    expect(find.text('westworld-s2-E1_1080p.mkv'), findsOneWidget);
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
