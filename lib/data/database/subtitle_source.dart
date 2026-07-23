/// Where an external subtitle association came from. Kept dependency-free so the
/// pure sidecar-matching logic can use it without importing the drift database.
enum SubtitleSource {
  /// Discovered next to the video during a scan, by naming convention.
  sidecar,

  /// Chosen by the user with "Load subtitle file…".
  manual,

  /// Fetched online (a future phase; reserved so the schema doesn't churn).
  downloaded,
}
