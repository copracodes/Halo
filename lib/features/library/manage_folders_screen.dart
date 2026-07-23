import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../metadata/metadata_maintenance.dart';
import '../metadata/metadata_providers.dart';
import '../metadata/metadata_sync.dart';
import '../metadata/needs_review_screen.dart';
import '../metadata/tmdb_attribution.dart';
import '../player/playback_settings_screen.dart';
import 'hidden_files_screen.dart';
import 'library_providers.dart';
import 'quality_label.dart';
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
  ///
  /// Deliberately does *not* retry already-failed titles: a film TMDB returned
  /// nothing for lands in Needs review and stays there until the user corrects
  /// it by hand or its parsed title changes — re-querying hopeless titles on
  /// every sync is exactly the infinite-retry this phase set out to avoid.
  Future<void> _syncMetadata(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(metadataSyncProvider.notifier).syncNow();
    final outcome = ref.read(metadataSyncProvider).outcome;

    messenger.showSnackBar(
      SnackBar(
        content: Text(outcome.message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Deletes cached artwork after confirming, and refreshes the size figure.
  /// Metadata is untouched; images re-download on the next sync.
  Future<void> _clearImageCache(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear image cache?'),
        content: const Text(
          'Cached posters and backdrops will be deleted to free up space. Your '
          'matches and details are kept — artwork re-downloads on the next '
          'metadata sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    await ref.read(metadataMaintenanceProvider).clearImageCache();
    ref.invalidate(imageCacheSizeProvider);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Image cache cleared. Artwork re-downloads on next sync.'),
        duration: Duration(seconds: 3),
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
      // The folder's files cascade away by foreign key, but their TMDB records
      // are keyed by title, not folder — so prune whatever is now orphaned.
      // Cached image files are left in place (content-addressed and shared), so
      // re-adding the same folder re-links without re-downloading a thing.
      await ref.read(metadataMaintenanceProvider).pruneOrphans();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(libraryFoldersProvider);
    final scan = ref.watch(scanControllerProvider);
    final syncing = ref.watch(metadataSyncProvider.select((s) => s.running));

    final reviewCount = ref.watch(reviewCountProvider);
    final hiddenCount = ref.watch(hiddenMediaProvider).value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
          _SettingsEntry(
            icon: Icons.rule,
            title: 'Needs review',
            subtitle: reviewCount == 0
                ? 'Everything matched'
                : '$reviewCount ${reviewCount == 1 ? 'title needs' : 'titles need'} a look',
            count: reviewCount,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NeedsReviewScreen()),
            ),
          ),
          _SettingsEntry(
            icon: Icons.visibility_off_outlined,
            title: 'Hidden files',
            subtitle: hiddenCount == 0
                ? 'Nothing hidden'
                : '$hiddenCount ${hiddenCount == 1 ? 'file' : 'files'} hidden',
            count: hiddenCount,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HiddenFilesScreen()),
            ),
          ),
          _ImageCacheEntry(onClear: () => _clearImageCache(context, ref)),
          _SettingsEntry(
            icon: Icons.tune,
            title: 'Playback',
            subtitle: 'Languages, subtitles, and speed',
            count: 0,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PlaybackSettingsScreen(),
              ),
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'FOLDERS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
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

/// The image-cache storage row: shows how much artwork is on disk and offers a
/// clear action. Only the sizes the app renders are ever cached, so this figure
/// is the whole of Halo's artwork footprint.
class _ImageCacheEntry extends ConsumerWidget {
  const _ImageCacheEntry({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeAsync = ref.watch(imageCacheSizeProvider);
    final bytes = sizeAsync.value ?? 0;
    final subtitle = switch (sizeAsync) {
      AsyncData() => bytes == 0
          ? 'No artwork cached'
          : '${formatFileSize(bytes)} of cached artwork',
      AsyncError() => 'Cached artwork',
      _ => 'Measuring…',
    };

    return ListTile(
      leading: const Icon(Icons.image_outlined, color: AppColors.accent),
      title: const Text(
        'Image cache',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: TextButton(
        onPressed: bytes == 0 ? null : onClear,
        child: const Text('Clear'),
      ),
    );
  }
}

/// A navigable settings row with an optional count badge (Needs review, Hidden
/// files).
class _SettingsEntry extends StatelessWidget {
  const _SettingsEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
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
