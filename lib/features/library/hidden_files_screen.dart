import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import 'media_display.dart';

/// Files the user hid as "not a movie" (samples, trailers). They still exist in
/// the database — this screen lists them so any can be restored to the library.
class HiddenFilesScreen extends ConsumerWidget {
  const HiddenFilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiddenAsync = ref.watch(hiddenMediaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hidden files')),
      body: hiddenAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(child: Text('Could not load hidden files.\n$e')),
        data: (files) {
          if (files.isEmpty) return const _Empty();
          return ListView.separated(
            itemCount: files.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final file = files[index];
              return ListTile(
                leading: const Icon(Icons.visibility_off_outlined,
                    color: AppColors.textSecondary),
                title: Text(
                  file.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  file.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                trailing: TextButton(
                  onPressed: () => _restore(context, ref, file),
                  child: const Text('Restore'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    MediaFile file,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(libraryRepositoryProvider).setHidden(file.id, false);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Restored “${file.displayTitle}” to your library.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Reactive list of hidden files.
final hiddenMediaProvider = StreamProvider<List<MediaFile>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchHiddenMedia();
});

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
            Icon(Icons.visibility_outlined,
                size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'No hidden files',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Files you mark “not a movie” show up here to restore.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
