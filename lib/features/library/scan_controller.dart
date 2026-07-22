import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/library_repository.dart';
import '../metadata/metadata_sync.dart';
import 'folder_access/saf_folder_access.dart';
import 'library_providers.dart';

/// Live progress of a library scan, observed by the UI.
class ScanState {
  const ScanState({
    required this.scanning,
    required this.filesFound,
    this.currentFolder,
  });

  const ScanState.idle()
      : scanning = false,
        filesFound = 0,
        currentFolder = null;

  final bool scanning;

  /// Running count of video files found so far in the current scan.
  final int filesFound;

  /// Display name of the folder currently being scanned, if any.
  final String? currentFolder;

  ScanState copyWith({
    bool? scanning,
    int? filesFound,
    String? currentFolder,
  }) {
    return ScanState(
      scanning: scanning ?? this.scanning,
      filesFound: filesFound ?? this.filesFound,
      currentFolder: currentFolder ?? this.currentFolder,
    );
  }
}

/// Drives library scans and exposes their progress. Scanning is a no-op while
/// one is already running, so auto-scan and a manual "Scan Now" can't overlap.
class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState.idle();

  /// Opens the system folder picker; if the user picks a folder, persists it as
  /// a library folder and immediately scans everything. Returns true if a folder
  /// was added. Does nothing if the picker was cancelled.
  Future<bool> addFolder() async {
    final picked = await ref.read(folderAccessProvider).pickFolder();
    if (picked == null) return false;
    await ref.read(libraryRepositoryProvider).addFolder(
          path: picked.uri,
          displayName: picked.displayName,
        );
    await scanAll();
    return true;
  }

  /// Scans every library folder in sequence, updating [state] as it goes. Safe
  /// to call on app start (silent auto-scan) and from a button.
  Future<void> scanAll() async {
    if (state.scanning) return;

    final library = ref.read(libraryRepositoryProvider);
    final scanner = ref.read(libraryScannerProvider);
    final folders = await library.allFolders();
    if (folders.isEmpty) return;

    state = const ScanState(scanning: true, filesFound: 0);
    var total = 0;
    try {
      for (final folder in folders) {
        state = state.copyWith(currentFolder: 'Scanning ${folder.displayName}');
        final result = await scanner.scanFolder(
          folder,
          onFileFound: (found) =>
              state = state.copyWith(filesFound: total + found),
        );
        total += result.found;
      }
    } finally {
      state = ScanState(scanning: false, filesFound: total);
    }

    // Enrichment follows indexing: the scan decides *what* exists, the sync
    // decides what it is. Deliberately not awaited — browsing must never wait
    // on the network — and it skips itself silently when offline.
    unawaited(ref.read(metadataSyncProvider.notifier).syncNow());
  }

  /// Re-runs the filename parser over existing rows (no disk rescan), refreshing
  /// titles and season/episode numbers.
  Future<void> reparse() async {
    if (state.scanning) return;
    final scanner = ref.read(libraryScannerProvider);
    state = const ScanState(
      scanning: true,
      filesFound: 0,
      currentFolder: 'Reparsing library',
    );
    try {
      final total = await scanner.reparseAll(
        onProgress: (done) => state = state.copyWith(filesFound: done),
      );
      state = ScanState(scanning: false, filesFound: total);
    } finally {
      if (state.scanning) state = const ScanState.idle();
    }
  }
}

final scanControllerProvider =
    NotifierProvider<ScanController, ScanState>(ScanController.new);
