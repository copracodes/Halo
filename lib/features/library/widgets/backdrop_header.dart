import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Cinematic header for a detail screen: a backdrop that fades into the page,
/// with the poster, title, and a short facts line over it.
///
/// Every image comes from the local cache, so this looks identical offline.
/// With nothing cached the header still works — it collapses to a gradient
/// panel, which is the same treatment the placeholder cards use.
class BackdropHeader extends StatelessWidget {
  const BackdropHeader({
    super.key,
    required this.title,
    this.imagePath,
    this.posterPath,
    this.facts = const [],
    this.heroTag,
    this.actions,
  });

  /// Local backdrop file.
  final String? imagePath;

  /// Local poster file, shown as a thumbnail over the backdrop.
  final String? posterPath;

  final String title;

  /// Short facts shown under the title: year, runtime, rating, genres.
  final List<String> facts;

  /// Tag of the card that opened this screen, so its poster flies in.
  final Object? heroTag;

  /// Optional trailing action, shown top-right opposite the back button — the
  /// detail screens hang their overflow menu here.
  final Widget? actions;

  static const double _backdropHeight = 240;

  @override
  Widget build(BuildContext context) {
    final imagePath = this.imagePath;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: _backdropHeight + 40,
      child: Stack(
        children: [
          // Backdrop, bleeding under the status bar.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: _backdropHeight,
            child: imagePath == null
                ? const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.surface, AppColors.background],
                      ),
                    ),
                  )
                : Image(
                    image: ResizeImage.resizeIfNeeded(
                      (width * devicePixelRatio).round(),
                      null,
                      FileImage(File(imagePath)),
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
          ),
          // Scrim: keeps the title legible over any image, and dissolves the
          // backdrop's bottom edge into the page rather than cutting it off.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: _backdropHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.45, 1],
                  colors: [
                    Color(0x99000000),
                    Color(0x33000000),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 4,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
          if (actions != null)
            Positioned(
              right: 4,
              top: 4,
              child: SafeArea(child: actions!),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Poster(path: posterPath, heroTag: heroTag, title: title),
                const SizedBox(width: 14),
                Expanded(child: _TitleBlock(title: title, facts: facts)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({
    required this.path,
    required this.heroTag,
    required this.title,
  });

  final String? path;
  final Object? heroTag;
  final String title;

  static const double _width = 92;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    final tile = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: _width,
        height: _width * 3 / 2,
        child: path == null
            ? const ColoredBox(color: AppColors.surface)
            : Image(
                image: ResizeImage.resizeIfNeeded(
                  (_width * devicePixelRatio).round(),
                  null,
                  FileImage(File(path)),
                ),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: AppColors.surface),
              ),
      ),
    );

    final tag = heroTag;
    return tag == null ? tile : Hero(tag: tag, child: tile);
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.title, required this.facts});

  final String title;
  final List<String> facts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        if (facts.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            facts.join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
