/// Parses SRT and WebVTT subtitle text into timed cues, and finds the cue for a
/// playback position. Pure string work — no I/O, no player — so Halo can render
/// external subtitles itself rather than relying on the video backend to load
/// them (media_kit's `sub-add` can't open external files on Android).
library;

/// One subtitle line with the window it's shown in.
class SubtitleCue {
  const SubtitleCue({
    required this.start,
    required this.end,
    required this.text,
  });

  final Duration start;
  final Duration end;
  final String text;
}

final RegExp _timeLine = RegExp(
  r'(\d{1,2}):(\d{2}):(\d{2})[.,](\d{1,3})\s*-->\s*'
  r'(\d{1,2}):(\d{2}):(\d{2})[.,](\d{1,3})',
);

/// Parses [content] (SRT or VTT) into cues ordered by start time. Blocks without
/// a valid timestamp line (an SRT index, the `WEBVTT` header, notes) are
/// skipped, so both formats — and their common malformations — parse.
List<SubtitleCue> parseSubtitles(String content) {
  final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final blocks = normalized.split(RegExp(r'\n[ \t]*\n'));

  final cues = <SubtitleCue>[];
  for (final block in blocks) {
    final lines = block.split('\n');
    var timeIndex = -1;
    RegExpMatch? match;
    for (var i = 0; i < lines.length; i++) {
      final candidate = _timeLine.firstMatch(lines[i]);
      if (candidate != null) {
        timeIndex = i;
        match = candidate;
        break;
      }
    }
    if (match == null) continue;

    final text = lines
        .sublist(timeIndex + 1)
        .join('\n')
        .trim();
    if (text.isEmpty) continue;

    cues.add(SubtitleCue(
      start: _durationFrom(match, 1),
      end: _durationFrom(match, 5),
      text: _stripMarkup(text),
    ));
  }

  cues.sort((a, b) => a.start.compareTo(b.start));
  return cues;
}

/// The cue active at [position], or null when none covers it. Linear scan —
/// subtitle files are small and this runs only a few times a second.
String? subtitleAt(List<SubtitleCue> cues, Duration position) {
  for (final cue in cues) {
    if (position >= cue.start && position < cue.end) return cue.text;
    if (cue.start > position) break; // cues are sorted; no later cue can match
  }
  return null;
}

Duration _durationFrom(RegExpMatch match, int base) {
  int at(int offset) => int.parse(match.group(base + offset)!);
  final millisText = match.group(base + 3)!.padRight(3, '0');
  return Duration(
    hours: at(0),
    minutes: at(1),
    seconds: at(2),
    milliseconds: int.parse(millisText),
  );
}

/// Strips the styling tags subtitles carry — SRT/VTT HTML-ish `<i>` tags and
/// ASS override blocks `{\...}` — leaving just the readable text.
String _stripMarkup(String text) {
  return text
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll(RegExp(r'\{[^}]*\}'), '')
      .trim();
}
