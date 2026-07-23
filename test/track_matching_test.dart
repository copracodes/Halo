// Pure track matching: the real-world messiness of language tags, missing tags,
// and single-track files, without a player.

import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';

import 'package:halo/features/player/track_matching.dart';

void main() {
  group('normalizeLanguage', () {
    test('collapses code and name spellings to one canonical code', () {
      expect(normalizeLanguage('eng'), 'en');
      expect(normalizeLanguage('EN'), 'en');
      expect(normalizeLanguage(' English '), 'en');
      expect(normalizeLanguage('jpn'), 'ja');
    });

    test('unknown tags fall back to their own lowercased form', () {
      expect(normalizeLanguage('xyz'), 'xyz');
    });

    test('null or blank is empty', () {
      expect(normalizeLanguage(null), '');
      expect(normalizeLanguage('   '), '');
    });
  });

  group('languagesMatch', () {
    test('matches across code and name spellings', () {
      expect(languagesMatch('eng', 'en'), isTrue);
      expect(languagesMatch('English', 'eng'), isTrue);
    });

    test('different languages do not match', () {
      expect(languagesMatch('eng', 'jpn'), isFalse);
    });

    test('two missing tags never match — a blank is not a language', () {
      expect(languagesMatch(null, null), isFalse);
      expect(languagesMatch('', ''), isFalse);
      expect(languagesMatch(null, 'en'), isFalse);
    });
  });

  group('matchAudioTrack', () {
    const en = AudioTrack('1', 'English', 'eng');
    const ja = AudioTrack('2', 'Japanese', 'jpn');
    const commentary = AudioTrack('3', 'Director Commentary', null);

    test('matches by language first, across spellings', () {
      final match = matchAudioTrack(
        [en, ja],
        const TrackChoice(language: 'ja'),
      );
      expect(match, ja);
    });

    test('language wins over an also-present title match', () {
      // Pref has both; the Japanese language tag should decide, not the title.
      final match = matchAudioTrack(
        [en, ja],
        const TrackChoice(language: 'jpn', title: 'English'),
      );
      expect(match, ja);
    });

    test('falls back to a title match when the tag is missing', () {
      final match = matchAudioTrack(
        [en, commentary],
        const TrackChoice(language: 'de', title: 'commentary'),
      );
      expect(match, commentary, reason: 'untagged track matched by its title');
    });

    test('no match leaves the default (null)', () {
      final match = matchAudioTrack([en], const TrackChoice(language: 'ko'));
      expect(match, isNull);
    });

    test('an empty preference never overrides', () {
      expect(matchAudioTrack([en, ja], const TrackChoice()), isNull);
    });

    test('a single matching track is selected', () {
      expect(
        matchAudioTrack([en], const TrackChoice(language: 'en')),
        en,
      );
    });

    test('no tracks means no match', () {
      expect(matchAudioTrack(const [], const TrackChoice(language: 'en')),
          isNull);
    });
  });

  group('matchSubtitleTrack', () {
    const en = SubtitleTrack('1', 'English', 'eng');
    const enSdh = SubtitleTrack('2', 'English (SDH)', 'eng');
    const es = SubtitleTrack('3', 'Español', 'spa');

    test('matches by language', () {
      expect(
        matchSubtitleTrack([en, es], const TrackChoice(language: 'es')),
        es,
      );
    });

    test('picks the first language match when several share it', () {
      expect(
        matchSubtitleTrack([en, enSdh], const TrackChoice(language: 'en')),
        en,
      );
    });

    test('no language match leaves the default', () {
      expect(
        matchSubtitleTrack([en, es], const TrackChoice(language: 'fr')),
        isNull,
      );
    });
  });
}
