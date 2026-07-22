import 'dart:async';
import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../data/repositories/progress_repository.dart';
import 'player_engine.dart';
import 'resume_behavior.dart';
import 'player_model.dart';
import 'resume_policy.dart';

/// How long controls stay up after the last interaction while playing.
const _autoHideDelay = Duration(seconds: 3);

/// How far the skip-back / skip-forward buttons jump.
const _skipStep = Duration(seconds: 10);

/// How long a gesture indicator lingers after a discrete gesture (double tap).
const _hintLinger = Duration(milliseconds: 700);

/// Keyboard/step volume increment, in media_kit's 0–100 scale.
const _volumeStep = 5.0;

/// How often the current position is persisted for resume.
const _saveInterval = Duration(seconds: 5);

/// How long the resume prompt lingers before it auto-dismisses and continues.
const _resumePromptTimeout = Duration(seconds: 12);

/// How far playback may sit from the requested resume point before it counts as
/// having missed it. Keyframe snapping moves a start position by a second or
/// two, which is not worth a corrective seek.
const _resumeDrift = Duration(seconds: 5);

/// Owns the media_kit [Player]/[VideoController] and every piece of playback and
/// control state for a single video. Widgets read [PlayerModel] and call these
/// methods; no playback logic lives in the widgets.
class PlayerController extends Notifier<PlayerModel> {
  /// How a [PlayerEngine] is created. Overridable in tests.
  @visibleForTesting
  static PlayerEngine Function() engineFactory = MediaKitEngine.new;

  /// App-wide single active engine. Creating a new one disposes any existing
  /// one first, so a leaked/duplicate player can never keep playing.
  static PlayerEngine? _activeEngine;

  PlayerEngine? _engine;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _hideTimer;
  Timer? _hintTimer;
  Timer? _saveTimer;
  Timer? _resumePromptTimer;

  static const _policy = ResumePolicy();

  /// Resolved from the provider on [open] and cached so [_teardown] can persist
  /// a final position after the notifier (and its `ref`) are disposed.
  ProgressRepository? _progress;

  /// Stable identity used for resume/progress: the file's content URI (or a
  /// name+size fallback), so reopening the same title resumes even though its
  /// playback path may change. On Android the picked file's path can be a
  /// throwaway cache copy that differs every open, so it must NOT be the key;
  /// this falls back to that path only when no id is supplied.
  String _progressKey = '';
  Duration? _savedResume;
  bool _resumeChecked = false;

  /// What to do about a saved position on this open.
  ResumeBehavior _behavior = ResumeBehavior.ask;

  /// The stored position this session opened from, if there was one. Guards
  /// that point against being erased before playback has caught up to it (see
  /// [ResumePolicy.actionFor]). Cleared by [startOver], which is the viewer
  /// explicitly abandoning it.
  Duration? _restoredFrom;

  /// Whether the file was opened positioned at [_savedResume] rather than at
  /// the start.
  bool _openedAtResume = false;

  /// Cached position/duration so teardown can persist without reading `state`
  /// (which throws once the notifier is disposed).
  Duration _lastPosition = Duration.zero;
  Duration _lastDuration = Duration.zero;

  /// Values captured at the start of a vertical/horizontal drag so updates can
  /// be applied relative to where the finger first went down.
  double _dragStartLevel = 0;
  Duration _dragStartPosition = Duration.zero;

  /// Player volume to restore when unmuting.
  double _volumeBeforeMute = 100.0;

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  @override
  PlayerModel build() {
    // Auto-dispose: fires when the screen is popped and nothing watches this.
    ref.onDispose(_teardown);
    return PlayerModel.initial('');
  }

  /// Attaches an already-constructed engine as the active player, bypassing
  /// [open]. Only for tests that exercise the disposal path without a real
  /// (native) player.
  @visibleForTesting
  void debugAttachEngine(PlayerEngine engine) {
    _engine = engine;
    _activeEngine = engine;
  }

  /// Creates the player, opens [path], and starts playback. Idempotent.
  ///
  /// [mediaId] is a stable identity for the file (its content URI, or a
  /// name+size key) used for resume/progress; when omitted, [path] is used,
  /// which is only reliable if the path itself is stable across opens.
  ///
  /// [title] is what the top bar shows; without one it is derived from [path],
  /// which only reads well for real filesystem paths. [behavior] decides
  /// whether a saved position is offered, used silently, or ignored.
  Future<void> open(
    String path, {
    String? mediaId,
    String? title,
    ResumeBehavior behavior = ResumeBehavior.ask,
  }) async {
    if (_engine != null) return;
    _progressKey = mediaId ?? path;
    _behavior = behavior;
    _progress = ref.read(progressRepositoryProvider);

    state = PlayerModel.initial(title ?? _titleFromPath(path));

    // Enter the immersive, landscape player chrome on mobile (applies to the
    // error card too, so the whole screen is consistent). Restored on exit in
    // _teardown, which runs on every exit path.
    if (_isMobile) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      state = state.copyWith(isFullscreen: true);
    }

    // Fail fast with a friendly message if the file is gone (moved/deleted).
    // Library files are SAF content:// URIs, which aren't filesystem paths —
    // media_kit resolves those to a file descriptor itself, and a missing one
    // surfaces through the normal open() failure below.
    if (!_isContentUri(path) && !File(path).existsSync()) {
      state = state.copyWith(
        phase: PlayerPhase.error,
        errorMessage:
            "This file couldn't be found. It may have been moved or deleted.",
      );
      return;
    }

    // Load any saved resume position before opening; evaluated once we know
    // the duration (see _maybeOfferResume).
    final saved = await _progress!.resumeStateFor(_progressKey);
    _savedResume = saved?.position;
    // Guard it from the moment it is read: the periodic save starts running
    // well before playback has reached this point.
    _restoredFrom = _savedResume;

    // Decide here, before opening, whether this position is worth resuming
    // from — using the duration stored alongside it, since the real one isn't
    // known until the file is loaded. The payoff is that playback can *begin*
    // at the resume point (see [PlayerEngine.open]) instead of starting at
    // zero and seeking, which races the demuxer and visibly snaps back.
    // "Start over" ignores the saved point entirely: nothing to open at, and
    // nothing to protect from being overwritten.
    _openedAtResume = _behavior != ResumeBehavior.restart &&
        saved != null &&
        saved.duration > Duration.zero &&
        _policy.shouldOffer(saved.position, saved.duration);
    if (_behavior == ResumeBehavior.restart) _restoredFrom = null;

    // Single-player guard: dispose any engine still alive app-wide before
    // creating a new one, so two players can never play at once.
    await _activeEngine?.dispose();

    final engine = engineFactory();
    _engine = engine;
    _activeEngine = engine;

    _listen(engine.stream);

    // Only open() itself represents a "can't play this file" failure; state
    // mutations stay outside the try so framework errors surface as real bugs.
    try {
      await engine.open(
        path,
        startAt: _openedAtResume ? _savedResume : null,
      );
    } on Object catch (error) {
      state = state.copyWith(
        phase: PlayerPhase.error,
        errorMessage: 'This video could not be played. It may use an '
            'unsupported format or codec.\n$error',
      );
      return;
    }

    if (state.phase != PlayerPhase.error) {
      state = state.copyWith(
        phase: PlayerPhase.ready,
        controller: engine.videoController,
      );
      _saveTimer = Timer.periodic(_saveInterval, (_) => _persistPosition());
    }
  }

  void _listen(PlayerStream stream) {
    _subscriptions.addAll([
      stream.playing.listen(_onPlayingChanged),
      stream.buffering.listen((v) => state = state.copyWith(buffering: v)),
      stream.position.listen(_onPosition),
      stream.duration.listen(_onDuration),
      stream.buffer.listen((v) => state = state.copyWith(buffer: v)),
      stream.rate.listen((v) => state = state.copyWith(rate: v)),
      stream.tracks.listen(_onTracks),
      stream.track.listen(_onTrackSelection),
      stream.completed.listen(_onCompleted),
      stream.error.listen((message) {
        if (message.isNotEmpty) {
          state = state.copyWith(
            phase: PlayerPhase.error,
            errorMessage: 'This video could not be played. It may use an '
                'unsupported format or codec.\n$message',
          );
        }
      }),
    ]);
  }

  void _onPosition(Duration position) {
    _lastPosition = position;
    state = state.copyWith(position: position);
  }

  void _onDuration(Duration duration) {
    _lastDuration = duration;
    state = state.copyWith(duration: duration);
    _maybeOfferResume(duration);
  }

  void _onCompleted(bool completed) {
    // Finished watching — mark it done so it's no longer offered for resume.
    if (completed) {
      _progress?.markFinished(_progressKey);
    }
  }

  void _onPlayingChanged(bool playing) {
    // Paused controls stay up; playing schedules an auto-hide.
    state = state.copyWith(
      playing: playing,
      controlsVisible: playing ? state.controlsVisible : true,
    );
    // Keep the screen awake only while actually playing.
    WakelockPlus.toggle(enable: playing);
    _restartHideTimer();
  }

  void _onTracks(Tracks tracks) {
    bool real(String id) => id != 'auto' && id != 'no';
    state = state.copyWith(
      audioTracks: tracks.audio.where((t) => real(t.id)).toList(),
      subtitleTracks: tracks.subtitle.where((t) => real(t.id)).toList(),
    );
  }

  void _onTrackSelection(Track track) {
    state = state.copyWith(
      activeAudioId: track.audio.id,
      activeSubtitleId: track.subtitle.id,
    );
  }

  // --- User actions -------------------------------------------------------

  void togglePlayPause() {
    _engine?.playOrPause();
    _kick();
  }

  void skipForward() {
    final target = state.position + _skipStep;
    final max = state.duration;
    _engine?.seek(target > max ? max : target);
    _kick();
  }

  void skipBackward() {
    final target = state.position - _skipStep;
    _engine?.seek(target < Duration.zero ? Duration.zero : target);
    _kick();
  }

  void seekTo(Duration position) {
    _engine?.seek(position);
    _kick();
  }

  void setRate(double rate) {
    _engine?.setRate(rate);
    _kick();
  }

  void selectAudioTrack(String id) {
    for (final track in state.audioTracks) {
      if (track.id == id) {
        _engine?.setAudioTrack(track);
        break;
      }
    }
    _kick();
  }

  /// Selects a subtitle track by id, or turns subtitles off for id `'no'`.
  void selectSubtitleTrack(String id) {
    if (id == 'no') {
      _engine?.setSubtitleTrack(SubtitleTrack.no());
    } else {
      for (final track in state.subtitleTracks) {
        if (track.id == id) {
          _engine?.setSubtitleTrack(track);
          break;
        }
      }
    }
    _kick();
  }

  void toggleFullscreen() => _setFullscreen(!state.isFullscreen);

  void exitFullscreen() {
    if (state.isFullscreen) _setFullscreen(false);
  }

  void _setFullscreen(bool value) {
    SystemChrome.setEnabledSystemUIMode(
      value ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
    state = state.copyWith(isFullscreen: value);
    _kick();
  }

  // --- Player volume & mute (desktop keyboard) ----------------------------

  void volumeUp() => _setVolume(state.volume + _volumeStep);
  void volumeDown() => _setVolume(state.volume - _volumeStep);

  void _setVolume(double volume) {
    final clamped = volume.clamp(0.0, 100.0);
    _engine?.setVolume(clamped);
    state = state.copyWith(volume: clamped, muted: clamped == 0);
    _showHint(GestureHint(
      kind: GestureHintKind.volume,
      level: clamped / 100,
    ));
    _kick();
  }

  void toggleMute() {
    if (state.muted || state.volume == 0) {
      _setVolume(_volumeBeforeMute == 0 ? 100 : _volumeBeforeMute);
    } else {
      _volumeBeforeMute = state.volume;
      _setVolume(0);
    }
  }

  // --- Double-tap seek ----------------------------------------------------

  /// Seeks ±10s from a double tap and flashes a "-10s"/"+10s" indicator,
  /// without forcing the controls to appear.
  void doubleTapSeek({required bool forward}) {
    final target = forward ? state.position + _skipStep : state.position - _skipStep;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > state.duration ? state.duration : target);
    _engine?.seek(clamped);
    _showHint(
      GestureHint(
        kind: forward ? GestureHintKind.seekForward : GestureHintKind.seekBackward,
      ),
      linger: _hintLinger,
    );
  }

  // --- Vertical drag: brightness (left) & system volume (right) -----------

  Future<void> startBrightnessDrag() async {
    if (!_isMobile) return;
    try {
      _dragStartLevel = await ScreenBrightness.instance.application;
    } on Object {
      _dragStartLevel = 1.0;
    }
  }

  void updateBrightnessDrag(double deltaFraction) {
    if (!_isMobile) return;
    final level = (_dragStartLevel + deltaFraction).clamp(0.0, 1.0);
    ScreenBrightness.instance.setApplicationScreenBrightness(level);
    _showHint(GestureHint(kind: GestureHintKind.brightness, level: level));
  }

  Future<void> startVolumeDrag() async {
    if (!_isMobile) return;
    VolumeController.instance.showSystemUI = false;
    try {
      _dragStartLevel = await VolumeController.instance.getVolume();
    } on Object {
      _dragStartLevel = 0.5;
    }
  }

  void updateVolumeDrag(double deltaFraction) {
    if (!_isMobile) return;
    final level = (_dragStartLevel + deltaFraction).clamp(0.0, 1.0);
    VolumeController.instance.setVolume(level);
    _showHint(GestureHint(kind: GestureHintKind.volume, level: level));
  }

  /// Ends a brightness/volume/scrub drag by clearing the indicator.
  void endVerticalDrag() => _clearHint();

  // --- Horizontal drag: scrub ---------------------------------------------

  void startScrub() {
    _dragStartPosition = state.position;
  }

  void updateScrub(double deltaFraction) {
    final delta = Duration(
      milliseconds: (state.duration.inMilliseconds * deltaFraction).round(),
    );
    final target = _dragStartPosition + delta;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > state.duration ? state.duration : target);
    _showHint(GestureHint(
      kind: GestureHintKind.scrub,
      target: clamped,
      delta: clamped - _dragStartPosition,
    ));
  }

  void endScrub() {
    if (state.hint.kind == GestureHintKind.scrub) {
      _engine?.seek(state.hint.target);
    }
    _clearHint();
  }

  // --- Resume where I left off --------------------------------------------

  /// Once the duration is known, decide what to do about the saved position.
  /// Runs at most once per open.
  ///
  /// Playback is already sitting at that position — [open] started the file
  /// there — so nothing here seeks. Continue Watching simply carries on; every
  /// other entry point pauses and asks.
  void _maybeOfferResume(Duration duration) {
    if (_resumeChecked || duration <= Duration.zero) return;
    _resumeChecked = true;

    final saved = _savedResume;
    if (saved == null || !_openedAtResume) return;
    // The real duration can differ from the one recorded alongside the
    // position; re-check against it before putting the choice to the viewer.
    if (!_policy.shouldOffer(saved, duration)) return;

    // The tap already answered the question; don't ask it again.
    if (_behavior == ResumeBehavior.resume) return;

    // Hold here until the user chooses, auto-continuing if they don't.
    _engine?.pause();
    state = state.copyWith(resumeFrom: saved);
    _resumePromptTimer = Timer(_resumePromptTimeout, () => _dismissResume(play: true));
  }

  void resumeFromSaved() {
    final target = state.resumeFrom;
    // Normally a no-op: the file was opened at this point. The seek is a
    // fallback for a format where mpv's start option didn't take, so "Resume"
    // is never a lie.
    if (target != null && (_lastPosition - target).abs() > _resumeDrift) {
      _engine?.seek(target);
    }
    _dismissResume(play: true);
  }

  void startOver() {
    // Deliberately abandoning the saved point, so stop protecting it — from
    // here a low position really does mean "back at the start".
    _restoredFrom = null;
    _engine?.seek(Duration.zero);
    _dismissResume(play: true);
  }

  void _dismissResume({required bool play}) {
    _resumePromptTimer?.cancel();
    if (play) _engine?.play();
    if (state.resumeFrom != null) {
      state = state.copyWith(resumeFrom: null);
    }
  }

  void _persistPosition() {
    // Uses cached fields, not `state`, so it is safe to call during teardown.
    final progress = _progress;
    if (progress == null) return;
    final position = _lastPosition;
    final duration = _lastDuration;

    switch (_policy.actionFor(
      position,
      duration,
      restored: _restoredFrom != null,
    )) {
      case ProgressAction.save:
        progress.savePosition(
          _progressKey,
          position: position,
          duration: duration,
        );
      case ProgressAction.discard:
        progress.clearProgress(_progressKey);
      case ProgressAction.keep:
        break;
    }
  }

  /// Pause when the app is backgrounded on mobile (called by the screen's
  /// lifecycle observer) so audio doesn't keep playing off-screen.
  void pauseForBackground() => _engine?.pause();

  // --- Gesture hint plumbing ----------------------------------------------

  void _showHint(GestureHint hint, {Duration? linger}) {
    _hintTimer?.cancel();
    state = state.copyWith(hint: hint);
    if (linger != null) {
      _hintTimer = Timer(linger, _clearHint);
    }
  }

  void _clearHint() {
    _hintTimer?.cancel();
    if (state.hint.isVisible) {
      state = state.copyWith(hint: GestureHint.none);
    }
  }

  /// Toggles control visibility (the tap-anywhere gesture).
  void toggleControls() {
    if (state.controlsVisible) {
      _hideTimer?.cancel();
      state = state.copyWith(controlsVisible: false);
    } else {
      _showControls();
    }
  }

  void _showControls() {
    state = state.copyWith(controlsVisible: true);
    _restartHideTimer();
  }

  /// Keep controls up and reset the countdown after an interaction.
  void _kick() => _showControls();

  void _restartHideTimer() {
    _hideTimer?.cancel();
    if (state.playing && state.controlsVisible) {
      _hideTimer = Timer(_autoHideDelay, () {
        state = state.copyWith(controlsVisible: false);
      });
    }
  }

  /// Runs when the provider is disposed (screen popped). Ordered so the native
  /// player is always torn down: nothing that could throw runs before it, and
  /// every step after it is wrapped so a failure can't leave the player alive.
  void _teardown() {
    // 1. CRITICAL, FIRST: stop and dispose the native player so audio stops
    //    immediately. Never gated behind anything that can throw.
    final engine = _engine;
    _engine = null;
    if (identical(_activeEngine, engine)) _activeEngine = null;
    if (engine != null) {
      // pause() is a synchronous command for an instant stop; dispose() then
      // releases the native instance (its future is intentionally not awaited).
      engine.pause();
      engine.dispose();
    }

    // 2. Cancel timers and stream subscriptions (best effort).
    _hideTimer?.cancel();
    _hintTimer?.cancel();
    _saveTimer?.cancel();
    _resumePromptTimer?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    // 3. Persist a final resume position from cached values (not `state`, which
    //    is no longer readable), and restore system state. All guarded so a
    //    plugin/platform failure can never resurrect the player.
    try {
      _persistPosition();
      WakelockPlus.disable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (_isMobile) {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        ScreenBrightness.instance
            .resetApplicationScreenBrightness()
            .ignore();
      }
    } on Object {
      // Best effort — the player is already disposed, which is what matters.
    }
  }

  /// Whether [path] is an Android Storage Access Framework document URI rather
  /// than a filesystem path. Library files are always these; ad-hoc picked files
  /// are real paths.
  static bool _isContentUri(String path) => path.startsWith('content://');

  static String _titleFromPath(String path) {
    final name = path.split(RegExp(r'[/\\]')).last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}

final playerControllerProvider =
    NotifierProvider.autoDispose<PlayerController, PlayerModel>(
  PlayerController.new,
);
