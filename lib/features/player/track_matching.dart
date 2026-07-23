import 'package:media_kit/media_kit.dart';

/// Matches a remembered track preference against the tracks a real file exposes.
/// Pure logic over media_kit's plain track data classes — no player, no I/O — so
/// the real-world messiness (three spellings of a language, missing tags,
/// single-track files) can be tested exhaustively.

/// Common language tags mapped to a canonical ISO 639-1 code, so `eng`, `en`,
/// and `english` all resolve to the same thing. Covers the languages that show
/// up in real releases; anything unknown falls back to its own lowercased form,
/// which still matches an identical tag.
const Map<String, String> _languageAliases = {
  'en': 'en', 'eng': 'en', 'english': 'en',
  'ja': 'ja', 'jpn': 'ja', 'jp': 'ja', 'japanese': 'ja',
  'es': 'es', 'spa': 'es', 'esp': 'es', 'spanish': 'es',
  'fr': 'fr', 'fra': 'fr', 'fre': 'fr', 'french': 'fr',
  'de': 'de', 'deu': 'de', 'ger': 'de', 'german': 'de',
  'it': 'it', 'ita': 'it', 'italian': 'it',
  'pt': 'pt', 'por': 'pt', 'portuguese': 'pt',
  'ru': 'ru', 'rus': 'ru', 'russian': 'ru',
  'zh': 'zh', 'zho': 'zh', 'chi': 'zh', 'cmn': 'zh', 'chinese': 'zh',
  'ko': 'ko', 'kor': 'ko', 'korean': 'ko',
  'hi': 'hi', 'hin': 'hi', 'hindi': 'hi',
  'ar': 'ar', 'ara': 'ar', 'arabic': 'ar',
  'nl': 'nl', 'nld': 'nl', 'dut': 'nl', 'dutch': 'nl',
  'sv': 'sv', 'swe': 'sv', 'swedish': 'sv',
  'pl': 'pl', 'pol': 'pl', 'polish': 'pl',
  'tr': 'tr', 'tur': 'tr', 'turkish': 'tr',
};

/// Canonical form of a language tag: lowercased, trimmed, and mapped through
/// [_languageAliases]. Empty for null/blank input.
String normalizeLanguage(String? code) {
  if (code == null) return '';
  final key = code.trim().toLowerCase();
  if (key.isEmpty) return '';
  return _languageAliases[key] ?? key;
}

/// Whether two language tags refer to the same language, across code and name
/// spellings. Two blanks never match — a missing tag is not a language.
bool languagesMatch(String? a, String? b) {
  final na = normalizeLanguage(a);
  return na.isNotEmpty && na == normalizeLanguage(b);
}

/// Whether [token] is a recognisable language tag (a code or a name we know), so
/// a filename suffix like `.en` is read as a language but `.forced` is not.
bool isLanguageTag(String? token) {
  if (token == null) return false;
  return _languageAliases.containsKey(token.trim().toLowerCase());
}

/// Display names for the canonical codes, for labels like "English — external".
const Map<String, String> _languageNames = {
  'en': 'English', 'es': 'Spanish', 'fr': 'French', 'de': 'German',
  'it': 'Italian', 'pt': 'Portuguese', 'ru': 'Russian', 'ja': 'Japanese',
  'ko': 'Korean', 'zh': 'Chinese', 'hi': 'Hindi', 'ar': 'Arabic',
  'nl': 'Dutch', 'sv': 'Swedish', 'pl': 'Polish', 'tr': 'Turkish',
};

/// A friendly language name for a code, or the code itself when unknown, or ''
/// for a missing tag.
String languageDisplayName(String? code) {
  final normalized = normalizeLanguage(code);
  if (normalized.isEmpty) return '';
  return _languageNames[normalized] ?? code!.trim();
}

/// Loose title match for untagged tracks: case-insensitive equality or
/// containment, so "English (SDH)" still matches a remembered "English".
bool titlesMatch(String? a, String? b) {
  final na = a?.trim().toLowerCase() ?? '';
  final nb = b?.trim().toLowerCase() ?? '';
  if (na.isEmpty || nb.isEmpty) return false;
  return na == nb || na.contains(nb) || nb.contains(na);
}

/// A remembered track preference: a language code and/or a track title.
class TrackChoice {
  const TrackChoice({this.language, this.title});

  final String? language;
  final String? title;

  bool get hasLanguage => language != null && language!.trim().isNotEmpty;
  bool get hasTitle => title != null && title!.trim().isNotEmpty;
  bool get isEmpty => !hasLanguage && !hasTitle;
}

/// Picks the track that best fits [pref]: language first, then a title match for
/// untagged tracks, else null — meaning "no preferred track here, leave the
/// file's default". [language] and [title] read those fields off a track.
T? _match<T>(
  List<T> tracks, {
  required String? Function(T) language,
  required String? Function(T) title,
  required TrackChoice pref,
}) {
  if (tracks.isEmpty || pref.isEmpty) return null;

  if (pref.hasLanguage) {
    for (final track in tracks) {
      if (languagesMatch(language(track), pref.language)) return track;
    }
  }
  if (pref.hasTitle) {
    for (final track in tracks) {
      if (titlesMatch(title(track), pref.title)) return track;
    }
  }
  return null;
}

/// The audio track matching [pref], or null to keep the file's default.
AudioTrack? matchAudioTrack(List<AudioTrack> tracks, TrackChoice pref) =>
    _match(tracks, language: (t) => t.language, title: (t) => t.title, pref: pref);

/// The subtitle track matching [pref], or null to keep the file's default.
SubtitleTrack? matchSubtitleTrack(List<SubtitleTrack> tracks, TrackChoice pref) =>
    _match(tracks, language: (t) => t.language, title: (t) => t.title, pref: pref);
