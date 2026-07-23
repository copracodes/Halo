import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player_controller.dart';

/// A floating, glassy control for the manual subtitle timing offset. Appears
/// (with the rest of the controls) only while an external subtitle is active;
/// adjusts live and is remembered per show/film. Minus = earlier, plus = later.
class SubtitleDelayPill extends ConsumerWidget {
  const SubtitleDelayPill({super.key});

  static const _step = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(
        playerControllerProvider.select((s) => s.activeExternalUri != null));
    if (!active) return const SizedBox.shrink();

    final controller = ref.read(playerControllerProvider.notifier);
    final delay =
        ref.watch(playerControllerProvider.select((s) => s.subtitleDelay));
    final offset = delay != Duration.zero;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.subtitles_outlined,
                    color: Colors.white70, size: 16),
              ),
              _RoundButton(
                icon: Icons.remove,
                tooltip: 'Subtitles earlier',
                onTap: () => controller.adjustSubtitleDelay(-_step),
              ),
              SizedBox(
                width: 58,
                child: Text(
                  _format(delay),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: offset ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              _RoundButton(
                icon: Icons.add,
                tooltip: 'Subtitles later',
                onTap: () => controller.adjustSubtitleDelay(_step),
              ),
              // Reset takes the place the offset earns; gone at zero.
              AnimatedSize(
                duration: const Duration(milliseconds: 160),
                child: offset
                    ? _RoundButton(
                        icon: Icons.restart_alt,
                        tooltip: 'Reset',
                        onTap: () => controller.setSubtitleDelay(Duration.zero),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(Duration delay) {
    final seconds = delay.inMilliseconds / 1000.0;
    if (seconds == 0) return '0.0s';
    final sign = seconds > 0 ? '+' : '−';
    return '$sign${seconds.abs().toStringAsFixed(1)}s';
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
