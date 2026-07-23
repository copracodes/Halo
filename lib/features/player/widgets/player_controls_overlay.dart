import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player_controller.dart';
import 'player_bottom_bar.dart';
import 'player_center_controls.dart';
import 'player_top_bar.dart';
import 'subtitle_delay_pill.dart';

/// Fades the Netflix-style control layer in and out. The scrims run edge-to-edge
/// (they draw behind the status area and display cutout), while the control bars
/// are inset by the safe-area padding so they're never clipped by the cutout or
/// rounded corners.
class PlayerControlsOverlay extends ConsumerWidget {
  const PlayerControlsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(
      playerControllerProvider.select((s) => s.controlsVisible),
    );
    final safe = MediaQuery.of(context).padding;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Stack(
          children: [
            // Full-bleed scrims for legibility — subtle, no middle darkening.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: _Scrim(top: true, opacity: 0.45),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 160,
              child: _Scrim(top: false, opacity: 0.55),
            ),
            // Control bars, inset away from the cutout / rounded corners.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  top: safe.top,
                  left: safe.left,
                  right: safe.right,
                ),
                child: const PlayerTopBar(),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: PlayerCenterControls(),
            ),
            // Floating subtitle-timing control, tucked under the top bar on the
            // right. Hides itself unless an external subtitle is active.
            Positioned(
              top: safe.top + 56,
              right: safe.right + 12,
              child: const SubtitleDelayPill(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: safe.bottom,
                  left: safe.left,
                  right: safe.right,
                ),
                child: const PlayerBottomBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single edge scrim: an opaque-ish edge fading to transparent toward the
/// middle. Non-interactive so it never blocks the gesture layer beneath.
class _Scrim extends StatelessWidget {
  const _Scrim({required this.top, required this.opacity});

  /// Whether this scrim hugs the top edge (else the bottom edge).
  final bool top;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: top ? Alignment.topCenter : Alignment.bottomCenter,
            end: top ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
