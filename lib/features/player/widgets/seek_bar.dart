import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Scrubbable progress bar showing played, buffered, and remaining ranges.
///
/// The only local state is the finger position while a drag is in progress; the
/// committed seek is pushed up through [onSeek]. Everything else comes from the
/// player model.
class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.buffer,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final Duration buffer;
  final ValueChanged<Duration> onSeek;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  /// Fraction (0–1) the user is dragging to, or null when not dragging.
  double? _dragFraction;

  double _fraction(Duration d) {
    final total = widget.duration.inMilliseconds;
    if (total <= 0) return 0;
    return (d.inMilliseconds / total).clamp(0.0, 1.0);
  }

  Duration _durationAt(double fraction) => Duration(
        milliseconds: (widget.duration.inMilliseconds * fraction).round(),
      );

  void _seekTo(double fraction) => widget.onSeek(_durationAt(fraction));

  @override
  Widget build(BuildContext context) {
    final playedFraction = _dragFraction ?? _fraction(widget.position);
    final bufferedFraction = _fraction(widget.buffer);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double fractionFor(double dx) => (dx / width).clamp(0.0, 1.0);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _seekTo(fractionFor(d.localPosition.dx)),
          onHorizontalDragStart: (d) =>
              setState(() => _dragFraction = fractionFor(d.localPosition.dx)),
          onHorizontalDragUpdate: (d) =>
              setState(() => _dragFraction = fractionFor(d.localPosition.dx)),
          onHorizontalDragEnd: (_) {
            final fraction = _dragFraction;
            if (fraction != null) _seekTo(fraction);
            setState(() => _dragFraction = null);
          },
          child: SizedBox(
            height: 24,
            child: Center(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Base (remaining) track.
                  _bar(width, 1, Colors.white24),
                  // Buffered range.
                  _bar(width, bufferedFraction, Colors.white38),
                  // Played range.
                  _bar(width, playedFraction, AppColors.accent),
                  // Thumb.
                  Positioned(
                    left: (width * playedFraction - 7).clamp(0.0, width - 14),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bar(double width, double fraction, Color color) {
    return Container(
      width: width * fraction,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
