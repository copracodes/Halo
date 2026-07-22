import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player_controller.dart';

/// Center transport controls: skip back 10s, play/pause, skip forward 10s.
/// While buffering, the middle button yields to the loading spinner drawn by
/// the screen, so it renders empty space to avoid overlap.
class PlayerCenterControls extends ConsumerWidget {
  const PlayerCenterControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final playing =
        ref.watch(playerControllerProvider.select((s) => s.playing));
    final buffering =
        ref.watch(playerControllerProvider.select((s) => s.buffering));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundButton(
          icon: Icons.replay_10,
          size: 36,
          onPressed: controller.skipBackward,
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 72,
          height: 72,
          child: buffering
              ? const SizedBox.shrink()
              : _RoundButton(
                  icon: playing ? Icons.pause : Icons.play_arrow,
                  size: 56,
                  onPressed: controller.togglePlayPause,
                ),
        ),
        const SizedBox(width: 40),
        _RoundButton(
          icon: Icons.forward_10,
          size: 36,
          onPressed: controller.skipForward,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.size,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: size),
      onPressed: onPressed,
      splashRadius: size * 0.7,
    );
  }
}
