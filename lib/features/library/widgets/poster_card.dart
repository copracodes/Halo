import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A tappable library card: an artwork tile with a title and short caption
/// beneath it.
///
/// With [imagePath] set the tile shows cached TMDB artwork, fading in as it
/// decodes. Without one — unmatched title, or metadata not synced yet — it
/// renders a dark gradient derived from the title, so a mixed grid still reads
/// as a designed set rather than a row of holes. The same fallback catches a
/// cache file that has been deleted, which is what keeps the grid intact
/// offline.
class PosterCard extends StatefulWidget {
  const PosterCard({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.imagePath,
    this.progress,
    this.badge,
    this.aspectRatio = _posterAspect,
    this.icon = Icons.movie_outlined,
    this.heroTag,
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

  /// Absolute path to a **cached local** artwork file, or null for the
  /// placeholder. Never a URL: artwork is downloaded during metadata sync so
  /// the library looks identical offline (see `MetadataImageCache`).
  final String? imagePath;

  /// Watch progress as 0–1, drawn as a bar across the bottom of the tile. Null
  /// hides the bar entirely.
  final double? progress;

  /// Small label in the tile's top-right corner (e.g. "3 seasons").
  final String? badge;

  final double aspectRatio;

  /// Watermark shown on the placeholder tile, hinting at the kind of content.
  final IconData icon;

  /// When set, the artwork flies into the detail screen's header. Must be
  /// unique on screen, and must match the tag on the destination.
  final Object? heroTag;

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  /// Wraps the tile in a [Hero] only when a tag was given — an untagged card
  /// must not join a flight, and two cards sharing a tag would throw.
  Widget _maybeHero(Widget child) {
    final tag = widget.heroTag;
    if (tag == null) return child;
    return Hero(tag: tag, child: child);
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
              child: _maybeHero(
                _PosterTile(
                  title: widget.title,
                  imagePath: widget.imagePath,
                  progress: widget.progress,
                  badge: widget.badge,
                  icon: widget.icon,
                ),
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
    required this.imagePath,
    required this.progress,
    required this.badge,
    required this.icon,
  });

  final String title;
  final String? imagePath;
  final double? progress;
  final String? badge;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final imagePath = this.imagePath;
    final badge = this.badge;
    final progress = this.progress;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The placeholder always sits underneath, so a slow or failed image
          // never flashes a bare hole — and a deleted cache file degrades to
          // the gradient rather than an error box.
          _PlaceholderArt(title: title, icon: icon),
          if (imagePath != null)
            _FadingArtwork(path: imagePath),
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

/// Cached artwork that fades in once decoded.
///
/// Decoding is capped to the tile's own pixel size: a wall of posters decoded
/// at full resolution is the classic way to make a grid stutter and blow up
/// memory, and nothing here is ever displayed larger than its tile.
class _FadingArtwork extends StatelessWidget {
  const _FadingArtwork({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth * devicePixelRatio).round()
            : null;

        return Image(
          image: ResizeImage.resizeIfNeeded(
            cacheWidth,
            null,
            FileImage(File(path)),
          ),
          fit: BoxFit.cover,
          // Missing file (cache cleared, storage reclaimed) shows the
          // placeholder underneath rather than an error glyph.
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              child: child,
            );
          },
        );
      },
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
