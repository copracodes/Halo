import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../metadata/metadata_sync.dart';
import '../metadata/tmdb_attribution.dart';
import 'library_providers.dart';
import 'scan_controller.dart';

/// Lets the user add, scan, and remove the folders Halo indexes.
class ManageFoldersScreen extends ConsumerWidget {
  const ManageFoldersScreen({super.key});

  Future<void> _addFolder(WidgetRef ref) =>
      ref.read(scanControllerProvider.notifier).addFolder();

  /// Runs a sync and reports the result.
  ///
  /// The app-bar spinner lives on the home shell, which is *behind* this
  /// pushed screen — so from here it is invisible, and a fast no-op sync used
  /// to look exactly like a dead button. The outcome is stated explicitly
  /// instead.
  Future<void> _syncMetadata(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(metadataSyncProvider.notifier).syncNow(retryFailed: true);
    final outcome = ref.read(metadataSyncProvider).outcome;

    messenger.showSnackBar(
      SnackBar(
        content: Text(outcome.message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _removeFolder(
    BuildContext context,
    WidgetRef ref,
    LibraryFolder folder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove folder?'),
        content: Text(
          '“${folder.displayName}” and its indexed files will be removed from '
          'your library. The files on disk are not touched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(libraryRepositoryProvider).removeFolder(folder.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(libraryFoldersProvider);
    final scan = ref.watch(scanControllerProvider);
    final syncing = ref.watch(metadataSyncProvider.select((s) => s.running));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage folders'),
        actions: [
          TextButton(
            onPressed: scan.scanning
                ? null
                : () => ref.read(scanControllerProvider.notifier).reparse(),
            child: const Text('Reparse'),
          ),
          TextButton.icon(
            onPressed: scan.scanning
                ? null
                : () => ref.read(scanControllerProvider.notifier).scanAll(),
            icon: const Icon(Icons.refresh),
            label: const Text('Scan now'),
          ),
          // A scan already triggers a sync; this runs one on its own, and
          // retries titles a previous pass failed to match.
          TextButton.icon(
            onPressed: syncing ? null : () => _syncMetadata(context, ref),
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Sync metadata'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addFolder(ref),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('Add folder'),
      ),
      body: Column(
        children: [
          if (scan.scanning) _ScanBanner(scan: scan),
          if (syncing) const _SyncBanner(),
          Expanded(
            child: foldersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (e, _) => Center(child: Text('Could not load folders.\n$e')),
              data: (folders) {
                if (folders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No folders yet. Add one to build your library.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (context, i) {
                    final folder = folders[i];
                    return ListTile(
                      leading: const Icon(Icons.folder,
                          color: AppColors.accent),
                      title: Text(folder.displayName),
                      subtitle: Text(
                        folder.path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove folder',
                        onPressed: () => _removeFolder(context, ref, folder),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // TMDB's terms require attribution wherever their data is used.
          const TmdbAttribution(),
        ],
      ),
    );
  }
}

/// Progress for a metadata sync, shown on this screen because the app-bar
/// indicator belongs to the home shell underneath and can't be seen from here.
class _SyncBanner extends ConsumerWidget {
  const _SyncBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(metadataSyncProvider);
    final counted = sync.total > 0;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              counted
                  ? 'Fetching metadata — ${sync.completed} of ${sync.total}'
                  : 'Fetching metadata…',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// A slim banner shown while a scan is in progress.
class _ScanBanner extends StatelessWidget {
  const _ScanBanner({required this.scan});

  final ScanState scan;

  @override
  Widget build(BuildContext context) {
    final label = scan.currentFolder;
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label == null
                  ? 'Scanning… ${scan.filesFound} found'
                  : '$label… ${scan.filesFound} found',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
