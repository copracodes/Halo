// Episode files -> shows -> seasons. The TV tab shows *shows*, so this is the
// step that decides which file belongs under which card and which season.

import 'package:flutter_test/flutter_test.dart';

import 'package:halo/data/database/app_database.dart';
import 'package:halo/features/library/show_grouping.dart';

import 'support/media_fixtures.dart';

void main() {
  group('groupIntoShows', () {
    test('collapses episodes of one show into a single card', () {
      final shows = groupIntoShows([
        episode('Breaking Bad', season: 1, number: 1),
        episode('Breaking Bad', season: 1, number: 2),
        episode('Breaking Bad', season: 2, number: 1),
      ]);

      expect(shows, hasLength(1));
      expect(shows.single.title, 'Breaking Bad');
      expect(shows.single.episodeCount, 3);
      expect(shows.single.seasonCount, 2);
    });

    test('puts each episode under its own season', () {
      final shows = groupIntoShows([
        episode('The Office', season: 2, number: 1),
        episode('The Office', season: 1, number: 1),
        episode('The Office', season: 1, number: 2),
      ]);

      final seasons = shows.single.seasons;
      expect(seasons.map((s) => s.season), [1, 2]);
      expect(seasons.first.episodes.map((e) => e.parsedEpisode), [1, 2]);
      expect(seasons.last.episodes.map((e) => e.parsedEpisode), [1]);
    });

    test('orders episodes within a season by episode number', () {
      final shows = groupIntoShows([
        episode('Severance', season: 1, number: 9),
        episode('Severance', season: 1, number: 10),
        episode('Severance', season: 1, number: 2),
      ]);

      expect(
        shows.single.seasons.single.episodes.map((e) => e.parsedEpisode),
        [2, 9, 10],
      );
    });

    test('keeps separate shows apart and sorts them alphabetically', () {
      final shows = groupIntoShows([
        episode('The Wire', season: 1, number: 1),
        episode('Andor', season: 1, number: 1),
        episode('Fringe', season: 1, number: 1),
      ]);

      expect(shows.map((s) => s.title), ['Andor', 'Fringe', 'The Wire']);
      expect(shows.every((s) => s.episodeCount == 1), isTrue);
    });

    test('merges titles that differ only by case or spacing', () {
      final shows = groupIntoShows([
        episode('The Office', season: 1, number: 1),
        episode('the  office', season: 1, number: 2),
        episode('The Office', season: 1, number: 3),
      ]);

      expect(shows, hasLength(1));
      expect(shows.single.episodeCount, 3);
      // The spelling most files agree on wins, so one odd download can't
      // rename the card.
      expect(shows.single.title, 'The Office');
    });

    test('files with no season form their own trailing group', () {
      final shows = groupIntoShows([
        episode('One Piece', season: null, number: 1071),
        episode('One Piece', season: 1, number: 1),
      ]);

      final seasons = shows.single.seasons;
      expect(seasons.map((s) => s.season), [1, null]);
      expect(seasons.last.label, 'Episodes');
      // A show with only one numbered season isn't advertised as multi-season.
      expect(shows.single.seasonCount, 1);
    });

    test('unnumbered episodes sort after numbered ones, by file name', () {
      final shows = groupIntoShows([
        mediaFile(
          'succession.finale.mkv',
          mediaType: MediaType.episode,
          parsedTitle: 'Succession',
          parsedSeason: 4,
        ),
        episode('Succession', season: 4, number: 1),
      ]);

      expect(
        shows.single.seasons.single.episodes.map((e) => e.fileName),
        ['Succession.S4E1.mkv', 'succession.finale.mkv'],
      );
    });

    test('groups by file name when the parser found no title', () {
      final shows = groupIntoShows([
        mediaFile(
          'mystery.show.mkv',
          mediaType: MediaType.episode,
          parsedEpisode: 3,
        ),
      ]);

      expect(shows.single.title, 'mystery.show');
    });

    test('is independent of the order the files arrive in', () {
      final files = [
        episode('Dark', season: 2, number: 2),
        episode('Dark', season: 1, number: 1),
        episode('Chernobyl', season: 1, number: 1),
        episode('Dark', season: 2, number: 1),
      ];

      final forwards = groupIntoShows(files);
      final backwards = groupIntoShows(files.reversed.toList());

      String describe(List<Show> shows) => shows
          .map(
            (s) =>
                '${s.title}:${s.seasons.map((season) => '${season.season}='
                    '${season.episodes.map((e) => e.parsedEpisode).join(',')}')
                    .join('|')}',
          )
          .join(';');

      expect(describe(backwards), describe(forwards));
    });

    test('returns nothing for an empty library', () {
      expect(groupIntoShows(const []), isEmpty);
    });
  });
}
