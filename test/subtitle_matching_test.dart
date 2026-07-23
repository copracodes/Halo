// Pure sidecar association rules: naming conventions, language extraction, and
// the location (same dir / Subs subfolder) constraints — no database, no player.

import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';

import 'package:halo/data/database/subtitle_source.dart';
import 'package:halo/features/library/folder_access/folder_access.dart';
import 'package:halo/features/library/subtitle_matching.dart';
import 'package:halo/features/player/external_subtitle.dart';
import 'package:halo/features/player/subtitle_selection.dart';

void main() {
  group('matchSidecarName', () {
    test('exact basename matches with no language', () {
      final match = matchSidecarName('Ep.S01E01.mkv', 'Ep.S01E01.srt');
      expect(match, isNotNull);
      expect(match!.lang, isNull);
    });

    test('a language suffix is extracted and normalised', () {
      expect(matchSidecarName('Ep.S01E01.mkv', 'Ep.S01E01.en.srt')!.lang, 'en');
      expect(matchSidecarName('Ep.S01E01.mkv', 'Ep.S01E01.eng.srt')!.lang, 'en');
    });

    test('a non-language suffix still matches, without a language', () {
      final match = matchSidecarName('Ep.S01E01.mkv', 'Ep.S01E01.forced.srt');
      expect(match, isNotNull);
      expect(match!.lang, isNull);
    });

    test('a different basename does not match', () {
      expect(matchSidecarName('Ep.S01E01.mkv', 'Ep.S01E02.srt'), isNull);
    });

    test('a non-subtitle extension never matches', () {
      expect(matchSidecarName('Ep.S01E01.mkv', 'Ep.S01E01.txt'), isNull);
    });

    test('all recognised subtitle extensions count', () {
      for (final ext in subtitleExtensions) {
        expect(isSubtitleFile('x.$ext'), isTrue, reason: ext);
      }
      expect(isSubtitleFile('x.mkv'), isFalse);
    });
  });

  group('languageFromSubtitleName', () {
    test('reads a trailing language token', () {
      expect(languageFromSubtitleName('Movie.en.srt'), 'en');
      expect(languageFromSubtitleName('Movie.english.srt'), 'en');
    });

    test('a name with no language token yields null', () {
      expect(languageFromSubtitleName('random_subs.srt'), isNull);
    });
  });

  group('linkSubtitles', () {
    ScannedFile file(String uri, String name, [List<String> path = const []]) =>
        ScannedFile(uri: uri, name: name, size: 1, lastModified: 0, parentPath: path);

    test('matches sidecars in the same directory', () {
      final links = linkSubtitles(
        videos: [file('v', 'Ep.S01E01.mkv', const ['Season 1'])],
        subtitles: [file('s', 'Ep.S01E01.en.srt', const ['Season 1'])],
      );
      expect(links, hasLength(1));
      expect(links.single.subtitleUri, 's');
      expect(links.single.lang, 'en');
    });

    test('matches a sidecar in a Subs subfolder', () {
      final links = linkSubtitles(
        videos: [file('v', 'Ep.S01E01.mkv', const ['Season 1'])],
        subtitles: [file('s', 'Ep.S01E01.srt', const ['Subs', 'Season 1'])],
      );
      expect(links, hasLength(1));
    });

    test('ignores a subtitle in an unrelated directory', () {
      final links = linkSubtitles(
        videos: [file('v', 'Ep.S01E01.mkv', const ['Season 1'])],
        subtitles: [file('s', 'Ep.S01E01.srt', const ['Season 2'])],
      );
      expect(links, isEmpty);
    });
  });

  group('chooseStartupSubtitle prefers an external language match', () {
    ExternalSubtitle ext(String uri, String? lang) =>
        ExternalSubtitle(uri: uri, lang: lang, source: SubtitleSource.sidecar);

    test('the next episode auto-selects its own external sub of that language',
        () {
      // A remembered preference of English subtitles on; this episode has its
      // own English external sidecar plus a Spanish embedded track.
      final decision = chooseStartupSubtitle(
        enabled: true,
        lang: 'en',
        external: [ext('content://ep2.en.srt', 'en')],
        embedded: const [SubtitleTrack('1', 'Spanish', 'spa')],
      );
      expect(decision.action, SubtitleAction.external);
      expect(decision.external!.uri, 'content://ep2.en.srt');
    });

    test('falls back to a single untagged external sub', () {
      final decision = chooseStartupSubtitle(
        enabled: true,
        lang: 'en',
        external: [ext('content://ep2.srt', null)],
        embedded: const [],
      );
      expect(decision.action, SubtitleAction.external);
    });

    test('falls back to an embedded match when no external fits', () {
      final decision = chooseStartupSubtitle(
        enabled: true,
        lang: 'en',
        external: [ext('content://ep2.fr.srt', 'fr'), ext('content://x.de.srt', 'de')],
        embedded: const [SubtitleTrack('1', 'English', 'eng')],
      );
      expect(decision.action, SubtitleAction.embedded);
      expect(decision.embedded!.id, '1');
    });

    test('an explicit off wins over any external', () {
      final decision = chooseStartupSubtitle(
        enabled: false,
        lang: 'en',
        external: [ext('content://ep2.en.srt', 'en')],
        embedded: const [],
      );
      expect(decision.action, SubtitleAction.off);
    });

    test('no preference at all leaves the file default', () {
      final decision = chooseStartupSubtitle(
        enabled: null,
        lang: null,
        external: [ext('content://ep2.en.srt', 'en')],
        embedded: const [],
      );
      expect(decision.action, SubtitleAction.leaveDefault);
    });
  });
}
