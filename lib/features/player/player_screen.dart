import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../core/theme/app_colors.dart';
import 'player_controller.dart';
import 'player_model.dart';
import 'resume_behavior.dart';
import 'widgets/gesture_hint_overlay.dart';
import 'widgets/player_controls_overlay.dart';
import 'widgets/player_error_view.dart';
import 'widgets/player_gesture_layer.dart';
import 'widgets/resume_prompt.dart';

/// Full-screen video playback surface with custom controls, touch gestures, and
/// desktop keyboard shortcuts. This widget only triggers `open()` and renders
/// the notifier's [PlayerModel]; all logic lives in the notifier.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({
    super.key,
    required this.path,
    this.mediaId,
    this.title,
    this.behavior = ResumeBehavior.ask,
  });

  /// Where to read the video from: a filesystem path for ad-hoc picked files, or
  /// a SAF `content://` URI for library files. On Android a picked file's path
  /// may be a throwaway cache copy, so it is not used as the resume identity.
  final String path;

  /// Stable identity for resume/progress (content URI or name+size). When null,
  /// [path] is used as the key.
  final String? mediaId;

  /// Title for the player's top bar. Falls back to the filename in [path].
  final String? title;

  /// Whether a saved position is offered, used silently, or ignored.
  final ResumeBehavior behavior;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Defer until after the first frame: calling open() during the build phase
    // would mutate the provider while the widget tree is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(playerControllerProvider.notifier).open(
            widget.path,
            mediaId: widget.mediaId,
            title: widget.title,
            behavior: widget.behavior,
          );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause playback when the app leaves the foreground so audio doesn't keep
    // running in the background.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      ref.read(playerControllerProvider.notifier).pauseForBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase =
        ref.watch(playerControllerProvider.select((s) => s.phase));

    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (phase) {
        PlayerPhase.loading => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        PlayerPhase.error => PlayerErrorView(
            message: ref.read(
                  playerControllerProvider.select((s) => s.errorMessage),
                ) ??
                'This file could not be played.',
            onBack: () => Navigator.of(context).maybePop(),
          ),
        PlayerPhase.ready => const _ReadyView(),
      },
    );
  }
}

/// Playback surface once the file is open: video, gesture layer, controls, and
/// gesture indicators, all under a keyboard-shortcut scope for desktop.
class _ReadyView extends ConsumerWidget {
  const _ReadyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final videoController =
        ref.watch(playerControllerProvider.select((s) => s.controller));
    final buffering =
        ref.watch(playerControllerProvider.select((s) => s.buffering));

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.space):
            controller.togglePlayPause,
        const SingleActivator(LogicalKeyboardKey.arrowLeft):
            controller.skipBackward,
        const SingleActivator(LogicalKeyboardKey.arrowRight):
            controller.skipForward,
        const SingleActivator(LogicalKeyboardKey.arrowUp): controller.volumeUp,
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            controller.volumeDown,
        const SingleActivator(LogicalKeyboardKey.keyF):
            controller.toggleFullscreen,
        const SingleActivator(LogicalKeyboardKey.keyM): controller.toggleMute,
        const SingleActivator(LogicalKeyboardKey.escape):
            controller.exitFullscreen,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (videoController != null)
              Video(
                controller: videoController,
                controls: NoVideoControls,
                fit: BoxFit.contain,
              ),
            // Gesture surface sits above the video, below the controls.
            const PlayerGestureLayer(),
            if (buffering)
              const IgnorePointer(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
            const Positioned.fill(child: PlayerControlsOverlay()),
            const Positioned.fill(child: ResumePrompt()),
            const Positioned.fill(child: GestureHintOverlay()),
          ],
        ),
      ),
    );
  }
}
