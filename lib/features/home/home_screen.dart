import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../library/library_providers.dart';
import '../library/scan_controller.dart';
import '../library/widgets/library_states.dart';
import 'home_shell.dart';

/// App root. Shows the first-launch invitation until the user adds a library
/// folder, then hands over to the browsing shell.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Silent auto-scan on start: a no-op when there are no folders yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(scanControllerProvider.notifier).scanAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(libraryFoldersProvider);

    return Scaffold(
      body: foldersAsync.when(
        loading: () => const LibraryLoading(),
        error: (error, _) => LibraryMessage(
          icon: Icons.error_outline,
          title: 'Could not open your library.',
          detail: '$error',
        ),
        data: (folders) =>
            folders.isEmpty ? const _EmptyState() : const HomeShell(),
      ),
    );
  }
}

/// First-launch experience: no folders added yet.
class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Point Halo at a folder of movies to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(scanControllerProvider.notifier).addFolder(),
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('Add your movies folder'),
            ),
          ],
        ),
      ),
    );
  }
}
