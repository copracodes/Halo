/// What should happen to the stored resume point for a file.
enum ProgressAction {
  /// Write the current position over whatever is stored.
  save,

  /// Throw the stored position away — the viewer is effectively at the start,
  /// or so near the end that resuming would be pointless.
  discard,

  /// Leave the stored position exactly as it is.
  keep,
}

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

  /// What to do with the stored resume point, given where the player currently
  /// is.
  ///
  /// [restored] means this session opened *from* a saved position. That single
  /// bit is what stops resume from being single-use: for the first moments
  /// after opening, the player reports a position near zero because the seek to
  /// the resume point hasn't landed yet. Read literally that looks like "the
  /// viewer is at the start, discard the bookmark" — so the periodic save wipes
  /// the very position it just resumed from, and the next open starts over.
  /// When a position was restored, a low reading is treated as "not caught up
  /// yet" and the stored point is kept.
  ///
  /// A deliberate start-over clears [restored] at the call site, so choosing to
  /// rewatch from the beginning does still discard the old point.
  ProgressAction actionFor(
    Duration position,
    Duration duration, {
    required bool restored,
  }) {
    // Nothing meaningful can be decided before the duration is known.
    if (duration <= Duration.zero) return ProgressAction.keep;
    if (shouldPersist(position, duration)) return ProgressAction.save;
    return restored ? ProgressAction.keep : ProgressAction.discard;
  }
}
