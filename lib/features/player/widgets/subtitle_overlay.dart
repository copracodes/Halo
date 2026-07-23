import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player_controller.dart';

/// Draws the active external subtitle line. External subtitles are rendered by
/// Halo itself (media_kit can't load them on Android), so the current cue's text
/// comes from the player state and is drawn here, above the video and below the
/// controls, styled like a normal subtitle track.
class SubtitleOverlay extends ConsumerWidget {
  const SubtitleOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cue =
        ref.watch(playerControllerProvider.select((s) => s.subtitleCue));
    if (cue == null || cue.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          // Sit above where the bottom controls appear.
          padding: const EdgeInsets.only(bottom: 72, left: 24, right: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                cue,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
