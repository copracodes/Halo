// Parsing SRT/VTT into timed cues and matching a cue to a playback position.

import 'package:flutter_test/flutter_test.dart';

import 'package:halo/features/player/subtitle_parser.dart';

void main() {
  group('parseSubtitles (SRT)', () {
    const srt = '''
1
00:00:01,000 --> 00:00:03,500
Hello there.

2
00:00:04,000 --> 00:00:06,000
<i>General Kenobi.</i>
You are a bold one.
''';

    test('parses cues, times, and multi-line text', () {
      final cues = parseSubtitles(srt);
      expect(cues, hasLength(2));
      expect(cues[0].start, const Duration(seconds: 1));
      expect(cues[0].end, const Duration(seconds: 3, milliseconds: 500));
      expect(cues[0].text, 'Hello there.');
      expect(cues[1].text, 'General Kenobi.\nYou are a bold one.',
          reason: 'markup stripped, lines kept');
    });

    test('finds the cue for a position and the gaps between', () {
      final cues = parseSubtitles(srt);
      expect(subtitleAt(cues, const Duration(seconds: 2)), 'Hello there.');
      expect(subtitleAt(cues, const Duration(milliseconds: 3600)), isNull);
      expect(subtitleAt(cues, const Duration(seconds: 5)),
          'General Kenobi.\nYou are a bold one.');
      expect(subtitleAt(cues, const Duration(seconds: 30)), isNull);
    });
  });

  group('parseSubtitles (VTT)', () {
    const vtt = '''
WEBVTT

00:00:02.000 --> 00:00:04.000
Web subtitle line.
''';

    test('parses dot-millisecond timestamps and skips the header', () {
      final cues = parseSubtitles(vtt);
      expect(cues, hasLength(1));
      expect(cues.single.start, const Duration(seconds: 2));
      expect(cues.single.text, 'Web subtitle line.');
    });
  });

  test('malformed blocks are skipped, not fatal', () {
    const messy = '''
not a cue

5
00:00:10,000 --> 00:00:12,000
Only this one counts.
''';
    final cues = parseSubtitles(messy);
    expect(cues, hasLength(1));
    expect(cues.single.text, 'Only this one counts.');
  });
}
