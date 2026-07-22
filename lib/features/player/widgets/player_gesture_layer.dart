import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player_controller.dart';

/// Transparent full-screen gesture surface that sits between the video and the
/// controls overlay. It translates touch gestures into notifier calls:
///
/// - single tap → toggle controls
/// - double tap left/right → seek ∓10s
/// - vertical drag left → brightness, right → system volume
/// - horizontal drag → scrub
///
/// All effects live in the notifier; this widget only measures and dispatches.
class PlayerGestureLayer extends ConsumerStatefulWidget {
  const PlayerGestureLayer({super.key});

  @override
  ConsumerState<PlayerGestureLayer> createState() => _PlayerGestureLayerState();
}

class _PlayerGestureLayerState extends ConsumerState<PlayerGestureLayer> {
  bool _doubleTapOnRight = false;
  bool _verticalOnLeft = false;
  double _dragAnchor = 0;

  PlayerController get _controller =>
      ref.read(playerControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Single tap toggles the controls.
          onTap: _controller.toggleControls,
          // Double tap seeks; the half decides direction.
          onDoubleTapDown: (d) =>
              _doubleTapOnRight = d.localPosition.dx > width / 2,
          onDoubleTap: () =>
              _controller.doubleTapSeek(forward: _doubleTapOnRight),
          // Vertical drag: brightness (left half) or volume (right half).
          onVerticalDragStart: (d) {
            _verticalOnLeft = d.localPosition.dx < width / 2;
            _dragAnchor = d.localPosition.dy;
            if (_verticalOnLeft) {
              _controller.startBrightnessDrag();
            } else {
              _controller.startVolumeDrag();
            }
          },
          onVerticalDragUpdate: (d) {
            // Upward drag increases the level.
            final fraction = (_dragAnchor - d.localPosition.dy) / height;
            if (_verticalOnLeft) {
              _controller.updateBrightnessDrag(fraction);
            } else {
              _controller.updateVolumeDrag(fraction);
            }
          },
          onVerticalDragEnd: (_) => _controller.endVerticalDrag(),
          // Horizontal drag scrubs; full width spans the whole duration.
          onHorizontalDragStart: (d) {
            _dragAnchor = d.localPosition.dx;
            _controller.startScrub();
          },
          onHorizontalDragUpdate: (d) {
            final fraction = (d.localPosition.dx - _dragAnchor) / width;
            _controller.updateScrub(fraction);
          },
          onHorizontalDragEnd: (_) => _controller.endScrub(),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
