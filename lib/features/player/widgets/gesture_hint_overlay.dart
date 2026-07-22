import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../player_controller.dart';
import '../player_model.dart';

/// Renders the transient gesture indicator (seek ripple, brightness/volume
/// level, or scrub preview) from the notifier's [GestureHint]. Purely visual
/// and non-interactive.
class GestureHintOverlay extends ConsumerWidget {
  const GestureHintOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hint =
        ref.watch(playerControllerProvider.select((s) => s.hint));

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: hint.isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: _hintBody(hint),
      ),
    );
  }

  Widget _hintBody(GestureHint hint) {
    switch (hint.kind) {
      case GestureHintKind.none:
        return const SizedBox.expand();
      case GestureHintKind.seekBackward:
        return const _SeekRipple(
          alignment: Alignment.centerLeft,
          icon: Icons.replay_10,
          label: '-10s',
        );
      case GestureHintKind.seekForward:
        return const _SeekRipple(
          alignment: Alignment.centerRight,
          icon: Icons.forward_10,
          label: '+10s',
        );
      case GestureHintKind.brightness:
        return _LevelBadge(
          icon: Icons.brightness_6,
          level: hint.level,
        );
      case GestureHintKind.volume:
        return _LevelBadge(
          icon: hint.level <= 0 ? Icons.volume_off : Icons.volume_up,
          level: hint.level,
        );
      case GestureHintKind.scrub:
        return _ScrubPreview(target: hint.target, delta: hint.delta);
    }
  }
}

class _SeekRipple extends StatelessWidget {
  const _SeekRipple({
    required this.alignment,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: Colors.black38,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 34),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.icon, required this.level});

  final IconData icon;
  final double level;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 12),
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: level.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(level.clamp(0.0, 1.0) * 100).round()}%',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrubPreview extends StatelessWidget {
  const _ScrubPreview({required this.target, required this.delta});

  final Duration target;
  final Duration delta;

  @override
  Widget build(BuildContext context) {
    final sign = delta.isNegative ? '-' : '+';
    final deltaLabel =
        '$sign${FormatUtils.formatDuration(delta.abs())}';

    return Align(
      alignment: const Alignment(0, -0.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FormatUtils.formatDuration(target),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              deltaLabel,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
