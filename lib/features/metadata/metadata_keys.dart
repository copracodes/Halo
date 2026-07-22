/// Identity keys that decide which library files share one metadata record.
/// Pure string work — no Flutter, no I/O.
library;

/// Strips case, punctuation, and spacing differences so cosmetic variations in
/// a filename don't fork a title into two records.
String normalizeTitle(String title) {
  final lowered = title.toLowerCase().trim();
  final stripped = lowered
      // Punctuation that filenames add or drop freely.
      .replaceAll(RegExp(r"[._\-:;,'’!?()\[\]{}]"), ' ')
      // Ampersand and "and" are used interchangeably in titles.
      .replaceAll(' & ', ' and ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return stripped;
}

/// Key for a movie's metadata record: normalised title plus year.
///
/// Every file that parses to the same title *and* year shares one record, so a
/// 720p and a 1080p rip of one film are matched once and shown once. Two films
/// with the same title from different years stay separate, which is exactly
/// what distinguishes a remake from a duplicate.
String movieKeyFor(String title, int? year) {
  final normalized = normalizeTitle(title);
  return year == null ? normalized : '$normalized|$year';
}

/// Key for a show's metadata record. Shows have no year in Halo's parser
/// output, so the normalised title alone identifies them — the same basis
/// `groupIntoShows` already uses to build show cards.
String showKeyFor(String title) => normalizeTitle(title);
