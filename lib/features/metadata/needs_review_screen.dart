import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'fix_match_flow.dart';
import 'metadata_providers.dart';

/// The titles the matcher couldn't confidently place, each with the same
/// search-and-pick correction flow as the detail screens. An item leaves this
/// list the moment it's corrected — the list is derived live from the library.
class NeedsReviewScreen extends ConsumerWidget {
  const NeedsReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(reviewItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Needs review')),
      body: items.isEmpty
          ? const _Empty()
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(
                    item.isMovie ? Icons.movie_outlined : Icons.tv_outlined,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    item.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.search, size: 20),
                  onTap: () => runFixMatch(
                    context,
                    ref,
                    matchKey: item.matchKey,
                    parsedTitle: item.title,
                    isMovie: item.isMovie,
                  ),
                );
              },
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Nothing needs review',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Every title was matched with confidence.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
