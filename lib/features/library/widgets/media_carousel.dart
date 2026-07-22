import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'poster_card.dart';

/// A titled, horizontally scrolling row of cards — the Netflix shelf the home
/// tab is built from.
///
/// The row's height is derived from the card width and artwork ratio the same
/// way [PosterSliverGrid] derives its tile height, so cards never overflow at a
/// large text scale.
class MediaCarousel extends StatelessWidget {
  const MediaCarousel({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    required this.cardWidth,
    this.aspectRatio = 2 / 3,
    this.hasSubtitle = true,
    this.storageKey,
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Width of one card; the artwork tile fills it and the height follows.
  final double cardWidth;
  final double aspectRatio;
  final bool hasSubtitle;

  /// Preserves the row's scroll offset across tab switches.
  final String? storageKey;

  @override
  Widget build(BuildContext context) {
    final captionHeight =
        PosterCard.captionHeight(context, hasSubtitle: hasSubtitle);
    final storageKey = this.storageKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        SizedBox(
          height: cardWidth / aspectRatio + captionHeight,
          child: ListView.separated(
            key: storageKey == null ? null : PageStorageKey<String>(storageKey),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemCount,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: cardWidth,
              child: itemBuilder(context, index),
            ),
          ),
        ),
      ],
    );
  }
}

/// Row heading used above carousels and grids.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
