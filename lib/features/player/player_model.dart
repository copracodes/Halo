import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Top-level screen phase.
enum PlayerPhase { loading, ready, error }

/// What the transient gesture indicator is currently showing.
enum GestureHintKind { none, seekBackward, seekForward, brightness, volume, scrub }

/// A short-lived piece of on-screen feedback for a gesture (the "-10s" ripple,
/// the brightness/volume level bar, or the scrub time preview). Lives in the
/// notifier state so widgets stay pure renderers.
class GestureHint {
  const GestureHint({
    required this.kind,
    this.level = 0,
    this.target = Duration.zero,
    this.delta = Duration.zero,
  });

  static const none = GestureHint(kind: GestureHintKind.none);

  final GestureHintKind kind;

  /// 0–1 fill level for brightness/volume hints.
  final double level;

  /// Preview position for the scrub hint.
  final Duration target;

  /// Signed offset for the scrub hint (relative to where the drag began).
  final Duration delta;

  bool get isVisible => kind != GestureHintKind.none;
}

/// Immutable snapshot of everything the player screen renders. All playback and
/// control state lives here in the notifier's state — widgets only read it and
/// call methods; they never hold player state of their own (aside from the
/// transient finger position while actively dragging).
class PlayerModel {
  const PlayerModel({
    required this.phase,
    required this.title,
    this.errorMessage,
    this.controller,
    this.playing = false,
    this.buffering = true,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffer = Duration.zero,
    this.rate = 1.0,
    this.volume = 100.0,
    this.muted = false,
    this.controlsVisible = true,
    this.isFullscreen = false,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.activeAudioId,
    this.activeSubtitleId,
    this.hint = GestureHint.none,
    this.resumeFrom,
  });

  factory PlayerModel.initial(String title) =>
      PlayerModel(phase: PlayerPhase.loading, title: title);

  final PlayerPhase phase;
  final String title;
  final String? errorMessage;

  /// Backs the `Video` widget. Set once, when playback becomes ready.
  final VideoController? controller;

  final bool playing;
  final bool buffering;
  final Duration position;
  final Duration duration;

  /// How far the media is buffered, as an absolute position from the start.
  final Duration buffer;
  final double rate;

  /// media_kit player volume (0–100) and mute state. Adjusted by desktop
  /// keyboard shortcuts; mobile swipes drive *system* volume via a plugin.
  final double volume;
  final bool muted;

  final bool controlsVisible;
  final bool isFullscreen;

  /// Real embedded tracks reported by media_kit (pseudo `auto`/`no` removed).
  final List<AudioTrack> audioTracks;
  final List<SubtitleTrack> subtitleTracks;

  /// Id of the currently selected track (`'no'` means subtitles are off).
  final String? activeAudioId;
  final String? activeSubtitleId;

  /// Current transient gesture indicator.
  final GestureHint hint;

  /// When non-null, a saved position is being offered via the resume prompt.
  final Duration? resumeFrom;

  /// Sentinel so [copyWith] can distinguish "leave unchanged" from "set null"
  /// for the nullable [resumeFrom].
  static const Object _unset = Object();

  PlayerModel copyWith({
    PlayerPhase? phase,
    String? title,
    String? errorMessage,
    VideoController? controller,
    bool? playing,
    bool? buffering,
    Duration? position,
    Duration? duration,
    Duration? buffer,
    double? rate,
    double? volume,
    bool? muted,
    bool? controlsVisible,
    bool? isFullscreen,
    List<AudioTrack>? audioTracks,
    List<SubtitleTrack>? subtitleTracks,
    String? activeAudioId,
    String? activeSubtitleId,
    GestureHint? hint,
    Object? resumeFrom = _unset,
  }) {
    return PlayerModel(
      phase: phase ?? this.phase,
      title: title ?? this.title,
      errorMessage: errorMessage ?? this.errorMessage,
      controller: controller ?? this.controller,
      playing: playing ?? this.playing,
      buffering: buffering ?? this.buffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffer: buffer ?? this.buffer,
      rate: rate ?? this.rate,
      volume: volume ?? this.volume,
      muted: muted ?? this.muted,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
      activeAudioId: activeAudioId ?? this.activeAudioId,
      activeSubtitleId: activeSubtitleId ?? this.activeSubtitleId,
      hint: hint ?? this.hint,
      resumeFrom: identical(resumeFrom, _unset)
          ? this.resumeFrom
          : resumeFrom as Duration?,
    );
  }
}
