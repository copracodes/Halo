/// Pure decisions about "resume where I left off", with no I/O so they can be
/// unit-tested in isolation. Both the offer (on open) and the persist (every few
/// seconds / on exit) use the same window, keeping the two in lockstep.
class ResumePolicy {
  const ResumePolicy();

  /// Only resume once the user is at least this far in — below it, starting over
  /// is effectively the same and a prompt would just be noise.
  static const minPosition = Duration(seconds: 30);

  /// Never resume (or persist) within this much of the end, so we don't drop the
  /// viewer back into the closing credits of something they basically finished.
  static const endGuard = Duration(minutes: 2);

  /// Whether a saved [position] in a video of [duration] is worth offering as a
  /// resume point.
  bool shouldOffer(Duration position, Duration duration) {
    if (duration <= Duration.zero) return false;
    return position >= minPosition && position <= duration - endGuard;
  }

  /// Whether the current [position] is worth persisting. Mirrors [shouldOffer]:
  /// if it isn't worth offering, it isn't worth keeping.
  bool shouldPersist(Duration position, Duration duration) =>
      shouldOffer(position, duration);
}
