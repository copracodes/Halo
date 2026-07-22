// Table-driven tests for the filename parser: movies, every TV pattern,
// multi-episode ranges, anime absolute numbering, and nasty edge cases.

import 'package:flutter_test/flutter_test.dart';

import 'package:halo/data/database/media_type.dart';
import 'package:halo/features/library/parser/filename_parser.dart';
import 'package:halo/features/library/parser/parsed_media.dart';

/// One row of the parser truth table.
class _Case {
  const _Case(
    this.input,
    this.expected, {
    this.folders = const [],
  });

  final String input;
  final ParsedMedia expected;
  final List<String> folders;
}

ParsedMedia _movie(String title, [int? year]) =>
    ParsedMedia(mediaType: MediaType.movie, title: title, year: year);

ParsedMedia _ep(
  String title, {
  int? season,
  required int episode,
  int? episodeEnd,
}) =>
    ParsedMedia(
      mediaType: MediaType.episode,
      title: title,
      season: season,
      episode: episode,
      episodeEnd: episodeEnd,
    );

void main() {
  const parser = FilenameParser();

  final cases = <_Case>[
    // --- Movies: Title.Year.junk ---
    _Case('The.Matrix.1999.1080p.BluRay.x264-GROUP.mkv',
        _movie('The Matrix', 1999)),
    _Case('Inception.2010.mkv', _movie('Inception', 2010)),
    _Case('Interstellar.2014.2160p.UHD.BluRay.x265-TERMINAL.mkv',
        _movie('Interstellar', 2014)),
    _Case('Dune.Part.Two.2024.1080p.WEB-DL.mkv',
        _movie('Dune Part Two', 2024)),
    _Case('Nobody.2021.WEBRip.mkv', _movie('Nobody', 2021)),
    _Case('Tenet.2020.PROPER.1080p.mkv', _movie('Tenet', 2020)),
    _Case('Dune.2021.4K.HDR.mkv', _movie('Dune', 2021)),
    _Case('Some.Movie.2019.1080p.10bit.mkv', _movie('Some Movie', 2019)),
    // --- Movies: Title (Year) / brackets ---
    _Case('The Godfather (1972).mkv', _movie('The Godfather', 1972)),
    _Case('Parasite (2019) [1080p] [BluRay].mkv', _movie('Parasite', 2019)),
    _Case('The.Batman.2022.1080p.[YTS].mkv', _movie('The Batman', 2022)),
    _Case('Arrival.2016-RARBG.mkv', _movie('Arrival', 2016)),
    // --- Movies: plain / no year ---
    _Case('Avatar.mkv', _movie('Avatar')),
    _Case('Sintel.mkv', _movie('Sintel')),
    // --- Movies: minor words & hyphens ---
    _Case('The.Lord.of.the.Rings.2001.720p.mkv',
        _movie('The Lord of the Rings', 2001)),
    _Case('Spider-Man.2002.1080p.BluRay.mkv', _movie('Spider-Man', 2002)),
    _Case('WALL-E.2008.1080p.mkv', _movie('Wall-E', 2008)),
    _Case('Malcolm.X.1992.mkv', _movie('Malcolm X', 1992)),
    // --- Movies: device-pass example ---
    _Case('Sintel.2010.720p.mkv', _movie('Sintel', 2010)),
    // --- Nasty edge cases: numbers / years in titles ---
    _Case('2012.2009.1080p.mkv', _movie('2012', 2009)),
    _Case('2012.1080p.mkv', _movie('2012')),
    _Case('Se7en.1995.mkv', _movie('Se7en', 1995)),
    _Case('Se7en.mkv', _movie('Se7en')),
    _Case('300.2006.720p.mkv', _movie('300', 2006)),
    _Case('1917.2019.1080p.mkv', _movie('1917', 2019)),
    _Case('Blade.Runner.2049.2017.2160p.mkv',
        _movie('Blade Runner 2049', 2017)),
    _Case('Blade.Runner.2049.1080p.mkv', _movie('Blade Runner 2049')),

    // --- TV: S01E05 family ---
    _Case('Breaking.Bad.S01E01.720p.mkv',
        _ep('Breaking Bad', season: 1, episode: 1)),
    _Case('Breaking.Bad.s1e5.mkv', _ep('Breaking Bad', season: 1, episode: 5)),
    _Case('The.Mandalorian.S01E01.Chapter.1.1080p.mkv',
        _ep('The Mandalorian', season: 1, episode: 1)),
    _Case('Some.Show.S03E04.HDTV.x264.mkv',
        _ep('Some Show', season: 3, episode: 4)),
    // --- TV: season/episode markers split by hyphens or spaces ---
    _Case('westworld-s2-E1.mkv', _ep('Westworld', season: 2, episode: 1)),
    _Case('Westworld.S02.E01.1080p.mkv',
        _ep('Westworld', season: 2, episode: 1)),
    _Case('The Bear - S03 - E07.mkv', _ep('The Bear', season: 3, episode: 7)),
    // A word starting with "e" after the code is not a second episode number.
    _Case('Show.S01E01.Endgame.mkv', _ep('Show', season: 1, episode: 1)),
    // --- TV: 1x05 ---
    _Case('Game.of.Thrones.1x05.mkv',
        _ep('Game of Thrones', season: 1, episode: 5)),
    _Case('Firefly.01x05.mkv', _ep('Firefly', season: 1, episode: 5)),
    // --- TV: Season X Episode Y ---
    _Case('The.Office.Season.2.Episode.5.mkv',
        _ep('The Office', season: 2, episode: 5)),
    _Case('Chernobyl Season 1 Episode 3.mkv',
        _ep('Chernobyl', season: 1, episode: 3)),
    // --- TV: multi-episode ranges ---
    _Case('Breaking.Bad.S02E01E02.1080p.mkv',
        _ep('Breaking Bad', season: 2, episode: 1, episodeEnd: 2)),
    _Case('Show.S01E01-E03.mkv',
        _ep('Show', season: 1, episode: 1, episodeEnd: 3)),
    // --- TV: year in the show name (not a movie year) ---
    _Case('Doctor.Who.2005.S01E01.720p.mkv',
        _ep('Doctor Who 2005', season: 1, episode: 1)),
    _Case('1923.S01E01.1080p.mkv', _ep('1923', season: 1, episode: 1)),
    // --- TV: folder-based (season from folder, episode from leading number) ---
    _Case('05 - Ozymandias.mkv', _ep('Breaking Bad', season: 2, episode: 5),
        folders: ['Season 2', 'Breaking Bad']),
    _Case('09 - Serenity.mkv', _ep('Firefly', season: 3, episode: 9),
        folders: ['S3', 'Firefly']),
    // --- TV: anime absolute numbering (season null) ---
    _Case('[SubsPlease] Naruto - 133 [720p].mkv', _ep('Naruto', episode: 133)),
    _Case('Show.Name.-.12.mkv', _ep('Show Name', episode: 12)),
    _Case('[Erai-raws] Jujutsu Kaisen - 24 [1080p][Multi Subs].mkv',
        _ep('Jujutsu Kaisen', episode: 24)),
    _Case('One Piece - 100 [1080p].mkv', _ep('One Piece', episode: 100)),
  ];

  for (final c in cases) {
    test('${c.input}  ->  ${c.expected}', () {
      expect(parser.parse(c.input, parentFolders: c.folders), c.expected);
    });
  }

  test('there are at least 40 table cases', () {
    expect(cases.length, greaterThanOrEqualTo(40));
  });
}
