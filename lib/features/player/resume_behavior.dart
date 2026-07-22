/// What the player should do about a saved position when it opens.
///
/// One intent rather than a pair of booleans, because the three cases are
/// mutually exclusive and the call site always knows which one it means.
enum ResumeBehavior {
  /// Offer the choice. What tapping a title from a grid does.
  ask,

  /// Continue silently from the saved point — the tap already *was* the
  /// choice, as on a Continue Watching card or a "Resume" button.
  resume,

  /// Begin at the start, ignoring any saved position. The explicit
  /// "Start over" action.
  restart,
}
