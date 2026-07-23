import 'dart:async';
import 'dart:convert' show latin1, utf8;
import 'dart:io' show Directory, File, Platform;
import 'dart:typed_data' show BytesBuilder;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
// Internal media_kit helper: the only mechanism that can open a SAF content://
// document URI on Android (saf_util is denied permission for these), used here
// to read sidecar subtitle bytes the same way media_kit reads the video.
// ignore: implementation_imports
import 'package:media_kit/src/player/native/utils/android_content_uri_provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/repositories/playback_prefs_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/subtitle_repository.dart';
import '../library/subtitle_matching.dart';
import 'external_subtitle.dart';
import 'playback_prefs.dart';
import 'player_engine.dart';
import 'resume_behavior.dart';
import 'player_model.dart';
import 'resume_policy.dart';
import 'subtitle_parser.dart';
import 'subtitle_selection.dart';
import 'track_matching.dart';

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

  /// Sticky playback preferences: where this file's preferences live (null for
  /// ad-hoc files, which read global defaults but persist nothing), the store,
  /// the preferences resolved for this open, and the global speed-memory toggle.
  PlaybackScope? _scope;
  PlaybackPrefsRepository? _prefs;
  ResolvedPlaybackPrefs _resolvedPrefs = const ResolvedPlaybackPrefs();
  bool _rememberSpeed = true;

  /// Completes when the file's real tracks have been parsed, so preferred
  /// tracks are applied before the video is shown. Reset per open.
  Completer<void> _tracksReady = Completer<void>();

  /// The most recent preference write, exposed to tests so they can await the
  /// fire-and-forget persistence deterministically.
  Future<void>? _lastPrefWrite;

  /// External subtitle plumbing: the store, the id of the file being played (so
  /// hand-loaded subtitles can be associated with it), platform access for
  /// resolving `content://` sidecars to file descriptors, and the descriptors
  /// opened this session so they can be closed on teardown.
  SubtitleRepository? _subtitles;
  LibraryRepository? _library;
  int? _mediaFileId;

  /// Parsed cues for the active external subtitle. Halo renders these itself
  /// (media_kit can't load external subtitles on Android), matching the current
  /// one to the playback position.
  List<SubtitleCue> _externalCues = const [];

  /// The last position media_kit reported and when (wall clock) it arrived, so
  /// the current position can be *interpolated* between the position stream's
  /// coarse updates — otherwise subtitles lag the audio by up to one update.
  Duration _positionSample = Duration.zero;
  DateTime _positionSampledAt = DateTime.now();

  /// Drives subtitle-cue updates faster than the position stream ticks.
  Timer? _subtitleTimer;

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

  /// Configures the preference plumbing without running the full [open] flow, so
  /// a test can drive track/speed persistence against a fake engine.
  @visibleForTesting
  void debugConfigurePrefs({
    required PlaybackPrefsRepository prefs,
    PlaybackScope? scope,
    bool rememberSpeed = true,
  }) {
    _prefs = prefs;
    _scope = scope;
    _rememberSpeed = rememberSpeed;
  }

  /// The most recent preference write, so a test can await the fire-and-forget
  /// persistence before asserting on the database.
  @visibleForTesting
  Future<void>? get debugLastPrefWrite => _lastPrefWrite;

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
    PlaybackScope? scope,
  }) async {
    if (_engine != null) return;
    _progressKey = mediaId ?? path;
    _behavior = behavior;
    _progress = ref.read(progressRepositoryProvider);
    _scope = scope;
    _prefs = ref.read(playbackPrefsRepositoryProvider);
    _subtitles = ref.read(subtitleRepositoryProvider);
    _library = ref.read(libraryRepositoryProvider);

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

    // Resolve sticky preferences before opening: show/movie over global over
    // file defaults. Loaded here so they can be applied while the file is still
    // paused and hidden (see _applyStartupPrefs).
    final globalPrefs = await _prefs!.global();
    final scopePrefs =
        scope == null ? null : await _prefs!.forScope(scope.type, scope.key);
    _resolvedPrefs = resolvePlaybackPrefs(scope: scopePrefs, global: globalPrefs);
    _rememberSpeed = rememberSpeedPerShow(globalPrefs);

    // Load this file's external subtitles (sidecars + hand-loaded), so they can
    // be offered in the selector and considered when auto-selecting on open.
    _mediaFileId = await _library!.findOrCreateMediaId(_progressKey);
    final external = await _subtitles!.forMedia(_mediaFileId!);
    state = state.copyWith(
      externalSubtitles: [
        for (final row in external)
          ExternalSubtitle(
            uri: row.uri,
            lang: row.languageCode,
            source: row.source,
            selected: row.selected,
          ),
      ],
      subtitleDelay: Duration(milliseconds: _resolvedPrefs.subtitleDelayMs),
    );

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

    _tracksReady = Completer<void>();
    final engine = engineFactory();
    _engine = engine;
    _activeEngine = engine;

    _listen(engine.stream);

    // Open paused: preferred tracks are applied before the first frame is shown
    // (below), so the viewer never sees the wrong subtitle flash on screen.
    // Only open() itself represents a "can't play this file" failure; state
    // mutations stay outside the try so framework errors surface as real bugs.
    try {
      await engine.open(
        path,
        startAt: _openedAtResume ? _savedResume : null,
        play: false,
      );
    } on Object catch (error) {
      state = state.copyWith(
        phase: PlayerPhase.error,
        errorMessage: 'This video could not be played. It may use an '
            'unsupported format or codec.\n$error',
      );
      return;
    }

    if (state.phase == PlayerPhase.error) return;

    // Apply remembered audio/subtitle/speed while still paused and hidden.
    await _applyStartupPrefs();
    if (_engine == null) return; // torn down mid-open

    state = state.copyWith(
      phase: PlayerPhase.ready,
      controller: engine.videoController,
    );
    _saveTimer = Timer.periodic(_saveInterval, (_) => _persistPosition());

    // Start playing — unless a resume prompt is already holding for the
    // viewer's choice (an "ask" open that landed on a saved position).
    if (state.resumeFrom == null) _engine?.play();
  }

  /// Selects the remembered audio, subtitle, and speed for this file, once its
  /// real tracks are known. Bounded wait so a file whose tracks never parse
  /// still starts playing. Anything not matched is left at the file's default.
  Future<void> _applyStartupPrefs() async {
    await _tracksReady.future
        .timeout(const Duration(seconds: 4), onTimeout: () {});
    final engine = _engine;
    if (engine == null) return;
    final prefs = _resolvedPrefs;

    final audio = matchAudioTrack(
      state.audioTracks,
      TrackChoice(language: prefs.audioLang, title: prefs.audioTitle),
    );
    if (audio != null) await engine.setAudioTrack(audio);

    // Subtitles. Unless the viewer explicitly turned them off, an external
    // track they previously chose for *this* video wins outright — that is the
    // exact "reopen and it's already on" behaviour. Otherwise fall back to the
    // scope-level resolution (external language match, single external, embedded
    // match, or the file's default) so a new episode still inherits a language.
    final remembered = state.externalSubtitles.where((s) => s.selected);
    if (prefs.subtitlesEnabled != false && remembered.isNotEmpty) {
      await _loadExternalSubtitle(remembered.first);
    } else {
      final decision = chooseStartupSubtitle(
        enabled: prefs.subtitlesEnabled,
        lang: prefs.subtitleLang,
        external: state.externalSubtitles,
        embedded: state.subtitleTracks,
      );
      switch (decision.action) {
        case SubtitleAction.off:
          await engine.setSubtitleTrack(SubtitleTrack.no());
        case SubtitleAction.embedded:
          await engine.setSubtitleTrack(decision.embedded!);
        case SubtitleAction.external:
          await _loadExternalSubtitle(decision.external!);
        case SubtitleAction.leaveDefault:
          break;
      }
    }

    if (prefs.speed != 1.0) await engine.setRate(prefs.speed);
  }

  /// Loads an external subtitle into the player and records it as active.
  ///
  /// Reads an external subtitle's text, parses it, and renders it through Halo's
  /// own overlay — media_kit's `sub-add` can't open external subtitle files on
  /// Android (neither a path nor a descriptor). mpv's own subtitle is turned off
  /// so the two never fight.
  Future<void> _loadExternalSubtitle(ExternalSubtitle subtitle) async {
    await _renderExternalSubtitle(subtitle.uri, subtitle.uri);
  }

  /// Reads the text at [readUri], parses it into cues, and activates it under
  /// [activeUri] (which the selector highlights). [readUri] may differ from
  /// [activeUri] when a just-picked file is read from its concrete path but
  /// remembered by its content URI.
  Future<void> _renderExternalSubtitle(String readUri, String activeUri) async {
    final text = await _readSubtitleText(readUri);
    if (text == null || text.isEmpty) return;
    _externalCues = parseSubtitles(text);
    // Keep mpv's own subtitle off; Halo draws the external one.
    await _engine?.setSubtitleTrack(SubtitleTrack.no());
    state = state.copyWith(
      activeExternalUri: activeUri,
      subtitleCue: subtitleAt(_externalCues, _interpolatedPosition()),
    );
    _startSubtitleTimer();
  }

  /// Clears any active external subtitle (when embedded/off is chosen), and
  /// forgets the remembered per-video choice so it won't re-activate on reopen.
  void _clearExternalSubtitle() {
    _stopSubtitleTimer();
    _externalCues = const [];
    state = state.copyWith(activeExternalUri: null, subtitleCue: null);
    final id = _mediaFileId;
    if (id != null) _lastPrefWrite = _subtitles?.clearSelected(id);
  }

  /// Runs while an external subtitle is active, refreshing the shown cue far
  /// more often than the position stream ticks so cues land on time.
  void _startSubtitleTimer() {
    _subtitleTimer ??= Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _updateSubtitleCue(),
    );
  }

  void _stopSubtitleTimer() {
    _subtitleTimer?.cancel();
    _subtitleTimer = null;
  }

  /// Sets the shown cue for the *interpolated* current position, offset by the
  /// manual subtitle delay (positive = show later, so look further back).
  void _updateSubtitleCue() {
    if (_externalCues.isEmpty) return;
    final at = _interpolatedPosition() - state.subtitleDelay;
    final cue = subtitleAt(_externalCues, at);
    if (cue != state.subtitleCue) state = state.copyWith(subtitleCue: cue);
  }

  /// The current position estimated from the last sample plus the real time
  /// elapsed since (scaled by playback rate), so it advances smoothly between
  /// the position stream's updates. Frozen at the sample while paused.
  Duration _interpolatedPosition() {
    if (!state.playing) return _positionSample;
    final elapsed = DateTime.now().difference(_positionSampledAt);
    return _positionSample + elapsed * state.rate;
  }

  /// Nudges the manual subtitle timing offset by [delta].
  void adjustSubtitleDelay(Duration delta) =>
      setSubtitleDelay(state.subtitleDelay + delta);

  /// Sets the manual subtitle timing offset (clamped to ±60s), applies it live,
  /// and remembers it for this show/movie. Positive shows subtitles later.
  void setSubtitleDelay(Duration value) {
    const limit = Duration(seconds: 60);
    var next = value;
    if (next > limit) next = limit;
    if (next < -limit) next = -limit;
    state = state.copyWith(subtitleDelay: next);
    _updateSubtitleCue();
    _persist((scope, prefs) =>
        prefs.saveSubtitleDelay(scope.type, scope.key, next.inMilliseconds));
    _kick();
  }

  /// Reads a subtitle file's text. A `content://` sidecar is read through its
  /// file descriptor via `/proc/self/fd` (Android); a real path is read
  /// directly. Non-UTF-8 files fall back to Latin-1 so a legacy `.srt` still
  /// loads rather than failing to decode.
  Future<String?> _readSubtitleText(String uri) async {
    if (!uri.startsWith('content://')) {
      try {
        return _decodeSubtitle(await File(uri).readAsBytes());
      } on Object {
        return null;
      }
    }

    try {
      // Open the descriptor through media_kit's own content provider — the exact
      // mechanism it uses to play the video from this same URI. saf_util's
      // getFileDescriptor is denied permission for these document URIs; this is
      // not. Then read the open descriptor via /proc/self/fd, which grants the
      // already-permissioned file without re-checking the underlying path.
      final fd = await AndroidContentUriProvider.openFileDescriptor(uri);
      if (fd <= 0) return null;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in File('/proc/self/fd/$fd').openRead()) {
        builder.add(chunk);
      }
      return _decodeSubtitle(builder.takeBytes());
    } on Object {
      return null;
    } finally {
      await AndroidContentUriProvider.closeFileDescriptor(uri);
    }
  }

  static String _decodeSubtitle(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes, allowInvalid: true);
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
        if (message.isEmpty) return;
        // A subtitle that won't load must never take playback down with it —
        // mpv reports it here as an "external file" failure. Swallow those: a
        // subtitle is an enhancement, not a reason to fail the whole video.
        final lower = message.toLowerCase();
        if (lower.contains('external file') || lower.contains('subtitle')) {
          return;
        }
        state = state.copyWith(
          phase: PlayerPhase.error,
          errorMessage: 'This video could not be played. It may use an '
              'unsupported format or codec.\n$message',
        );
      }),
    ]);
  }

  void _onPosition(Duration position) {
    _lastPosition = position;
    _positionSample = position;
    _positionSampledAt = DateTime.now();
    state = state.copyWith(position: position);
    _updateSubtitleCue();
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
    // Keep the screen awake only while actually playing. Fire-and-forget: its
    // platform future is ignored so a plugin hiccup can't surface as an
    // unhandled async error.
    WakelockPlus.toggle(enable: playing).ignore();
    _restartHideTimer();
  }

  void _onTracks(Tracks tracks) {
    bool real(String id) => id != 'auto' && id != 'no';
    final audio = tracks.audio.where((t) => real(t.id)).toList();
    final subtitle = tracks.subtitle.where((t) => real(t.id)).toList();
    state = state.copyWith(audioTracks: audio, subtitleTracks: subtitle);
    // Real tracks have arrived: release the startup-prefs wait so the remembered
    // audio/subtitle can be applied before playback becomes visible.
    if (!_tracksReady.isCompleted && (audio.isNotEmpty || subtitle.isNotEmpty)) {
      _tracksReady.complete();
    }
  }

  void _onTrackSelection(Track track) {
    // An external subtitle loaded via [SubtitleTrack.data] has the whole file's
    // text as its id; don't stash that in state. A short marker is enough — the
    // active external subtitle is tracked separately by its URI.
    final subtitleId = track.subtitle.id;
    state = state.copyWith(
      activeAudioId: track.audio.id,
      activeSubtitleId: subtitleId.length > 200 ? 'external' : subtitleId,
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
    // Remember the speed for this show/movie, unless the viewer turned that off.
    if (_rememberSpeed) {
      _persist((scope, prefs) => prefs.saveSpeed(scope.type, scope.key, rate));
    }
    _kick();
  }

  void selectAudioTrack(String id) {
    for (final track in state.audioTracks) {
      if (track.id == id) {
        _engine?.setAudioTrack(track);
        _persist((scope, prefs) => prefs.saveAudioPref(
              scope.type,
              scope.key,
              lang: track.language,
              title: track.title,
            ));
        break;
      }
    }
    _kick();
  }

  /// Selects an embedded subtitle track by id, or turns subtitles off for id
  /// `'no'`. Either way the active subtitle is now an embedded one, so any
  /// external selection is cleared.
  void selectSubtitleTrack(String id) {
    if (id == 'no') {
      _engine?.setSubtitleTrack(SubtitleTrack.no());
      _clearExternalSubtitle();
      // Keep the remembered language so switching back on returns to it.
      _persist((scope, prefs) =>
          prefs.saveSubtitlesEnabled(scope.type, scope.key, false));
    } else {
      for (final track in state.subtitleTracks) {
        if (track.id == id) {
          _engine?.setSubtitleTrack(track);
          _clearExternalSubtitle();
          _persist((scope, prefs) => prefs.saveSubtitlePref(
                scope.type,
                scope.key,
                lang: track.language,
                enabled: true,
              ));
          break;
        }
      }
    }
    _kick();
  }

  /// Selects one of the external subtitles by its URI. Remembers the choice at
  /// the show/movie scope as an enabled subtitle in that language, so the next
  /// episode auto-selects its own external sub of the same language (4.1b).
  void selectExternalSubtitle(String uri) {
    for (final subtitle in state.externalSubtitles) {
      if (subtitle.uri == uri) {
        _loadExternalSubtitle(subtitle);
        _rememberExternalSelection(uri);
        _persist((scope, prefs) => prefs.saveSubtitlePref(
              scope.type,
              scope.key,
              lang: subtitle.lang,
              enabled: true,
            ));
        break;
      }
    }
    _kick();
  }

  /// Records [uri] as this video's chosen external subtitle (so it re-activates
  /// on reopen), replacing any prior choice.
  void _rememberExternalSelection(String uri) {
    final id = _mediaFileId;
    if (id != null) _lastPrefWrite = _subtitles?.setSelected(id, uri);
  }

  /// Opens a file picker for subtitle files, loads the chosen one immediately,
  /// and remembers it for this video so it's offered again next time.
  Future<void> loadSubtitleFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: subtitleExtensions.toList(),
    );
    final file = result?.files.singleOrNull;
    final pickedPath = file?.path;
    if (file == null || pickedPath == null) return;

    // The picker's file lives at a throwaway path with a non-persistable URI
    // grant, so reopening the video later can't read it. Copy its text into the
    // app's own storage and remember *that* — a path that always resolves.
    final text = await _readSubtitleText(pickedPath);
    if (text == null || text.isEmpty) return;
    final lang = languageFromSubtitleName(file.name);
    final uri = await _saveSubtitleCopy(text, file.name) ?? pickedPath;

    final mediaFileId = _mediaFileId;
    if (mediaFileId != null) {
      _lastPrefWrite =
          _subtitles?.addManual(mediaFileId, uri: uri, lang: lang);
    }

    // Offer it in the selector and activate it now.
    state = state.copyWith(
      externalSubtitles: [
        ...state.externalSubtitles,
        ExternalSubtitle(uri: uri, lang: lang, source: SubtitleSource.manual),
      ],
    );
    await _renderExternalSubtitle(uri, uri);
    _rememberExternalSelection(uri);
    _persist((scope, prefs) =>
        prefs.saveSubtitlePref(scope.type, scope.key, lang: lang, enabled: true));
    _kick();
  }

  /// Copies a hand-loaded subtitle's [text] into the app's own storage, keyed by
  /// the video and the file's name, so it survives the picker's transient grant
  /// and is restored automatically next time. Returns the saved path, or null on
  /// failure (the caller falls back to the picked path for this session).
  Future<String?> _saveSubtitleCopy(String text, String name) async {
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory('${base.path}/halo_manual_subs');
      if (!dir.existsSync()) await dir.create(recursive: true);
      final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      // Deterministic per video + name, so re-loading the same file overwrites
      // rather than piling up copies.
      final file = File('${dir.path}/${_mediaFileId ?? 0}_$safeName');
      await file.writeAsString(text);
      return file.path;
    } on Object {
      return null;
    }
  }

  /// Runs a preference write for the current scope, if there is one. Ad-hoc
  /// files have no scope and persist nothing. The future is kept so tests can
  /// await the otherwise fire-and-forget write.
  void _persist(
    Future<void> Function(PlaybackScope scope, PlaybackPrefsRepository prefs)
        write,
  ) {
    final scope = _scope;
    final prefs = _prefs;
    if (scope == null || prefs == null) return;
    _lastPrefWrite = write(scope, prefs);
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
    _subtitleTimer?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    // 3. Persist a final resume position from cached values (not `state`, which
    //    is no longer readable), and restore system state. All guarded so a
    //    plugin/platform failure can never resurrect the player.
    try {
      _persistPosition();
      // Ignored: these are fire-and-forget on the way out, and their platform
      // futures reject asynchronously — past this synchronous try — so they
      // must not be left to surface as unhandled errors.
      WakelockPlus.disable().ignore();
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
