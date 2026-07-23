import '../player/track_matching.dart';
import 'folder_access/folder_access.dart';
import 'media_display.dart';

/// Subtitle file extensions Halo recognises as sidecars.
const Set<String> subtitleExtensions = {'srt', 'ass', 'ssa', 'vtt', 'sub'};

/// Whether [fileName] is a subtitle file by extension.
bool isSubtitleFile(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot < 0 || dot == fileName.length - 1) return false;
  return subtitleExtensions.contains(fileName.substring(dot + 1).toLowerCase());
}

/// The language code embedded in a subtitle filename's trailing token
/// (`Movie.en.srt` → `en`), or null when the last token isn't a language. Used
/// for hand-loaded files, whose names don't line up against a video basename.
String? languageFromSubtitleName(String fileName) {
  final base = stripExtension(fileName);
  final token = base.split('.').last;
  return isLanguageTag(token) ? normalizeLanguage(token) : null;
}

/// A subtitle-to-video association discovered by convention.
class SubtitleLink {
  const SubtitleLink({
    required this.videoUri,
    required this.subtitleUri,
    this.lang,
  });

  final String videoUri;
  final String subtitleUri;
  final String? lang;
}

/// The result of testing one subtitle name against one video name.
class SidecarNameMatch {
  const SidecarNameMatch(this.lang);

  /// The language code carried in the filename suffix, or null.
  final String? lang;
}

/// Whether [subtitleName] is a sidecar for [videoName] by naming convention:
/// the exact basename (`Ep.S01E01.srt`), or the basename plus a language suffix
/// (`Ep.S01E01.en.srt`, `.eng.srt`). Returns the match (with any language it
/// found) or null. A subtitle sharing the basename but with a non-language
/// suffix (`.forced`) still matches, just without a language.
SidecarNameMatch? matchSidecarName(String videoName, String subtitleName) {
  if (!isSubtitleFile(subtitleName)) return null;

  final videoBase = stripExtension(videoName).toLowerCase();
  final subtitleBase = stripExtension(subtitleName).toLowerCase();
  if (videoBase.isEmpty || subtitleBase.isEmpty) return null;

  if (subtitleBase == videoBase) return const SidecarNameMatch(null);

  if (subtitleBase.startsWith('$videoBase.')) {
    final suffix = subtitleBase.substring(videoBase.length + 1);
    final token = suffix.split('.').first;
    return SidecarNameMatch(isLanguageTag(token) ? normalizeLanguage(token) : null);
  }

  return null;
}

/// Links subtitle files to the videos they belong to.
///
/// A subtitle qualifies for a video when its name matches (see
/// [matchSidecarName]) and it sits either in the same directory or in a `Subs`
/// (or `Subtitles`) subfolder directly beneath it. Directory identity comes from
/// [ScannedFile.parentPath].
List<SubtitleLink> linkSubtitles({
  required List<ScannedFile> videos,
  required List<ScannedFile> subtitles,
}) {
  final links = <SubtitleLink>[];
  for (final subtitle in subtitles) {
    for (final video in videos) {
      if (!_sharesLocation(video.parentPath, subtitle.parentPath)) continue;
      final match = matchSidecarName(video.name, subtitle.name);
      if (match == null) continue;
      links.add(SubtitleLink(
        videoUri: video.uri,
        subtitleUri: subtitle.uri,
        lang: match.lang,
      ));
    }
  }
  return links;
}

/// Subfolder names accepted as a subtitle drop next to the videos.
const Set<String> _subsFolderNames = {'subs', 'subtitles'};

/// Whether a subtitle at [subtitlePath] sits alongside a video at [videoPath]:
/// the same directory, or a `Subs`/`Subtitles` folder directly beneath it.
/// Paths are nearest-first ancestor lists (see [ScannedFile.parentPath]).
bool _sharesLocation(List<String> videoPath, List<String> subtitlePath) {
  if (_listEquals(videoPath, subtitlePath)) return true;
  if (subtitlePath.length == videoPath.length + 1 &&
      _subsFolderNames.contains(subtitlePath.first.toLowerCase()) &&
      _listEquals(subtitlePath.sublist(1), videoPath)) {
    return true;
  }
  return false;
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
