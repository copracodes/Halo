import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../player_controller.dart';
import 'seek_bar.dart';
import 'track_label.dart';

/// Bottom control bar: scrubber with time labels, then a row of speed, audio,
/// subtitle and fullscreen controls, over a gradient for readability.
class PlayerBottomBar extends ConsumerWidget {
  const PlayerBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final position =
        ref.watch(playerControllerProvider.select((s) => s.position));
    final duration =
        ref.watch(playerControllerProvider.select((s) => s.duration));
    final buffer =
        ref.watch(playerControllerProvider.select((s) => s.buffer));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                FormatUtils.formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SeekBar(
                  position: position,
                  duration: duration,
                  buffer: buffer,
                  onSeek: controller.seekTo,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                FormatUtils.formatDuration(duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              _SpeedButton(),
              _AudioButton(),
              _SubtitleButton(),
              Spacer(),
              _FullscreenButton(),
            ],
          ),
        ],
      ),
    );
  }
}

const _speeds = <double>[0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

class _SpeedButton extends ConsumerWidget {
  const _SpeedButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final rate = ref.watch(playerControllerProvider.select((s) => s.rate));

    return PopupMenuButton<double>(
      tooltip: 'Playback speed',
      color: AppColors.surface,
      initialValue: rate,
      onSelected: controller.setRate,
      itemBuilder: (context) => [
        for (final speed in _speeds)
          _checkedItem(
            value: speed,
            label: '${_trim(speed)}x',
            selected: speed == rate,
          ),
      ],
      child: _PillLabel(text: '${_trim(rate)}x'),
    );
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

class _AudioButton extends ConsumerWidget {
  const _AudioButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final tracks =
        ref.watch(playerControllerProvider.select((s) => s.audioTracks));
    final activeId =
        ref.watch(playerControllerProvider.select((s) => s.activeAudioId));

    return PopupMenuButton<String>(
      tooltip: 'Audio track',
      color: AppColors.surface,
      enabled: tracks.isNotEmpty,
      onSelected: controller.selectAudioTrack,
      itemBuilder: (context) => [
        for (var i = 0; i < tracks.length; i++)
          _checkedItem(
            value: tracks[i].id,
            label: audioTrackLabel(tracks[i], i),
            selected: tracks[i].id == activeId,
          ),
      ],
      child: _IconLabel(
        icon: Icons.audiotrack,
        label: 'Audio',
        enabled: tracks.isNotEmpty,
      ),
    );
  }
}

/// Sentinel value for the "Load subtitle file…" item, distinct from any track
/// id or subtitle URI.
const _loadSubtitleValue = '__halo_load_subtitle__';

class _SubtitleButton extends ConsumerWidget {
  const _SubtitleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final tracks =
        ref.watch(playerControllerProvider.select((s) => s.subtitleTracks));
    final external =
        ref.watch(playerControllerProvider.select((s) => s.externalSubtitles));
    final activeId =
        ref.watch(playerControllerProvider.select((s) => s.activeSubtitleId));
    final activeExternal =
        ref.watch(playerControllerProvider.select((s) => s.activeExternalUri));
    final off = activeExternal == null &&
        (activeId == null || activeId == 'no' || activeId == 'auto');

    void onSelected(String value) {
      if (value == _loadSubtitleValue) {
        controller.loadSubtitleFile();
      } else if (external.any((s) => s.uri == value)) {
        controller.selectExternalSubtitle(value);
      } else {
        controller.selectSubtitleTrack(value);
      }
    }

    return PopupMenuButton<String>(
      tooltip: 'Subtitles',
      color: AppColors.surface,
      onSelected: onSelected,
      itemBuilder: (context) => [
        _checkedItem(value: 'no', label: 'Off', selected: off),
        for (var i = 0; i < tracks.length; i++)
          _checkedItem(
            value: tracks[i].id,
            label: subtitleTrackLabel(tracks[i], i),
            selected: activeExternal == null && tracks[i].id == activeId,
          ),
        for (var i = 0; i < external.length; i++)
          _checkedItem(
            value: external[i].uri,
            label: externalSubtitleLabel(external[i], i),
            selected: external[i].uri == activeExternal,
          ),
        const PopupMenuItem<String>(
          value: _loadSubtitleValue,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Icon(Icons.upload_file, size: 16, color: Colors.white70),
              ),
              Text('Load subtitle file…',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
      child: _IconLabel(
        icon: off ? Icons.closed_caption_off : Icons.closed_caption,
        label: 'Subtitles',
        enabled: true,
      ),
    );
  }
}

class _FullscreenButton extends ConsumerWidget {
  const _FullscreenButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playerControllerProvider.notifier);
    final isFullscreen =
        ref.watch(playerControllerProvider.select((s) => s.isFullscreen));

    return IconButton(
      tooltip: 'Fullscreen',
      icon: Icon(
        isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: Colors.white,
      ),
      onPressed: controller.toggleFullscreen,
    );
  }
}

PopupMenuItem<T> _checkedItem<T>({
  required T value,
  required String label,
  required bool selected,
}) {
  return PopupMenuItem<T>(
    value: value,
    child: Row(
      children: [
        SizedBox(
          width: 24,
          child: selected
              ? const Icon(Icons.check, size: 16, color: AppColors.accent)
              : null,
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.white : Colors.white38;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
