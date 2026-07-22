/// How a library title came to be associated (or not) with a TMDB entry.
///
/// Kept in its own dependency-free file so the pure matching logic can use it
/// without importing the drift database (which pulls in Flutter).
enum MatchStatus {
  /// Queued: discovered by a scan, not yet looked up.
  pending,

  /// Matched automatically, above the confidence threshold.
  auto,

  /// Confirmed or corrected by the user. Never overwritten by a later
  /// automatic pass — a human decision outranks the scorer.
  manual,

  /// Searched, but nothing scored well enough to accept. Surfaced for review
  /// in 3.4 rather than guessed at.
  needsReview,

  /// Searched, and TMDB returned nothing at all.
  unmatched,
}

/// Whether an automatic pass is allowed to overwrite this record.
bool isAutoWritable(MatchStatus status) => status != MatchStatus.manual;
