import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';

import 'folder_access.dart';

/// Android implementation of [FolderAccess] backed by the Storage Access
/// Framework (`ACTION_OPEN_DOCUMENT_TREE`). Grants are scoped to the folders the
/// user picks and are persisted, so access survives app restarts. No broad
/// storage permission (e.g. MANAGE_EXTERNAL_STORAGE) is ever requested.
class SafFolderAccess implements FolderAccess {
  SafFolderAccess([SafUtil? saf]) : _saf = saf ?? SafUtil();

  final SafUtil _saf;

  @override
  Future<PickedFolder?> pickFolder() async {
    // Read-only access is all a player needs; request a persistable grant so
    // the folder is still readable after a restart.
    final dir = await _saf.pickDirectory(
      writePermission: false,
      persistablePermission: true,
    );
    if (dir == null) return null;
    return PickedFolder(uri: dir.uri, displayName: dir.name);
  }

  @override
  Stream<ScannedFile> listFiles(String folderUri) async* {
    // Depth-first walk. saf_util's list() returns one level, so recurse into
    // subdirectories. A queue (not real recursion) keeps the stack flat for
    // deep trees. Each entry carries the folder's ancestor names (nearest-first,
    // excluding the root) so files can report their parent path.
    final pending = <_PendingDir>[_PendingDir(folderUri, null, const [])];
    while (pending.isNotEmpty) {
      final dir = pending.removeLast();
      final List<SafDocumentFile> children;
      try {
        children = await _saf.list(dir.uri);
      } on Object {
        // A folder we lost access to (moved/deleted) shouldn't abort the scan.
        continue;
      }
      // Ancestors of this dir's children = [this dir's name, ...its ancestors].
      // The root's name is null (unknown from a bare URI), so it's excluded.
      final childAncestors =
          dir.name == null ? dir.ancestors : [dir.name!, ...dir.ancestors];
      for (final child in children) {
        if (child.isDir) {
          pending.add(_PendingDir(child.uri, child.name, childAncestors));
        } else {
          yield ScannedFile(
            uri: child.uri,
            name: child.name,
            size: child.length,
            lastModified: child.lastModified,
            parentPath: childAncestors,
          );
        }
      }
    }
  }

  @override
  Future<bool> hasAccess(String folderUri) {
    return _saf.hasPersistedPermission(folderUri);
  }

  @override
  Future<void> releaseFolder(String folderUri) {
    return _saf.releasePersistedPermission(folderUri);
  }
}

/// A directory queued for traversal, with its display name (null for the root,
/// whose name isn't known from its URI alone) and ancestor folder names.
class _PendingDir {
  const _PendingDir(this.uri, this.name, this.ancestors);
  final String uri;
  final String? name;
  final List<String> ancestors;
}

/// The app's folder-access implementation. Android-only today; an iOS
/// implementation would be swapped in here (see CLAUDE.md Platform Policy).
final folderAccessProvider = Provider<FolderAccess>((ref) => SafFolderAccess());
