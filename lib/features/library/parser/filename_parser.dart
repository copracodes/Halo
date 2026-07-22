import '../../../core/constants/app_constants.dart';
import '../../../data/database/media_type.dart';
import 'parsed_media.dart';

/// Turns messy download filenames into structured [ParsedMedia].
///
/// Pure Dart, no Flutter — every rule is exercised by the table-driven test.
/// Given a filename (and, optionally, its parent folder names nearest-first),
/// it detects movies vs. TV episodes, pulls out title/year/season/episode, and
/// strips quality/source/codec/release junk.
class FilenameParser {
  const FilenameParser();

  ParsedMedia parse(String fileName, {List<String> parentFolders = const []}) {
    final base = _normalize(_stripExtension(fileName));

    return _tvInName(base) ??
        _folderBased(base, parentFolders) ??
        _anime(base) ??
        _movie(base);
  }

  // --- TV: patterns inside the filename ------------------------------------

  /// `S01E05`, and the same thing with the season and episode markers split by
  /// spaces or hyphens — `westworld-s2-e1`, `Show.S02.E01`. [_normalize] has
  /// already turned dots and underscores into spaces by this point, so those
  /// are the only separators left to allow. The runs are bounded to whitespace
  /// and hyphens, so a stray "e" word later in the name can't be swallowed.
  static final _reSxxExx = RegExp(
    r'(?<![a-z])s(\d{1,2})[\s-]*e(\d{1,3})(?:[\s-]*e(\d{1,3}))?',
    caseSensitive: false,
  );
  static final _reNxNN = RegExp(
    r'(?<![a-z0-9])(\d{1,2})x(\d{1,3})(?![0-9])',
    caseSensitive: false,
  );
  static final _reSeasonEpisode = RegExp(
    r'season\s*(\d{1,2})\s*episode\s*(\d{1,3})',
    caseSensitive: false,
  );

  ParsedMedia? _tvInName(String base) {
    for (final re in [_reSxxExx, _reNxNN, _reSeasonEpisode]) {
      final m = re.firstMatch(base);
      if (m == null) continue;
      final season = int.parse(m.group(1)!);
      final episode = int.parse(m.group(2)!);
      final endGroup = re == _reSxxExx ? m.group(3) : null;
      final title = _episodeTitle(base.substring(0, m.start));
      return ParsedMedia(
        mediaType: MediaType.episode,
        title: title,
        season: season,
        episode: episode,
        episodeEnd: endGroup == null ? null : int.parse(endGroup),
      );
    }
    return null;
  }

  // --- TV: season from a parent folder, episode from a leading number ------

  static final _reSeasonFolder =
      RegExp(r'^(?:season\s*|s)(\d{1,2})$', caseSensitive: false);
  static final _reLeadingNumber = RegExp(r'^(\d{1,3})(?![0-9])');

  ParsedMedia? _folderBased(String base, List<String> parentFolders) {
    for (var i = 0; i < parentFolders.length; i++) {
      final m = _reSeasonFolder.firstMatch(parentFolders[i].trim());
      if (m == null) continue;

      final lead = _reLeadingNumber.firstMatch(base);
      if (lead == null) return null; // no episode number to anchor on.

      // The show is the folder just outside the season folder.
      final show = i + 1 < parentFolders.length ? parentFolders[i + 1] : '';
      return ParsedMedia(
        mediaType: MediaType.episode,
        title: _titleCase(_collapse(show)),
        season: int.parse(m.group(1)!),
        episode: int.parse(lead.group(1)!),
      );
    }
    return null;
  }

  // --- Anime-style absolute numbering: "Show Name - 12" --------------------

  static final _reAnime = RegExp(r'^(.+?)\s*-\s*(\d{1,3})$');

  ParsedMedia? _anime(String base) {
    final m = _reAnime.firstMatch(_junkCut(base).trim());
    if (m == null) return null;
    final title = _titleCase(_collapse(m.group(1)!));
    if (title.isEmpty) return null;
    return ParsedMedia(
      mediaType: MediaType.episode,
      title: title,
      episode: int.parse(m.group(2)!),
    );
  }

  // --- Movies --------------------------------------------------------------

  static final _reYear = RegExp(r'(?<![0-9])(\d{4})(?![0-9])');

  ParsedMedia _movie(String base) {
    final preJunk = _junkCut(base);

    // Prefer the last standalone year in 1900–2030 that still leaves a title
    // in front of it (so "2012 2009" → title "2012", year 2009).
    int? year;
    var titleStr = preJunk;
    for (final m in _reYear.allMatches(preJunk)) {
      final value = int.parse(m.group(1)!);
      if (value < 1900 || value > 2030) continue;
      if (preJunk.substring(0, m.start).trim().isEmpty) continue;
      year = value;
      titleStr = preJunk.substring(0, m.start);
    }

    final title = _titleCase(_collapse(titleStr));
    if (title.isEmpty) {
      return ParsedMedia(mediaType: MediaType.unknown, title: _collapse(base));
    }
    return ParsedMedia(mediaType: MediaType.movie, title: title, year: year);
  }

  // --- Cleaning helpers ----------------------------------------------------

  String _episodeTitle(String before) {
    final title = _titleCase(_collapse(_junkCut(before)));
    return title;
  }

  static String _stripExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0) return fileName;
    final ext = fileName.substring(dot + 1).toLowerCase();
    return AppConstants.supportedVideoExtensions.contains(ext)
        ? fileName.substring(0, dot)
        : fileName;
  }

  /// Removes bracketed groups, turns separators into spaces, keeps hyphens.
  static String _normalize(String name) {
    return name
        .replaceAll(RegExp(r'\[[^\]]*\]'), ' ')
        .replaceAll(RegExp(r'\{[^}]*\}'), ' ')
        .replaceAll(RegExp(r'[()._]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _collapse(String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'^-+|-+$'), '').trim();

  /// Junk tokens (lowercase). Everything from the first one onward is dropped.
  static const _junk = {
    // resolution
    '480p', '540p', '576p', '720p', '900p', '1080p', '1440p', '2160p', '4320p',
    '4k', 'uhd',
    // source
    'web-dl', 'webdl', 'web-rip', 'webrip', 'bluray', 'blu-ray', 'brrip',
    'bdrip', 'bdremux', 'hdtv', 'pdtv', 'hdrip', 'dvdrip', 'remux', 'hdcam',
    // codec
    'x264', 'x265', 'h264', 'h265', 'hevc', 'avc', 'xvid', 'divx', 'av1', 'vp9',
    '10bit', '8bit', '10-bit',
    // audio
    'aac', 'ac3', 'eac3', 'dts', 'ddp', 'ddp5', 'dd5', 'truehd', 'atmos',
    'flac', 'opus',
    // hdr / misc
    'hdr', 'hdr10', 'dv', 'dovi', 'sdr', 'imax',
    // release flags
    'proper', 'repack', 'extended', 'unrated', 'remastered', 'limited',
    'internal', 'dual', 'multi', 'subs',
  };

  static final _reResolution = RegExp(r'^\d{3,4}p$');

  static bool _isJunk(String token) {
    final t = token.toLowerCase();
    return _junk.contains(t) || _reResolution.hasMatch(t);
  }

  /// Returns [s] truncated at the first junk token (release info), or all of it.
  static String _junkCut(String s) {
    final tokens = s.split(' ');
    var offset = 0;
    for (final token in tokens) {
      if (token.isNotEmpty && _isJunk(token)) {
        return s.substring(0, offset).trim();
      }
      offset += token.length + 1; // + the space
    }
    return s.trim();
  }

  static const _minorWords = {
    'a', 'an', 'and', 'as', 'at', 'but', 'by', 'for', 'from', 'in', 'into',
    'nor', 'of', 'on', 'onto', 'or', 'over', 'the', 'to', 'up', 'via', 'vs',
    'with',
  };

  /// Capitalizes each word (and each hyphen-separated part, so "spider-man" →
  /// "Spider-Man"), keeping minor words lowercase unless they lead the title.
  static String _titleCase(String s) {
    final words = s.split(' ').where((w) => w.isNotEmpty).toList();
    for (var i = 0; i < words.length; i++) {
      final lower = words[i].toLowerCase();
      if (i > 0 && _minorWords.contains(lower)) {
        words[i] = lower;
      } else {
        words[i] = words[i].split('-').map(_capitalize).join('-');
      }
    }
    return words.join(' ');
  }

  static String _capitalize(String w) =>
      w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase();
}
