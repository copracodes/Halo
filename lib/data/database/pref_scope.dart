/// What a [PlaybackPrefs] row applies to. Kept in its own dependency-free file
/// so the pure resolution logic can use it without importing the drift database
/// (which pulls in Flutter).
enum PrefScope {
  /// A single TV show, keyed by its show key. Every episode of the show shares
  /// these preferences.
  show,

  /// A single film, keyed by its movie key.
  movie,

  /// The app-wide fallback, with an empty scope key. Its language defaults feed
  /// every title that hasn't overridden them.
  global,
}
