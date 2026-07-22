import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'metadata_sync.dart';

/// Small app-bar ring shown while metadata is syncing.
///
/// Deliberately understated: enrichment is a background nicety, so it gets a
/// quiet progress ring rather than a banner. It occupies no space at all when
/// idle, and shows nothing when a sync is skipped for being offline — that is
/// expected behaviour, not a problem to report.
class MetadataSyncIndicator extends ConsumerWidget {
  const MetadataSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(metadataSyncProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: sync.running
          ? Tooltip(
              key: const ValueKey('syncing'),
              message: sync.total > 0
                  ? 'Fetching metadata (${sync.completed}/${sync.total})'
                  : 'Fetching metadata',
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    // Indeterminate: the item count is a poor predictor of
                    // time, since one match can mean three requests.
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('idle')),
    );
  }
}
