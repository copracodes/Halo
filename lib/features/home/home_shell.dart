import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../library/manage_folders_screen.dart';
import '../library/movies_tab.dart';
import '../library/scan_controller.dart';
import '../library/tv_shows_tab.dart';
import '../metadata/metadata_providers.dart';
import '../metadata/metadata_sync_indicator.dart';
import '../metadata/tmdb_debug_dialog.dart';
import '../player/player_screen.dart';
import 'home_tab.dart';
import 'widgets/scan_banner.dart';

/// The browsing shell once the library has at least one folder: three tabs
/// under one app bar, with folder management behind the settings icon.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[HomeTab(), MoviesTab(), TvShowsTab()];

  /// Ad-hoc playback of a single file from anywhere on the device — unrelated
  /// to the indexed library, which is why it keeps using the file picker rather
  /// than `FolderAccess`.
  Future<void> _openAdHocVideo() async {
    final navigator = Navigator.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedVideoExtensions.toList(),
    );

    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null) return;

    // The picker copies the file into a fresh cache folder each pick, so `path`
    // is not stable; identify by the content URI (or name+size) for resume.
    final identifier = file.identifier;
    final mediaId = (identifier != null && identifier.isNotEmpty)
        ? identifier
        : '${file.name}:${file.size}';

    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(path: path, mediaId: mediaId),
      ),
    );
  }

  void _openManageFolders() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ManageFoldersScreen()),
    );
  }

  /// TEMPORARY (Phase 3.1): long-press the settings icon to run one live TMDB
  /// search and see the raw response, confirming the token works on a real
  /// device and network. Remove when 3.2 wires real enrichment.
  void _openTmdbProbe() {
    showDialog<void>(
      context: context,
      builder: (_) => const TmdbDebugDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanning = ref.watch(scanControllerProvider.select((s) => s.scanning));
    final reviewCount = ref.watch(reviewCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        actions: [
          const MetadataSyncIndicator(),
          IconButton(
            icon: const Icon(Icons.video_file_outlined),
            tooltip: 'Open a file',
            onPressed: _openAdHocVideo,
          ),
          // IconButton has no long-press, so the settings action is built from
          // InkResponse to carry the temporary TMDB probe (Phase 3.1).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Tooltip(
              message: 'Settings',
              child: InkResponse(
                onTap: _openManageFolders,
                onLongPress: _openTmdbProbe,
                radius: 22,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  // Badge draws attention to titles the matcher wasn't sure
                  // about, which is where the user's manual attention is wanted.
                  child: Badge.count(
                    count: reviewCount,
                    isLabelVisible: reviewCount > 0,
                    child: const Icon(Icons.settings_outlined),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (scanning) const ScanBanner(),
          Expanded(
            // Cross-fades and lifts the incoming tab slightly. Each tab's
            // scroll view carries a PageStorageKey, so scroll position is
            // restored even though the widget itself is rebuilt.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey<int>(_index),
                child: _tabs[_index],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie, color: Colors.white),
            label: 'Movies',
          ),
          NavigationDestination(
            icon: Icon(Icons.tv_outlined),
            selectedIcon: Icon(Icons.tv, color: Colors.white),
            label: 'TV Shows',
          ),
        ],
      ),
    );
  }
}
