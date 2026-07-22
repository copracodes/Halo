import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A tappable library card: an artwork tile with a title and short caption
/// beneath it.
///
/// Posters arrive in Phase 3 (TMDB). Until then [poster] is null and the tile
/// renders a dark gradient derived from the title, so the grids read as designed
/// artwork rather than empty boxes. Swapping real posters in is a one-argument
/// change at the call site — pass a [poster] and the image takes over the tile;
/// the caption, the progress bar, the press animation, and every grid that uses
/// this card stay exactly as they are. A failed image decode falls back to the
/// same gradient, which keeps the offline-first promise.
class PosterCard extends StatefulWidget {
  const PosterCard({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.poster,
    this.progress,
    this.badge,
    this.aspectRatio = _posterAspect,
    this.icon = Icons.movie_outlined,
  });

  /// Standard poster proportions, so the grid already has the shape real
  /// artwork will need.
  static const double _posterAspect = 2 / 3;

  /// Wider tile for continue-watching cards, which read as a still frame
  /// rather than a poster.
  static const double stillAspect = 16 / 10;

  static const double _titleGap = 8;
  static const double _subtitleGap = 2;
  static const double _titleFontSize = 13;
  static const double _subtitleFontSize = 11;
  static const double _lineHeight = 1.2;

  /// Height of the caption block under the artwork.
  ///
  /// Grids and carousels have to know a card's total height up front to lay it
  /// out, so this is the one place that measurement lives — otherwise the two
  /// call sites drift apart from the widget and cards start overflowing. Lines
  /// are rounded up and given a couple of pixels of slack, because a font's
  /// real line box can be a hair taller than `fontSize * height`.
  static double captionHeight(BuildContext context, {bool hasSubtitle = true}) {
    final textScaler = MediaQuery.textScalerOf(context);
    double line(double fontSize) =>
        (textScaler.scale(fontSize) * _lineHeight).ceilToDouble();

    return _titleGap +
        line(_titleFontSize) +
        (hasSubtitle ? _subtitleGap + line(_subtitleFontSize) : 0) +
        2;
  }

  final String title;
  final VoidCallback onTap;

  /// One-line caption under the title: a year, an episode code, a season count.
  final String? subtitle;

  /// Artwork for the tile. Null today; Phase 3 supplies one.
  final ImageProvider? poster;

  /// Watch progress as 0–1, drawn as a bar across the bottom of the tile. Null
  /// hides the bar entirely.
  final double? progress;

  /// Small label in the tile's top-right corner (e.g. "3 seasons").
  final String? badge;

  final double aspectRatio;

  /// Watermark shown on the placeholder tile, hinting at the kind of content.
  final IconData icon;

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.subtitle;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: _PosterTile(
                title: widget.title,
                poster: widget.poster,
                progress: widget.progress,
                badge: widget.badge,
                icon: widget.icon,
              ),
            ),
            const SizedBox(height: PosterCard._titleGap),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: PosterCard._titleFontSize,
                fontWeight: FontWeight.w600,
                height: PosterCard._lineHeight,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: PosterCard._subtitleGap),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: PosterCard._subtitleFontSize,
                  height: PosterCard._lineHeight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The artwork rectangle itself: poster if there is one, gradient placeholder
/// otherwise, with the badge and progress bar layered on top of either.
class _PosterTile extends StatelessWidget {
  const _PosterTile({
    required this.title,
    required this.poster,
    required this.progress,
    required this.badge,
    required this.icon,
  });

  final String title;
  final ImageProvider? poster;
  final double? progress;
  final String? badge;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final poster = this.poster;
    final badge = this.badge;
    final progress = this.progress;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The placeholder always sits underneath, so a slow or failed image
          // never flashes a bare hole.
          _PlaceholderArt(title: title, icon: icon),
          if (poster != null)
            Image(
              image: poster,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          if (badge != null)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (progress != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ProgressBar(value: progress),
            ),
        ],
      ),
    );
  }
}

/// The poster stand-in: a deterministic dark gradient plus the title's initial
/// as a watermark, so a wall of cards looks varied and deliberate instead of
/// uniformly grey.
class _PlaceholderArt extends StatelessWidget {
  const _PlaceholderArt({required this.title, required this.icon});

  final String title;
  final IconData icon;

  /// Small, explicit FNV-1a hash. Deterministic across runs and platforms, so a
  /// title always gets the same tile.
  static int _hash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final hue = (_hash(title) % 360).toDouble();
    final top = HSLColor.fromAHSL(1, hue, 0.30, 0.24).toColor();
    final bottom = HSLColor.fromAHSL(1, (hue + 24) % 360, 0.42, 0.08).toColor();
    final initial = title.trim().isEmpty ? '' : title.trim()[0].toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [top, bottom],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.10),
                    fontSize: 96,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Icon(
              icon,
              size: 16,
              color: Colors.white.withValues(alpha: 0.28),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin watch-progress bar pinned to the bottom edge of a tile.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      color: Colors.black.withValues(alpha: 0.55),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(color: AppColors.accent),
      ),
    );
  }
}
