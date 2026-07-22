/// Reads a release's quality out of its filename, for the discreet "which
/// version is this" line on detail screens. Pure string work.
library;

/// Resolution tags, richest first so `2160p` wins over a stray `1080`.
const _resolutions = <String, String>{
  '2160p': '4K',
  '4320p': '8K',
  '1440p': '1440p',
  '1080p': '1080p',
  '720p': '720p',
  '576p': '576p',
  '480p': '480p',
  'uhd': '4K',
  '4k': '4K',
};

/// Source tags worth showing; a Blu-ray rip and a cam of the same film are not
/// the same viewing experience.
const _sources = <String, String>{
  'bluray': 'BluRay',
  'blu-ray': 'BluRay',
  'bdrip': 'BluRay',
  'bdremux': 'Remux',
  'remux': 'Remux',
  'web-dl': 'WEB-DL',
  'webdl': 'WEB-DL',
  'webrip': 'WEBRip',
  'web-rip': 'WEBRip',
  'hdtv': 'HDTV',
  'dvdrip': 'DVD',
  'hdcam': 'CAM',
};

/// A short quality label like `1080p · BluRay`, or null when the filename says
/// nothing useful. Null means "show nothing" — an invented label would be
/// worse than none.
String? qualityLabel(String fileName) {
  final name = fileName.toLowerCase();

  /// Matches [tag] as a standalone term. Deliberately *not* a token split:
  /// several real tags contain a hyphen (`web-dl`, `blu-ray`), and splitting
  /// on separators would tear them in half. Boundaries are "not a letter or
  /// digit", so every separator style works and `480` inside `s01e480` can't
  /// masquerade as a resolution.
  bool hasTag(String tag) {
    final pattern = RegExp(
      '(?<![a-z0-9])${RegExp.escape(tag)}(?![a-z0-9])',
    );
    return pattern.hasMatch(name);
  }

  String? resolution;
  for (final entry in _resolutions.entries) {
    if (hasTag(entry.key)) {
      resolution = entry.value;
      break;
    }
  }

  String? source;
  for (final entry in _sources.entries) {
    if (hasTag(entry.key)) {
      source = entry.value;
      break;
    }
  }

  final parts = [
    if (resolution != null) resolution,
    if (source != null) source,
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// Human-readable file size. Kept here so the detail screen and the episode
/// list format sizes identically.
String formatFileSize(int bytes) {
  const gb = 1024 * 1024 * 1024;
  const mb = 1024 * 1024;
  if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(1)} GB';
  if (bytes >= mb) return '${(bytes / mb).round()} MB';
  return '${(bytes / 1024).round()} KB';
}
