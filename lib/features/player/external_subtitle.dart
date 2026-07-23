import '../../data/database/subtitle_source.dart';

/// An external subtitle file offered for a video: a sidecar found next to it, or
/// one the user loaded by hand. Distinct from the embedded subtitle tracks
/// inside the video (media_kit's own [SubtitleTrack]s).
class ExternalSubtitle {
  const ExternalSubtitle({
    required this.uri,
    this.lang,
    required this.source,
    this.selected = false,
  });

  /// The subtitle file's handle: a SAF `content://` URI, or a real path for a
  /// manually picked file.
  final String uri;

  /// Language code from the filename (`en`), or null when it carried none.
  final String? lang;

  final SubtitleSource source;

  /// Whether this is the track the viewer last chose for this video — the one to
  /// re-activate automatically on reopen.
  final bool selected;
}
