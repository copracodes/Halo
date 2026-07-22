import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../player_controller.dart';

/// Small "Resume from HH:MM:SS / Start over" card shown when a saved position is
/// available. Reads the offered position from the notifier and dispatches the
/// user's choice back to it.
class ResumePrompt extends ConsumerWidget {
  const ResumePrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final resumeFrom =
        ref.watch(playerControllerProvider.select((s) => s.resumeFrom));

    if (resumeFrom == null) return const SizedBox.shrink();

    return Align(
      alignment: const Alignment(-0.9, 0.6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You were here last time',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: controller.resumeFromSaved,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text('Resume ${FormatUtils.formatDuration(resumeFrom)}'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: controller.startOver,
                  child: const Text(
                    'Start over',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
