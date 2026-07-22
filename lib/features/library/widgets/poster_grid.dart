import 'package:flutter/material.dart';

import 'poster_card.dart';

/// Grid of [PosterCard]s as a sliver, so a tab can stack other sections above
/// and below it in one scroll view.
///
/// The tile height is measured rather than guessed: the number of columns comes
/// from the available width, and the row height is the poster's height for that
/// column width plus the caption underneath. That keeps the cards from
/// overflowing on a narrow phone or at a large text scale, which a fixed
/// `childAspectRatio` can't promise.
class PosterSliverGrid extends StatelessWidget {
  const PosterSliverGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.aspectRatio = 2 / 3,
    this.hasSubtitle = true,
  });

  /// Target width of one card. The grid fits as many whole columns as it can,
  /// giving 2 columns on a small phone and 3 on a typical one.
  static const double _targetCardWidth = 170;

  static const double _crossSpacing = 12;
  static const double _mainSpacing = 20;

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Aspect ratio of the artwork tile (not the whole card).
  final double aspectRatio;

  /// Whether cards carry a second caption line, which the row height allows for.
  final bool hasSubtitle;

  @override
  Widget build(BuildContext context) {
    final captionHeight =
        PosterCard.captionHeight(context, hasSubtitle: hasSubtitle);

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns =
            (width / _targetCardWidth).ceil().clamp(2, 4);
        final cardWidth =
            (width - _crossSpacing * (columns - 1)) / columns;

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: _crossSpacing,
            mainAxisSpacing: _mainSpacing,
            mainAxisExtent: cardWidth / aspectRatio + captionHeight,
          ),
          delegate: SliverChildBuilderDelegate(itemBuilder,
              childCount: itemCount),
        );
      },
    );
  }
}
